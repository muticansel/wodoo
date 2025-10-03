const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

// Get Firestore instance
const db = admin.firestore();

// Import payment, webhook, invoice, subscription and iyzico functions
const paymentFunctions = require('./payment');
const webhookFunctions = require('./webhooks');
const invoiceFunctions = require('./invoice');
const subscriptionFunctions = require('./subscription');
const iyzicoFunctions = require('./iyzico');

// Send notification to user
async function sendNotificationToUser(userId, notification) {
  try {
    // Get user document
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      console.log('User not found:', userId);
      return;
    }
    
    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;
    const notificationPreferences = userData.notificationPreferences || {};
    
    // Check if user has FCM token
    if (!fcmToken) {
      console.log('No FCM token for user:', userId);
      return;
    }
    
    // Check notification preferences
    const notificationType = notification.type;
    if (notificationPreferences[notificationType] === false) {
      console.log('Notification disabled for user:', userId, 'type:', notificationType);
      return;
    }
    
    // Prepare message
    const message = {
      token: fcmToken,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: {
        type: notificationType,
        ...notification.data,
      },
      android: {
        notification: {
          icon: 'ic_notification',
          color: '#2889B8',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };
    
    // Send notification
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    
    // Log notification to user's notifications collection
    await db.collection('users').doc(userId).collection('notifications').add({
      ...notification,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'sent',
    });
    
  } catch (error) {
    console.error('Error sending notification:', error);
    
    // Log failed notification
    await db.collection('users').doc(userId).collection('notifications').add({
      ...notification,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'failed',
      error: error.message,
    });
  }
}

// Send notification to multiple users
async function sendNotificationToUsers(userIds, notification) {
  const promises = userIds.map(userId => sendNotificationToUser(userId, notification));
  await Promise.all(promises);
}

// Send notification to all users with specific preferences
async function sendNotificationToAllUsers(notification) {
  try {
    const usersSnapshot = await db.collection('users').get();
    const userIds = [];
    
    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      const notificationPreferences = userData.notificationPreferences || {};
      const notificationType = notification.type;
      
      // Check if user has this notification type enabled
      if (notificationPreferences[notificationType] !== false) {
        userIds.push(doc.id);
      }
    });
    
    await sendNotificationToUsers(userIds, notification);
  } catch (error) {
    console.error('Error sending notification to all users:', error);
  }
}

// Cloud Functions

// Send PR update notification
exports.sendPRUpdateNotification = functions.firestore
  .document('users/{userId}/personalRecords/{recordId}')
  .onCreate(async (snap, context) => {
    const recordData = snap.data();
    const userId = context.params.userId;
    
    const notification = {
      type: 'prUpdates',
      title: '🎉 Yeni Kişisel Rekor!',
      body: `${recordData.exercise} için yeni PR: ${recordData.weight}kg`,
      data: {
        exercise: recordData.exercise,
        weight: recordData.weight.toString(),
        recordId: snap.id,
      },
    };
    
    await sendNotificationToUser(userId, notification);
  });

// Send subscription notification
exports.sendSubscriptionNotification = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const userId = context.params.userId;
    
    // Check if subscription status changed
    if (beforeData.subscriptionStatus !== afterData.subscriptionStatus) {
      let notification;
      
      if (afterData.subscriptionStatus === 'active') {
        notification = {
          type: 'subscriptionNotifications',
          title: '✅ Abonelik Aktif!',
          body: 'Premium özellikler artık kullanımınızda',
          data: {
            subscriptionStatus: afterData.subscriptionStatus,
          },
        };
      } else if (afterData.subscriptionStatus === 'expired') {
        notification = {
          type: 'subscriptionNotifications',
          title: '⚠️ Abonelik Süresi Doldu',
          body: 'Premium özellikler için aboneliğinizi yenileyin',
          data: {
            subscriptionStatus: afterData.subscriptionStatus,
          },
        };
      }
      
      if (notification) {
        await sendNotificationToUser(userId, notification);
      }
    }
  });

// Send program update notification
exports.sendProgramUpdateNotification = functions.firestore
  .document('programs/{programId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const programId = context.params.programId;
    
    // Check if program was updated
    if (beforeData.updatedAt !== afterData.updatedAt) {
      const notification = {
        type: 'programUpdates',
        title: '🔄 Program Güncellendi!',
        body: `${afterData.name} programında yeni güncellemeler var`,
        data: {
          programId: programId,
          programName: afterData.name,
        },
      };
      
      // Send to all users who have this program
      const usersSnapshot = await db.collection('users').get();
      const userIds = [];
      
      usersSnapshot.forEach(doc => {
        const userData = doc.data();
        const userPrograms = userData.programs || [];
        
        // Check if user has this program
        if (userPrograms.includes(programId)) {
          userIds.push(doc.id);
        }
      });
      
      await sendNotificationToUsers(userIds, notification);
    }
  });

// Manual notification trigger (for testing)
exports.sendTestNotification = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const userId = context.auth.uid;
  const notification = {
    type: 'test',
    title: '🧪 Test Bildirimi',
    body: 'Bu bir test bildirimidir',
    data: {
      test: 'true',
    },
  };
  
  await sendNotificationToUser(userId, notification);
  
  return { success: true, message: 'Test notification sent' };
});

// Send custom notification (admin only)
exports.sendCustomNotification = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated and is admin
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  // Check if user is admin (you can implement your own admin check logic)
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  const userData = userDoc.data();
  
  if (!userData || !userData.isAdmin) {
    throw new functions.https.HttpsError('permission-denied', 'User must be admin');
  }
  
  const { userIds, notification } = data;
  
  if (userIds && Array.isArray(userIds)) {
    await sendNotificationToUsers(userIds, notification);
  } else {
    await sendNotificationToAllUsers(notification);
  }
  
  return { success: true, message: 'Custom notification sent' };
});

// Clean up old notifications (runs daily)
exports.cleanupOldNotifications = functions.pubsub
  .schedule('0 2 * * *') // Run at 2 AM daily
  .timeZone('Europe/Istanbul')
  .onRun(async (context) => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const usersSnapshot = await db.collection('users').get();
    const batch = db.batch();
    let deleteCount = 0;
    
    for (const userDoc of usersSnapshot.docs) {
      const notificationsSnapshot = await userDoc.ref
        .collection('notifications')
        .where('sentAt', '<', thirtyDaysAgo)
        .get();
      
      notificationsSnapshot.forEach(doc => {
        batch.delete(doc.ref);
        deleteCount++;
      });
    }
    
    if (deleteCount > 0) {
      await batch.commit();
      console.log(`Deleted ${deleteCount} old notifications`);
    }
    
    return null;
  });

// Export payment functions
exports.verifyPayment = paymentFunctions.verifyPayment;
exports.checkSubscriptionStatus = paymentFunctions.checkSubscriptionStatus;
exports.cancelSubscription = paymentFunctions.cancelSubscription;

// Export webhook functions
exports.iyzipayWebhook = webhookFunctions.iyzipayWebhook;

// Export invoice functions
exports.createInvoice = invoiceFunctions.createInvoice;
exports.getInvoiceStatus = invoiceFunctions.getInvoiceStatus;
exports.getUserInvoices = invoiceFunctions.getUserInvoices;
exports.generateInvoicePDF = invoiceFunctions.generateInvoicePDF;
exports.sendEInvoice = invoiceFunctions.sendEInvoice;
exports.autoCreateInvoice = invoiceFunctions.autoCreateInvoice;

// Export subscription functions
exports.checkSubscriptionRenewals = subscriptionFunctions.checkSubscriptionRenewals;
exports.manualRenewal = subscriptionFunctions.manualRenewal;
exports.updateAutoRenewalSettings = subscriptionFunctions.updateAutoRenewalSettings;

// Export iyzico functions
exports.createIyzicoPayment = iyzicoFunctions.createIyzicoPayment;
exports.checkIyzicoPaymentStatus = iyzicoFunctions.checkIyzicoPaymentStatus;
