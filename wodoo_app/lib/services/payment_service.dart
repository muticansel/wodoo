import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class PaymentService {
  // İyizico Sandbox API Bilgileri
  static const String _apiKey = 'sandbox-your-api-key'; // Gerçek API key'inizi buraya yazın
  static const String _secretKey = 'sandbox-your-secret-key'; // Gerçek secret key'inizi buraya yazın
  static const String _baseUrl = 'https://sandbox-api.iyzipay.com';
  
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Cloud Functions ile İyizico ödeme başlatma
  static Future<Map<String, dynamic>> initiatePayment({
    required String userId,
    required String subscriptionPlan,
    required double amount,
    required String currency,
    required Map<String, String> cardInfo,
    required Map<String, String> buyerInfo,
  }) async {
    try {
      // Cloud Functions ile İyizico API'sine istek gönder
      final callable = _functions.httpsCallable('createIyzicoPayment');
      final result = await callable.call({
        'paymentData': {
          'userId': userId,
          'subscriptionPlan': subscriptionPlan,
          'amount': amount,
          'currency': currency,
          'cardInfo': cardInfo,
          'buyerInfo': buyerInfo,
        }
      });

      return {
        'success': result.data['success'],
        'paymentId': result.data['paymentId'],
        'status': result.data['status'],
        'errorMessage': result.data['errorMessage'],
      };
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'Ödeme başlatılamadı: $e',
      };
    }
  }


  // Cloud Functions ile İyizico ödeme durumu sorgulama
  static Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    try {
      final callable = _functions.httpsCallable('checkIyzicoPaymentStatus');
      final result = await callable.call({
        'paymentId': paymentId,
      });

      return {
        'success': result.data['success'],
        'paymentStatus': result.data['paymentStatus'],
        'status': result.data['status'],
        'errorMessage': result.data['errorMessage'],
      };
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'Ödeme durumu sorgulanamadı: $e',
      };
    }
  }

  // Cloud Functions ile ödeme doğrulama
  static Future<Map<String, dynamic>> verifyPaymentWithCloudFunctions({
    required String paymentId,
    required String subscriptionPlan,
    required double amount,
  }) async {
    try {
      final callable = _functions.httpsCallable('verifyPayment');
      final result = await callable.call({
        'paymentId': paymentId,
        'subscriptionPlan': subscriptionPlan,
        'amount': amount,
      });

      return {
        'success': true,
        'data': result.data,
      };
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'Ödeme doğrulama hatası: $e',
      };
    }
  }

  // Abonelik durumu kontrolü
  static Future<Map<String, dynamic>> checkSubscriptionStatus() async {
    try {
      final callable = _functions.httpsCallable('checkSubscriptionStatus');
      final result = await callable.call();

      return {
        'success': true,
        'data': result.data,
      };
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'Abonelik durumu kontrol hatası: $e',
      };
    }
  }

  // Abonelik iptal etme
  static Future<Map<String, dynamic>> cancelSubscription() async {
    try {
      final callable = _functions.httpsCallable('cancelSubscription');
      final result = await callable.call();

      return {
        'success': true,
        'data': result.data,
      };
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'Abonelik iptal hatası: $e',
      };
    }
  }

  // E-fatura oluşturma
  static Future<Map<String, dynamic>> createInvoice({
    required String paymentId,
    required String subscriptionPlan,
    required double amount,
  }) async {
    try {
      final callable = _functions.httpsCallable('createInvoice');
      final result = await callable.call({
        'paymentId': paymentId,
        'subscriptionPlan': subscriptionPlan,
        'amount': amount,
      });

      return {
        'success': true,
        'data': result.data,
      };
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'E-fatura oluşturma hatası: $e',
      };
    }
  }

  // Fatura durumu sorgulama
  static Future<Map<String, dynamic>> getInvoiceStatus(String invoiceId) async {
    try {
      final callable = _functions.httpsCallable('getInvoiceStatus');
      final result = await callable.call({
        'invoiceId': invoiceId,
      });

      return {
        'success': true,
        'data': result.data,
      };
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'Fatura durumu sorgulama hatası: $e',
      };
    }
  }

  // Kullanıcı faturalarını listele
  static Future<Map<String, dynamic>> getUserInvoices({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final callable = _functions.httpsCallable('getUserInvoices');
      final result = await callable.call({
        'limit': limit,
        'offset': offset,
      });

      return {
        'success': true,
        'data': result.data,
      };
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'Fatura listesi alma hatası: $e',
      };
    }
  }

  // Fatura PDF oluşturma
  static Future<Map<String, dynamic>> generateInvoicePDF(String invoiceId) async {
    try {
      final callable = _functions.httpsCallable('generateInvoicePDF');
      final result = await callable.call({
        'invoiceId': invoiceId,
      });

      return {
        'success': true,
        'data': result.data,
      };
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'PDF oluşturma hatası: $e',
      };
    }
  }

  // E-fatura gönderme
  static Future<Map<String, dynamic>> sendEInvoice(String invoiceId) async {
    try {
      final callable = _functions.httpsCallable('sendEInvoice');
      final result = await callable.call({
        'invoiceId': invoiceId,
      });

      return {
        'success': true,
        'data': result.data,
      };
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'E-fatura gönderme hatası: $e',
      };
    }
  }

  // Manuel abonelik yenileme
  static Future<Map<String, dynamic>> manualRenewal(String plan) async {
    try {
      final callable = _functions.httpsCallable('manualRenewal');
      final result = await callable.call({
        'plan': plan,
      });

      return {
        'success': true,
        'data': result.data,
      };
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'Manuel yenileme hatası: $e',
      };
    }
  }

  // Otomatik yenileme ayarlarını güncelle
  static Future<Map<String, dynamic>> updateAutoRenewalSettings({
    required bool autoRenewal,
    required Map<String, dynamic> paymentMethod,
  }) async {
    try {
      final callable = _functions.httpsCallable('updateAutoRenewalSettings');
      final result = await callable.call({
        'autoRenewal': autoRenewal,
        'paymentMethod': paymentMethod,
      });

      return {
        'success': true,
        'data': result.data,
      };
    } catch (e) {
      return {
        'success': false,
        'errorMessage': 'Otomatik yenileme ayarları güncelleme hatası: $e',
      };
    }
  }

  // İyizico Test Kartları
  static List<Map<String, String>> getTestCards() {
    return [
      {
        'name': 'Başarılı Ödeme (Visa)',
        'number': '5528790000000008',
        'month': '12',
        'year': '2030',
        'cvc': '123',
        'holder': 'Test User',
      },
      {
        'name': 'Başarılı Ödeme (Mastercard)',
        'number': '5555444433331111',
        'month': '12',
        'year': '2030',
        'cvc': '123',
        'holder': 'Test User',
      },
      {
        'name': 'Başarısız Ödeme',
        'number': '5528790000000016',
        'month': '12',
        'year': '2030',
        'cvc': '123',
        'holder': 'Test User',
      },
      {
        'name': '3D Secure Test',
        'number': '5528790000000024',
        'month': '12',
        'year': '2030',
        'cvc': '123',
        'holder': 'Test User',
      },
      {
        'name': 'Yetersiz Bakiye',
        'number': '5528790000000032',
        'month': '12',
        'year': '2030',
        'cvc': '123',
        'holder': 'Test User',
      },
    ];
  }
}
