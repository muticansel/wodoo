const functions = require('firebase-functions');
const admin = require('firebase-admin');

// E-fatura oluşturma fonksiyonu
exports.createInvoice = functions.https.onCall(async (data, context) => {
  try {
    // Kullanıcı kimlik doğrulaması
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı giriş yapmamış');
    }

    const { paymentId, subscriptionPlan, amount } = data;
    const userId = context.auth.uid;

    // Kullanıcı bilgilerini al
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Kullanıcı bulunamadı');
    }

    const userData = userDoc.data();

    // E-fatura oluştur
    const invoice = await generateInvoice({
      userId,
      userData,
      paymentId,
      subscriptionPlan,
      amount,
    });

    // Firestore'a kaydet
    await admin.firestore().collection('invoices').add(invoice);

    return {
      success: true,
      invoiceId: invoice.invoiceId,
      invoiceNumber: invoice.invoiceNumber,
      message: 'E-fatura başarıyla oluşturuldu'
    };

  } catch (error) {
    console.error('E-fatura oluşturma hatası:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// E-fatura oluşturma (Mock)
async function generateInvoice({ userId, userData, paymentId, subscriptionPlan, amount }) {
  const invoiceId = `INV-${Date.now()}-${userId.substring(0, 8)}`;
  const invoiceNumber = `WOO-${new Date().getFullYear()}-${String(Date.now()).slice(-6)}`;
  
  const invoice = {
    invoiceId,
    invoiceNumber,
    userId,
    paymentId,
    subscriptionPlan,
    amount,
    currency: 'TRY',
    status: 'issued',
    issueDate: new Date().toISOString(),
    dueDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // 30 gün sonra
    
    // Fatura bilgileri
    invoiceDetails: {
      // Satıcı bilgileri (Wodoo)
      seller: {
        name: 'Wodoo CrossFit Training',
        taxNumber: '1234567890',
        address: 'İstanbul, Türkiye',
        phone: '+90 212 123 45 67',
        email: 'info@wodoo.com',
        website: 'www.wodoo.com'
      },
      
      // Alıcı bilgileri (Kullanıcı)
      buyer: {
        name: userData.displayName || 'Kullanıcı',
        email: userData.email,
        taxNumber: userData.taxNumber || '11111111111', // Varsayılan
        address: userData.address || 'Adres bilgisi yok',
        phone: userData.phone || 'Telefon bilgisi yok'
      },
      
      // Ürün/Hizmet detayları
      items: [
        {
          description: getSubscriptionDescription(subscriptionPlan),
          quantity: 1,
          unitPrice: amount,
          totalPrice: amount,
          taxRate: 18, // KDV %18
          taxAmount: amount * 0.18,
          netAmount: amount * 0.82
        }
      ],
      
      // Toplam tutarlar
      totals: {
        netAmount: amount * 0.82,
        taxAmount: amount * 0.18,
        totalAmount: amount
      }
    },
    
    // E-fatura durumu
    eInvoiceStatus: 'pending', // pending, sent, delivered, rejected
    eInvoiceId: null,
    eInvoiceUrl: null,
    
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };

  return invoice;
}

// Abonelik planı açıklaması
function getSubscriptionDescription(plan) {
  const descriptions = {
    'monthly': 'Wodoo Aylık Abonelik - Tüm programlara sınırsız erişim',
    'semi_annual': 'Wodoo 6 Aylık Abonelik - Tüm programlara sınırsız erişim',
    'annual': 'Wodoo Yıllık Abonelik - Tüm programlara sınırsız erişim'
  };
  
  return descriptions[plan] || 'Wodoo Abonelik';
}

// E-fatura durumu sorgulama
exports.getInvoiceStatus = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı giriş yapmamış');
    }

    const { invoiceId } = data;
    const userId = context.auth.uid;

    // Fatura bilgilerini al
    const invoiceSnapshot = await admin.firestore()
      .collection('invoices')
      .where('invoiceId', '==', invoiceId)
      .where('userId', '==', userId)
      .limit(1)
      .get();

    if (invoiceSnapshot.empty) {
      throw new functions.https.HttpsError('not-found', 'Fatura bulunamadı');
    }

    const invoiceData = invoiceSnapshot.docs[0].data();

    return {
      success: true,
      invoice: invoiceData
    };

  } catch (error) {
    console.error('Fatura durumu sorgulama hatası:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Kullanıcının tüm faturalarını listele
exports.getUserInvoices = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı giriş yapmamış');
    }

    const userId = context.auth.uid;
    const { limit = 10, offset = 0 } = data;

    // Kullanıcının faturalarını al
    const invoicesSnapshot = await admin.firestore()
      .collection('invoices')
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .offset(offset)
      .get();

    const invoices = [];
    invoicesSnapshot.forEach(doc => {
      invoices.push({
        id: doc.id,
        ...doc.data()
      });
    });

    return {
      success: true,
      invoices,
      total: invoices.length
    };

  } catch (error) {
    console.error('Fatura listesi alma hatası:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// E-fatura PDF oluşturma (Mock)
exports.generateInvoicePDF = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı giriş yapmamış');
    }

    const { invoiceId } = data;
    const userId = context.auth.uid;

    // Fatura bilgilerini al
    const invoiceSnapshot = await admin.firestore()
      .collection('invoices')
      .where('invoiceId', '==', invoiceId)
      .where('userId', '==', userId)
      .limit(1)
      .get();

    if (invoiceSnapshot.empty) {
      throw new functions.https.HttpsError('not-found', 'Fatura bulunamadı');
    }

    const invoiceData = invoiceSnapshot.docs[0].data();

    // PDF URL oluştur (mock)
    const pdfUrl = `https://wodoo.com/invoices/${invoiceId}.pdf`;

    // Fatura güncelle
    await admin.firestore()
      .collection('invoices')
      .doc(invoiceSnapshot.docs[0].id)
      .update({
        pdfUrl,
        updatedAt: new Date().toISOString()
      });

    return {
      success: true,
      pdfUrl,
      message: 'PDF başarıyla oluşturuldu'
    };

  } catch (error) {
    console.error('PDF oluşturma hatası:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// E-fatura gönderme (Mock)
exports.sendEInvoice = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı giriş yapmamış');
    }

    const { invoiceId } = data;
    const userId = context.auth.uid;

    // Fatura bilgilerini al
    const invoiceSnapshot = await admin.firestore()
      .collection('invoices')
      .where('invoiceId', '==', invoiceId)
      .where('userId', '==', userId)
      .limit(1)
      .get();

    if (invoiceSnapshot.empty) {
      throw new functions.https.HttpsError('not-found', 'Fatura bulunamadı');
    }

    const invoiceData = invoiceSnapshot.docs[0].data();

    // E-fatura gönderme simülasyonu
    const eInvoiceId = `EINV-${Date.now()}`;
    const eInvoiceUrl = `https://earsivportal.efatura.gov.tr/invoice/${eInvoiceId}`;

    // Fatura güncelle
    await admin.firestore()
      .collection('invoices')
      .doc(invoiceSnapshot.docs[0].id)
      .update({
        eInvoiceStatus: 'sent',
        eInvoiceId,
        eInvoiceUrl,
        sentAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });

    return {
      success: true,
      eInvoiceId,
      eInvoiceUrl,
      message: 'E-fatura başarıyla gönderildi'
    };

  } catch (error) {
    console.error('E-fatura gönderme hatası:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Otomatik e-fatura oluşturma (ödeme başarılı olduğunda)
exports.autoCreateInvoice = functions.firestore
  .document('payments/{paymentId}')
  .onCreate(async (snap, context) => {
    try {
      const paymentData = snap.data();
      
      // Sadece başarılı ödemeler için e-fatura oluştur
      if (paymentData.status !== 'completed') {
        return;
      }

      const { userId, plan, amount } = paymentData;

      // Kullanıcı bilgilerini al
      const userDoc = await admin.firestore().collection('users').doc(userId).get();
      if (!userDoc.exists) {
        console.error('Kullanıcı bulunamadı:', userId);
        return;
      }

      const userData = userDoc.data();

      // E-fatura oluştur
      const invoice = await generateInvoice({
        userId,
        userData,
        paymentId: snap.id,
        subscriptionPlan: plan,
        amount,
      });

      // Firestore'a kaydet
      await admin.firestore().collection('invoices').add(invoice);

      console.log(`Otomatik e-fatura oluşturuldu: ${invoice.invoiceId}`);

    } catch (error) {
      console.error('Otomatik e-fatura oluşturma hatası:', error);
    }
  });
