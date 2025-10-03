const functions = require('firebase-functions');
const admin = require('firebase-admin');

// İyizico webhook handler
exports.iyzipayWebhook = functions.https.onRequest(async (req, res) => {
  try {
    // Sadece POST isteklerini kabul et
    if (req.method !== 'POST') {
      return res.status(405).send('Method Not Allowed');
    }

    const webhookData = req.body;
    console.log('İyizico webhook alındı:', webhookData);

    // Webhook doğrulama (gerçek uygulamada İyizico imzası kontrol edilecek)
    const isValidWebhook = await validateWebhookSignature(req);
    
    if (!isValidWebhook) {
      console.error('Geçersiz webhook imzası');
      return res.status(401).send('Unauthorized');
    }

    // Webhook tipine göre işlem yap
    switch (webhookData.eventType) {
      case 'payment.success':
        await handlePaymentSuccess(webhookData);
        break;
      case 'payment.failed':
        await handlePaymentFailed(webhookData);
        break;
      case 'subscription.cancelled':
        await handleSubscriptionCancelled(webhookData);
        break;
      case 'subscription.renewed':
        await handleSubscriptionRenewed(webhookData);
        break;
      default:
        console.log('Bilinmeyen webhook tipi:', webhookData.eventType);
    }

    res.status(200).send('OK');
  } catch (error) {
    console.error('Webhook işleme hatası:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Webhook imza doğrulama (Mock)
async function validateWebhookSignature(req) {
  // Gerçek uygulamada İyizico'nun gönderdiği imza kontrol edilecek
  // Şimdilik her zaman true döndürüyoruz
  return true;
}

// Başarılı ödeme işlemi
async function handlePaymentSuccess(webhookData) {
  try {
    const { paymentId, userId, subscriptionPlan, amount } = webhookData;
    
    console.log(`Başarılı ödeme: ${paymentId} - ${userId} - ${subscriptionPlan}`);

    // Kullanıcı aboneliğini güncelle
    await updateUserSubscription(userId, subscriptionPlan, paymentId, 'active');

    // Ödeme geçmişi ekle
    await addPaymentHistory(userId, paymentId, subscriptionPlan, amount, 'success');

    // Kullanıcıya bildirim gönder
    await sendPaymentSuccessNotification(userId, subscriptionPlan);

  } catch (error) {
    console.error('Başarılı ödeme işleme hatası:', error);
  }
}

// Başarısız ödeme işlemi
async function handlePaymentFailed(webhookData) {
  try {
    const { paymentId, userId, subscriptionPlan, amount, errorMessage } = webhookData;
    
    console.log(`Başarısız ödeme: ${paymentId} - ${userId} - ${errorMessage}`);

    // Ödeme geçmişi ekle
    await addPaymentHistory(userId, paymentId, subscriptionPlan, amount, 'failed');

    // Kullanıcıya bildirim gönder
    await sendPaymentFailedNotification(userId, errorMessage);

  } catch (error) {
    console.error('Başarısız ödeme işleme hatası:', error);
  }
}

// Abonelik iptal işlemi
async function handleSubscriptionCancelled(webhookData) {
  try {
    const { userId, subscriptionPlan, cancellationReason } = webhookData;
    
    console.log(`Abonelik iptal: ${userId} - ${subscriptionPlan}`);

    // Kullanıcı aboneliğini iptal et
    await updateUserSubscription(userId, subscriptionPlan, null, 'cancelled');

    // Kullanıcıya bildirim gönder
    await sendSubscriptionCancelledNotification(userId, cancellationReason);

  } catch (error) {
    console.error('Abonelik iptal işleme hatası:', error);
  }
}

// Abonelik yenileme işlemi
async function handleSubscriptionRenewed(webhookData) {
  try {
    const { paymentId, userId, subscriptionPlan, amount } = webhookData;
    
    console.log(`Abonelik yenilendi: ${paymentId} - ${userId} - ${subscriptionPlan}`);

    // Kullanıcı aboneliğini yenile
    await updateUserSubscription(userId, subscriptionPlan, paymentId, 'active');

    // Ödeme geçmişi ekle
    await addPaymentHistory(userId, paymentId, subscriptionPlan, amount, 'renewal');

    // Kullanıcıya bildirim gönder
    await sendSubscriptionRenewedNotification(userId, subscriptionPlan);

  } catch (error) {
    console.error('Abonelik yenileme işleme hatası:', error);
  }
}

// Kullanıcı aboneliğini güncelle
async function updateUserSubscription(userId, plan, paymentId, status) {
  const db = admin.firestore();
  const userRef = db.collection('users').doc(userId);

  const updateData = {
    'subscription.status': status,
    'subscription.lastUpdated': new Date().toISOString(),
  };

  if (status === 'active') {
    // Abonelik bitiş tarihini hesapla
    const startDate = new Date();
    let endDate = new Date();
    
    switch (plan) {
      case 'monthly':
        endDate.setDate(startDate.getDate() + 30);
        break;
      case 'semi_annual':
        endDate.setDate(startDate.getDate() + 180);
        break;
      case 'annual':
        endDate.setDate(startDate.getDate() + 365);
        break;
    }

    updateData['subscription.plan'] = plan;
    updateData['subscription.isActive'] = true;
    updateData['subscription.startDate'] = startDate.toISOString();
    updateData['subscription.endDate'] = endDate.toISOString();
    
    if (paymentId) {
      updateData['subscription.paymentId'] = paymentId;
      updateData['subscription.lastPaymentDate'] = startDate.toISOString();
    }
  } else if (status === 'cancelled') {
    updateData['subscription.isActive'] = false;
    updateData['subscription.cancelledAt'] = new Date().toISOString();
  }

  await userRef.update(updateData);
}

// Ödeme geçmişi ekle
async function addPaymentHistory(userId, paymentId, plan, amount, status) {
  const db = admin.firestore();
  
  await db.collection('payments').add({
    userId,
    paymentId,
    plan,
    amount,
    status,
    createdAt: new Date().toISOString(),
  });
}

// Başarılı ödeme bildirimi gönder
async function sendPaymentSuccessNotification(userId, subscriptionPlan) {
  try {
    const db = admin.firestore();
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (userDoc.exists) {
      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;
      
      if (fcmToken) {
        const message = {
          token: fcmToken,
          notification: {
            title: 'Ödeme Başarılı! 🎉',
            body: `${subscriptionPlan} aboneliğiniz aktifleştirildi.`,
          },
          data: {
            type: 'payment_success',
            plan: subscriptionPlan,
          },
        };

        await admin.messaging().send(message);
        console.log(`Başarılı ödeme bildirimi gönderildi: ${userId}`);
      }
    }
  } catch (error) {
    console.error('Bildirim gönderme hatası:', error);
  }
}

// Başarısız ödeme bildirimi gönder
async function sendPaymentFailedNotification(userId, errorMessage) {
  try {
    const db = admin.firestore();
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (userDoc.exists) {
      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;
      
      if (fcmToken) {
        const message = {
          token: fcmToken,
          notification: {
            title: 'Ödeme Başarısız ❌',
            body: 'Ödeme işleminiz tamamlanamadı. Lütfen tekrar deneyin.',
          },
          data: {
            type: 'payment_failed',
            error: errorMessage,
          },
        };

        await admin.messaging().send(message);
        console.log(`Başarısız ödeme bildirimi gönderildi: ${userId}`);
      }
    }
  } catch (error) {
    console.error('Bildirim gönderme hatası:', error);
  }
}

// Abonelik iptal bildirimi gönder
async function sendSubscriptionCancelledNotification(userId, reason) {
  try {
    const db = admin.firestore();
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (userDoc.exists) {
      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;
      
      if (fcmToken) {
        const message = {
          token: fcmToken,
          notification: {
            title: 'Abonelik İptal Edildi',
            body: 'Aboneliğiniz iptal edildi. Tekrar abone olmak için uygulamayı ziyaret edin.',
          },
          data: {
            type: 'subscription_cancelled',
            reason: reason,
          },
        };

        await admin.messaging().send(message);
        console.log(`Abonelik iptal bildirimi gönderildi: ${userId}`);
      }
    }
  } catch (error) {
    console.error('Bildirim gönderme hatası:', error);
  }
}

// Abonelik yenileme bildirimi gönder
async function sendSubscriptionRenewedNotification(userId, subscriptionPlan) {
  try {
    const db = admin.firestore();
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (userDoc.exists) {
      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;
      
      if (fcmToken) {
        const message = {
          token: fcmToken,
          notification: {
            title: 'Abonelik Yenilendi 🔄',
            body: `${subscriptionPlan} aboneliğiniz başarıyla yenilendi.`,
          },
          data: {
            type: 'subscription_renewed',
            plan: subscriptionPlan,
          },
        };

        await admin.messaging().send(message);
        console.log(`Abonelik yenileme bildirimi gönderildi: ${userId}`);
      }
    }
  } catch (error) {
    console.error('Bildirim gönderme hatası:', error);
  }
}
