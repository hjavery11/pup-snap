const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.initializeKey = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
    }

    const pairingKey = data.pairingKey;

    try {
        const ref = admin.database().ref(`/${pairingKey}`);
        console.log(`Checking if key at path: /${pairingKey} exists`);

        // Verify if the key exists and check if the photos key is populated
        const snapshot = await ref.once('value');
        const data = snapshot.val();

        if (data && data.photos) {
            console.log(`Photos key already exists at path: /${pairingKey}`);
            return { message: `Photos key already exists for key ${pairingKey}` };
        } else {
            console.log(`Initializing key at path: /${pairingKey}`);
            // Initialize the key with an empty string
            await ref.set(``);

            console.log(`Data set at path: /${pairingKey}`);
            return { message: `Key ${pairingKey} initialized successfully.` };
        }
    } catch (error) {
        console.error('Error initializing key:', error);
        throw new functions.https.HttpsError('unknown', 'Failed to initialize key', error);
    }
});

exports.checkIfKeyExists = functions.https.onCall(async (data, context) => {
    // Only allow authenticated users to call this function
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
    }

    // Validate input
    const key = data.key;
    if (typeof key !== 'string' || key.trim() === '') {
        throw new functions.https.HttpsError('invalid-argument', 'The function must be called with a valid key.');
    }

    try {
        // Check if the key exists in the database
        const snapshot = await admin.database().ref(`/${key}`).once('value');
        const exists = snapshot.exists();

        return { exists: exists };
    } catch (error) {
        console.error('Error checking if key exists:', error);
        throw new functions.https.HttpsError('unknown', 'Failed to check if key exists', error);
    }
});

exports.generateUniqueKey = functions.https.onCall(async (data, context) => {
    // Only allow authenticated users to call this function
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
    }

    try {
        // Retrieve the current keys from the database
        const snapshot = await admin.database().ref('/').once('value');
        const data = snapshot.val();

        // Extract the keys from the top-level objects
        const keys = Object.keys(data).map(key => parseInt(key, 10)).filter(key => !isNaN(key));

        // Generate a new 8-digit key that isn't in the current list
        let newKey;
        do {
            newKey = Math.floor(10000000 + Math.random() * 90000000);
        } while (keys.includes(newKey));

        // Optionally, you can store the new key in the database if needed
        // await admin.database().ref(`/${newKey}`).set({ someData: 'value' });

        return { newKey: newKey };
    } catch (error) {
        console.error('Error generating unique key:', error);
        throw new functions.https.HttpsError('unknown', 'Failed to generate unique key', error);
    }
});

exports.setCustomClaims = functions.https.onCall(async (data, context) => {
    const uid = data.uid;
    const pairingKey = String(data.pairingKey);

    // Check if the user making the request is authenticated
    if (context.auth && context.auth.token) {
        // Set custom user claims on this newly created user.
        return admin.auth().setCustomUserClaims(uid, { pairingKey: pairingKey })
            .then(() => {
                return { message: `Custom claims set for user ${uid} for pairing key ${pairingKey}` };
            })
            .catch(error => {
                return { error: error.message };
            });
    } else {
        throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
    }
});

exports.sendPushNotification = functions.https.onRequest((req, res) => {
    const token = req.body.token;
    const notification = {
        title: req.body.notification.title,
        body: req.body.notification.body,
    };
    const data = req.body.data;

    const message = {
        notification: notification,
        data: data,
        token: token,
        android: {
            notification: {
                sound: 'default'
            }
        },
        apns: {
            payload: {
                aps: {
                    alert: {
                        title: req.body.notification.title,
                        body: req.body.notification.body,
                    },
                    sound: 'default'
                }
            }
        }
    };

    admin.messaging().send(message)
        .then((response) => {
            res.status(200).send('Notification sent successfully: ' + response);
        })
        .catch((error) => {
            res.status(500).send('Error sending notification: ' + error);
        });
});

exports.sendPushNotificationToTopic = functions.https.onRequest((req, res) => {
    const notification = {
        title: req.body.notification.title,
        body: req.body.notification.body,
    };
    const data = req.body.data;

    const message = {
        notification: notification,
        data: data,
        topic: 'allUsers',
        android: {
            notification: {
                sound: 'default'
            }
        },
        apns: {
            payload: {
                aps: {
                    alert: {
                        title: req.body.notification.title,
                        body: req.body.notification.body,
                    },
                    sound: 'default'
                }
            }
        }
    };

    admin.messaging().send(message)
        .then((response) => {
            res.status(200).send('Notification sent successfully: ' + response);
        })
        .catch((error) => {
            res.status(500).send('Error sending notification: ' + error);
        });
});

exports.notifyOnNewPhotoEntry = functions.database.ref('{pairingKey}/photos/{photoId}').onCreate(async (snapshot, context) => {
    const pairingKey = context.params.pairingKey
    const photoId = context.params.photoId;
    const photoData = snapshot.val();
    console.log('New photo entry:', photoData);

    const message = {
        notification: {
            title: 'New PupSnap Photo!',
            body: 'A new photo has been uploaded to your PupSnap Feed.',
        },
        data: {
            id: photoId,
            caption: photoData.caption || '',
            path: photoData.path || '',
            ratings: JSON.stringify(photoData.ratings || {}),
            timestamp: String(photoData.timestamp || '')
        },
        topic: `pairingKey_${pairingKey}`,
        android: {
            notification: {
                sound: 'default'
            }
        },
        apns: {
            payload: {
                aps: {
                    alert: {
                         title: 'New PupSnap Photo!',
                         body: 'A new photo has been uploaded to your PupSnap Feed.',
                    },
                    sound: 'default'
                },
                'mutable-content': 1
            },
            fcm_options: {
                image: `https://sophie-photo-1ccc0-default-rtdb.firebaseio.com/${photoData.path}`
            }
        }
    };

    try {
        const response = await admin.messaging().send(message);
        console.log('Notification sent succesfully with message:', message)
        console.log('Notification response was:', response);        
    } catch (error) {
        console.error(`Error sending notification for topic: pairingKey_${pairingKey}`, error);
    }
});
