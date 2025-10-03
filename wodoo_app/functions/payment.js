const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Ödeme doğrulama fonksiyonu
exports.verifyPayment = functions.https.onCall(async (data, context) => {
  try {
    // Kullanıcı kimlik doğrulaması
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı giriş yapmamış');
    }

    const { paymentId, subscriptionPlan, amount } = data;
    const userId = context.auth.uid;

    // Ödeme doğrulama (gerçek uygulamada İyizico API'si kullanılacak)
    const isPaymentValid = await verifyPaymentWithProvider(paymentId, amount);

    if (!isPaymentValid) {
      throw new functions.https.HttpsError('invalid-argument', 'Ödeme doğrulanamadı');
    }

    // Abonelik oluştur
    await createUserSubscription(userId, subscriptionPlan, paymentId);

    return {
      success: true,
      message: 'Abonelik başarıyla oluşturuldu',
      subscriptionPlan,
      paymentId
    };

  } catch (error) {
    console.error('Ödeme doğrulama hatası:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Ödeme sağlayıcısı ile doğrulama (Mock)
async function verifyPaymentWithProvider(paymentId, amount) {
  // Gerçek uygulamada İyizico API'si kullanılacak
  // Şimdilik mock doğrulama
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(true); // Her zaman başarılı
    }, 1000);
  });
}

// Kullanıcı aboneliği oluştur
async function createUserSubscription(userId, plan, paymentId) {
  const db = admin.firestore();
  const userRef = db.collection('users').doc(userId);

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
    default:
      endDate.setDate(startDate.getDate() + 30);
  }

  // Kullanıcı belgesini güncelle
  await userRef.update({
    'subscription.plan': plan,
    'subscription.isActive': true,
    'subscription.startDate': startDate.toISOString(),
    'subscription.endDate': endDate.toISOString(),
    'subscription.paymentId': paymentId,
    'subscription.lastPaymentDate': startDate.toISOString(),
  });

  // Ödeme geçmişi ekle
  await db.collection('payments').add({
    userId,
    paymentId,
    plan,
    amount: getPlanAmount(plan),
    status: 'completed',
    createdAt: startDate.toISOString(),
  });

  console.log(`Abonelik oluşturuldu: ${userId} - ${plan}`);
}

// Plan fiyatlarını al
function getPlanAmount(plan) {
  const prices = {
    'monthly': 829,
    'semi_annual': 4199,
    'annual': 7999
  };
  return prices[plan] || 829;
}

// Abonelik durumu kontrolü
exports.checkSubscriptionStatus = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı giriş yapmamış');
    }

    const userId = context.auth.uid;
    const db = admin.firestore();
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      return {
        isSubscribed: false,
        plan: null,
        isActive: false
      };
    }

    const userData = userDoc.data();
    const subscription = userData.subscription || {};

    const isActive = subscription.isActive && 
                    subscription.endDate && 
                    new Date(subscription.endDate) > new Date();

    return {
      isSubscribed: isActive,
      plan: subscription.plan,
      isActive,
      startDate: subscription.startDate,
      endDate: subscription.endDate
    };

  } catch (error) {
    console.error('Abonelik durumu kontrol hatası:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Abonelik iptal etme
exports.cancelSubscription = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı giriş yapmamış');
    }

    const userId = context.auth.uid;
    const db = admin.firestore();
    const userRef = db.collection('users').doc(userId);

    await userRef.update({
      'subscription.isActive': false,
      'subscription.cancelledAt': new Date().toISOString(),
    });

    return {
      success: true,
      message: 'Abonelik iptal edildi'
    };

  } catch (error) {
    console.error('Abonelik iptal hatası:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
