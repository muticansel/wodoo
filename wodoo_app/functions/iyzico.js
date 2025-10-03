const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const crypto = require('crypto');

// İyizico API bilgileri
const IYZICO_CONFIG = {
  apiKey: 'sandbox-your-api-key', // Gerçek API key'inizi buraya yazın
  secretKey: 'sandbox-your-secret-key', // Gerçek secret key'inizi buraya yazın
  baseUrl: 'https://sandbox-api.iyzipay.com'
};

// İyizico ödeme oluşturma
exports.createIyzicoPayment = functions.https.onCall(async (data, context) => {
  try {
    // Kullanıcı kimlik doğrulaması
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı giriş yapmamış');
    }

    const { paymentData } = data;
    const userId = context.auth.uid;

    // İyizico ödeme isteği oluştur
    const iyzicoRequest = {
      locale: 'tr',
      conversationId: `subscription_${userId}_${Date.now()}`,
      price: paymentData.amount.toString(),
      paidPrice: paymentData.amount.toString(),
      currency: paymentData.currency || 'TRY',
      installment: 1,
      basketId: `subscription_${paymentData.subscriptionPlan}`,
      paymentChannel: 'WEB',
      paymentGroup: 'SUBSCRIPTION',
      
      // Kart bilgileri
      paymentCard: {
        cardHolderName: paymentData.cardInfo.cardHolderName,
        cardNumber: paymentData.cardInfo.cardNumber,
        expireMonth: paymentData.cardInfo.expireMonth,
        expireYear: paymentData.cardInfo.expireYear,
        cvc: paymentData.cardInfo.cvc,
      },
      
      // Alıcı bilgileri
      buyer: {
        id: userId,
        name: paymentData.buyerInfo.name,
        surname: paymentData.buyerInfo.surname,
        email: paymentData.buyerInfo.email,
        identityNumber: paymentData.buyerInfo.identityNumber || '11111111111',
        registrationAddress: paymentData.buyerInfo.address || 'Test Address',
        city: paymentData.buyerInfo.city || 'Istanbul',
        country: 'Turkey',
        ip: paymentData.buyerInfo.ip || '127.0.0.1',
      },
      
      // Adres bilgileri
      billingAddress: {
        contactName: `${paymentData.buyerInfo.name} ${paymentData.buyerInfo.surname}`,
        city: paymentData.buyerInfo.city || 'Istanbul',
        country: 'Turkey',
        address: paymentData.buyerInfo.address || 'Test Address',
        zipCode: paymentData.buyerInfo.zipCode || '34000',
      },
      shippingAddress: {
        contactName: `${paymentData.buyerInfo.name} ${paymentData.buyerInfo.surname}`,
        city: paymentData.buyerInfo.city || 'Istanbul',
        country: 'Turkey',
        address: paymentData.buyerInfo.address || 'Test Address',
        zipCode: paymentData.buyerInfo.zipCode || '34000',
      },
      
      // Sepet öğeleri
      basketItems: [
        {
          id: paymentData.subscriptionPlan,
          name: `Wodoo ${paymentData.subscriptionPlan} Subscription`,
          category1: 'Subscription',
          category2: 'Fitness',
          itemType: 'VIRTUAL',
          price: paymentData.amount.toString(),
        }
      ],
    };

    // İyizico imzası oluştur
    const requestBody = JSON.stringify(iyzicoRequest);
    const randomString = generateRandomString();
    const dataString = `${IYZICO_CONFIG.apiKey}${randomString}${IYZICO_CONFIG.secretKey}${requestBody}`;
    const hash = crypto.createHash('sha1').update(dataString).digest('hex');
    const authorization = `IYZWS ${IYZICO_CONFIG.apiKey}:${hash}`;

    // İyizico API'sine istek gönder
    const response = await axios.post(
      `${IYZICO_CONFIG.baseUrl}/payment/create`,
      iyzicoRequest,
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authorization,
        },
      }
    );

    if (response.data.status === 'success') {
      return {
        success: true,
        paymentId: response.data.paymentId,
        status: response.data.status,
        errorMessage: null,
      };
    } else {
      return {
        success: false,
        errorMessage: response.data.errorMessage || 'Ödeme işlemi başarısız',
      };
    }

  } catch (error) {
    console.error('İyizico ödeme hatası:', error);
    
    if (error.response) {
      return {
        success: false,
        errorMessage: error.response.data?.errorMessage || 'API hatası',
      };
    } else {
      return {
        success: false,
        errorMessage: 'İyizico API bağlantı hatası',
      };
    }
  }
});

// İyizico ödeme durumu sorgulama
exports.checkIyzicoPaymentStatus = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı giriş yapmamış');
    }

    const { paymentId } = data;

    // İyizico ödeme durumu sorgulama isteği
    const statusRequest = {
      locale: 'tr',
      conversationId: `status_${paymentId}`,
      paymentId: paymentId,
    };

    const requestBody = JSON.stringify(statusRequest);
    const randomString = generateRandomString();
    const dataString = `${IYZICO_CONFIG.apiKey}${randomString}${IYZICO_CONFIG.secretKey}${requestBody}`;
    const hash = crypto.createHash('sha1').update(dataString).digest('hex');
    const authorization = `IYZWS ${IYZICO_CONFIG.apiKey}:${hash}`;

    const response = await axios.post(
      `${IYZICO_CONFIG.baseUrl}/payment/retrieve`,
      statusRequest,
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authorization,
        },
      }
    );

    return {
      success: true,
      paymentStatus: response.data.paymentStatus,
      status: response.data.status,
      errorMessage: null,
    };

  } catch (error) {
    console.error('İyizico ödeme durumu sorgulama hatası:', error);
    return {
      success: false,
      errorMessage: 'Ödeme durumu sorgulanamadı',
    };
  }
});

// Rastgele string oluştur
function generateRandomString() {
  return Date.now().toString();
}
