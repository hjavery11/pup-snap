const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

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

// Function to send a notification when a new file is uploaded to Firebase Storage
exports.notifyOnFileUpload = functions.storage.object().onFinalize(async (object) => {
    const filePath = object.name;
    console.log('New file uploaded:', filePath);

    const message = {
        notification: {
            title: 'New Sophie Photo!',
            body: 'A new photo has been uploaded.',
        },
        data: {
            filePath: filePath
        },
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
                        title: 'New Sophie Photo!',
                        body: 'A new photo has been uploaded.',
                    },
                    sound: 'default'
                },
                'mutable-content': 1
            },
            fcm_options: {
                image: `https://your-storage-bucket-url/${filePath}`
            }
        }
    };

    try {
        const response = await admin.messaging().send(message);
        console.log('Notification sent successfully:', response);
    } catch (error) {
        console.error('Error sending notification:', error);
    }
});
