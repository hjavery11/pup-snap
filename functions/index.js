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

exports.getAllKeys = functions.https.onCall(async (data, context) => {
    // Only allow authenticated users to call this function
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
    }

    try {
        const snapshot = await admin.database().ref('/').once('value');
        const data = snapshot.val();

        // Extract the keys from the top-level objects
        const keys = Object.keys(data).map(key => parseInt(key, 10)).filter(key => !isNaN(key));

        return { keys: keys };
    } catch (error) {
        console.error('Error retrieving keys:', error);
        throw new functions.https.HttpsError('unknown', 'Failed to retrieve keys', error);
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
                        title: 'New Sophie Photo!',
                        body: 'A new photo has been uploaded.',
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
