const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Otomatik abonelik yenileme kontrolü (günlük çalışır)
exports.checkSubscriptionRenewals = functions.pubsub
  .schedule('0 9 * * *') // Her gün saat 09:00'da çalışır
  .timeZone('Europe/Istanbul')
  .onRun(async (context) => {
    try {
      console.log('Abonelik yenileme kontrolü başlatıldı');
      
      const db = admin.firestore();
      const now = new Date();
      const threeDaysFromNow = new Date(now.getTime() + (3 * 24 * 60 * 60 * 1000)); // 3 gün sonra
      
      // 3 gün içinde süresi dolacak abonelikleri bul
      const expiringSubscriptions = await db.collection('users')
        .where('subscription.isActive', '==', true)
        .where('subscription.endDate', '<=', threeDaysFromNow.toISOString())
        .where('subscription.endDate', '>', now.toISOString())
        .get();
      
      console.log(`${expiringSubscriptions.size} abonelik 3 gün içinde süresi dolacak`);
      
      // Her abonelik için yenileme kontrolü yap
      for (const userDoc of expiringSubscriptions.docs) {
        const userData = userDoc.data();
        const userId = userDoc.id;
        
        await checkAndRenewSubscription(userId, userData);
      }
      
      // Süresi dolmuş abonelikleri pasif hale getir
      await deactivateExpiredSubscriptions();
      
      console.log('Abonelik yenileme kontrolü tamamlandı');
      
    } catch (error) {
      console.error('Abonelik yenileme kontrolü hatası:', error);
    }
  });

// Abonelik yenileme kontrolü ve işlemi
async function checkAndRenewSubscription(userId, userData) {
  try {
    const subscription = userData.subscription;
    const endDate = new Date(subscription.endDate);
    const now = new Date();
    const daysUntilExpiry = Math.ceil((endDate - now) / (1000 * 60 * 60 * 24));
    
    console.log(`Kullanıcı ${userId} - ${daysUntilExpiry} gün kaldı`);
    
    // 3 gün kala bildirim gönder
    if (daysUntilExpiry === 3) {
      await sendRenewalReminder(userId, subscription.plan, daysUntilExpiry);
    }
    
    // 1 gün kala son bildirim gönder
    if (daysUntilExpiry === 1) {
      await sendFinalRenewalReminder(userId, subscription.plan);
    }
    
    // Otomatik yenileme aktifse ve kredi kartı bilgisi varsa yenile
    if (userData.autoRenewal && userData.paymentMethod) {
      if (daysUntilExpiry <= 1) {
        await attemptAutoRenewal(userId, userData);
      }
    }
    
  } catch (error) {
    console.error(`Abonelik yenileme kontrolü hatası - Kullanıcı ${userId}:`, error);
  }
}

// Süresi dolmuş abonelikleri pasif hale getir
async function deactivateExpiredSubscriptions() {
  try {
    const db = admin.firestore();
    const now = new Date();
    
    const expiredSubscriptions = await db.collection('users')
      .where('subscription.isActive', '==', true)
      .where('subscription.endDate', '<=', now.toISOString())
      .get();
    
    console.log(`${expiredSubscriptions.size} abonelik süresi dolmuş`);
    
    const batch = db.batch();
    
    for (const userDoc of expiredSubscriptions.docs) {
      const userId = userDoc.id;
      
      // Aboneliği pasif hale getir
      batch.update(userDoc.ref, {
        'subscription.isActive': false,
        'subscription.expiredAt': now.toISOString(),
        'subscription.status': 'expired'
      });
      
      // Süresi dolma bildirimi gönder
      await sendSubscriptionExpiredNotification(userId);
    }
    
    if (expiredSubscriptions.size > 0) {
      await batch.commit();
      console.log(`${expiredSubscriptions.size} abonelik pasif hale getirildi`);
    }
    
  } catch (error) {
    console.error('Süresi dolmuş abonelik işleme hatası:', error);
  }
}

// Otomatik yenileme denemesi
async function attemptAutoRenewal(userId, userData) {
  try {
    console.log(`Otomatik yenileme denemesi - Kullanıcı ${userId}`);
    
    const subscription = userData.subscription;
    const paymentMethod = userData.paymentMethod;
    
    // Ödeme tutarını hesapla
    const amount = getSubscriptionAmount(subscription.plan);
    
    // Ödeme işlemini simüle et (gerçek uygulamada İyizico API'si kullanılacak)
    const paymentResult = await processPayment({
      userId,
      amount,
      paymentMethod,
      subscriptionPlan: subscription.plan
    });
    
    if (paymentResult.success) {
      // Aboneliği yenile
      await renewSubscription(userId, subscription.plan, paymentResult.paymentId);
      
      // Başarılı yenileme bildirimi gönder
      await sendAutoRenewalSuccessNotification(userId, subscription.plan);
      
      console.log(`Otomatik yenileme başarılı - Kullanıcı ${userId}`);
    } else {
      // Başarısız yenileme bildirimi gönder
      await sendAutoRenewalFailedNotification(userId, paymentResult.error);
      
      console.log(`Otomatik yenileme başarısız - Kullanıcı ${userId}: ${paymentResult.error}`);
    }
    
  } catch (error) {
    console.error(`Otomatik yenileme hatası - Kullanıcı ${userId}:`, error);
    await sendAutoRenewalFailedNotification(userId, error.message);
  }
}

// Ödeme işlemi simülasyonu
async function processPayment({ userId, amount, paymentMethod, subscriptionPlan }) {
  // Gerçek uygulamada İyizico API'si kullanılacak
  // Şimdilik mock ödeme işlemi
  
  return new Promise((resolve) => {
    setTimeout(() => {
      // %90 başarı oranı ile simüle et
      const isSuccess = Math.random() > 0.1;
      
      if (isSuccess) {
        resolve({
          success: true,
          paymentId: `payment_${Date.now()}_${userId}`,
          transactionId: `txn_${Date.now()}`
        });
      } else {
        resolve({
          success: false,
          error: 'Kart bilgileri geçersiz veya yetersiz bakiye'
        });
      }
    }, 2000);
  });
}

// Abonelik yenileme
async function renewSubscription(userId, plan, paymentId) {
  const db = admin.firestore();
  const userRef = db.collection('users').doc(userId);
  
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
  
  await userRef.update({
    'subscription.isActive': true,
    'subscription.startDate': startDate.toISOString(),
    'subscription.endDate': endDate.toISOString(),
    'subscription.paymentId': paymentId,
    'subscription.lastPaymentDate': startDate.toISOString(),
    'subscription.status': 'active',
    'subscription.renewedAt': startDate.toISOString()
  });
  
  // Ödeme geçmişi ekle
  await db.collection('payments').add({
    userId,
    paymentId,
    plan,
    amount: getSubscriptionAmount(plan),
    status: 'completed',
    type: 'auto_renewal',
    createdAt: startDate.toISOString()
  });
}

// Abonelik tutarını al
function getSubscriptionAmount(plan) {
  const amounts = {
    'monthly': 829,
    'semi_annual': 4199,
    'annual': 7999
  };
  return amounts[plan] || 829;
}

// Yenileme hatırlatma bildirimi gönder
async function sendRenewalReminder(userId, plan, daysLeft) {
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
            title: '⏰ Abonelik Yenileme Hatırlatması',
            body: `${plan} aboneliğinizin süresi ${daysLeft} gün sonra dolacak.`,
          },
          data: {
            type: 'renewal_reminder',
            plan: plan,
            daysLeft: daysLeft.toString(),
          },
        };

        await admin.messaging().send(message);
        console.log(`Yenileme hatırlatması gönderildi: ${userId}`);
      }
    }
  } catch (error) {
    console.error('Yenileme hatırlatması gönderme hatası:', error);
  }
}

// Son yenileme hatırlatması gönder
async function sendFinalRenewalReminder(userId, plan) {
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
            title: '🚨 Son Gün!',
            body: `${plan} aboneliğinizin süresi yarın dolacak. Hemen yenileyin!`,
          },
          data: {
            type: 'final_renewal_reminder',
            plan: plan,
          },
        };

        await admin.messaging().send(message);
        console.log(`Son yenileme hatırlatması gönderildi: ${userId}`);
      }
    }
  } catch (error) {
    console.error('Son yenileme hatırlatması gönderme hatası:', error);
  }
}

// Abonelik süresi dolma bildirimi gönder
async function sendSubscriptionExpiredNotification(userId) {
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
            title: '❌ Abonelik Süresi Doldu',
            body: 'Premium özellikler için aboneliğinizi yenileyin.',
          },
          data: {
            type: 'subscription_expired',
          },
        };

        await admin.messaging().send(message);
        console.log(`Abonelik süresi dolma bildirimi gönderildi: ${userId}`);
      }
    }
  } catch (error) {
    console.error('Abonelik süresi dolma bildirimi gönderme hatası:', error);
  }
}

// Otomatik yenileme başarı bildirimi gönder
async function sendAutoRenewalSuccessNotification(userId, plan) {
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
            title: '✅ Abonelik Otomatik Yenilendi',
            body: `${plan} aboneliğiniz başarıyla yenilendi.`,
          },
          data: {
            type: 'auto_renewal_success',
            plan: plan,
          },
        };

        await admin.messaging().send(message);
        console.log(`Otomatik yenileme başarı bildirimi gönderildi: ${userId}`);
      }
    }
  } catch (error) {
    console.error('Otomatik yenileme başarı bildirimi gönderme hatası:', error);
  }
}

// Otomatik yenileme başarısız bildirimi gönder
async function sendAutoRenewalFailedNotification(userId, error) {
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
            title: '❌ Otomatik Yenileme Başarısız',
            body: 'Aboneliğiniz otomatik olarak yenilenemedi. Lütfen manuel olarak yenileyin.',
          },
          data: {
            type: 'auto_renewal_failed',
            error: error,
          },
        };

        await admin.messaging().send(message);
        console.log(`Otomatik yenileme başarısız bildirimi gönderildi: ${userId}`);
      }
    }
  } catch (error) {
    console.error('Otomatik yenileme başarısız bildirimi gönderme hatası:', error);
  }
}

// Manuel abonelik yenileme
exports.manualRenewal = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı giriş yapmamış');
    }

    const userId = context.auth.uid;
    const { plan } = data;

    // Kullanıcı bilgilerini al
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Kullanıcı bulunamadı');
    }

    const userData = userDoc.data();

    // Ödeme işlemi
    const amount = getSubscriptionAmount(plan);
    const paymentResult = await processPayment({
      userId,
      amount,
      paymentMethod: userData.paymentMethod,
      subscriptionPlan: plan
    });

    if (paymentResult.success) {
      // Aboneliği yenile
      await renewSubscription(userId, plan, paymentResult.paymentId);

      return {
        success: true,
        message: 'Abonelik başarıyla yenilendi',
        paymentId: paymentResult.paymentId
      };
    } else {
      throw new functions.https.HttpsError('payment-failed', paymentResult.error);
    }

  } catch (error) {
    console.error('Manuel yenileme hatası:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Otomatik yenileme ayarlarını güncelle
exports.updateAutoRenewalSettings = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı giriş yapmamış');
    }

    const userId = context.auth.uid;
    const { autoRenewal, paymentMethod } = data;

    await admin.firestore().collection('users').doc(userId).update({
      autoRenewal: autoRenewal,
      paymentMethod: paymentMethod,
      autoRenewalUpdatedAt: new Date().toISOString()
    });

    return {
      success: true,
      message: 'Otomatik yenileme ayarları güncellendi'
    };

  } catch (error) {
    console.error('Otomatik yenileme ayarları güncelleme hatası:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
