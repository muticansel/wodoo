import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../services/subscription_service.dart';

class PaymentScreen extends StatefulWidget {
  final String subscriptionPlan;
  final double amount;
  final String currency;

  const PaymentScreen({
    super.key,
    required this.subscriptionPlan,
    required this.amount,
    required this.currency,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvcController = TextEditingController();
  final _cardHolderController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Test kartı bilgilerini doldur
    _cardNumberController.text = '5528790000000008';
    _expiryMonthController.text = '12';
    _expiryYearController.text = '2030';
    _cvcController.text = '123';
    _cardHolderController.text = 'Test User';
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvcController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Kart bilgilerini hazırla
      final cardInfo = {
        'cardHolderName': _cardHolderController.text,
        'cardNumber': _cardNumberController.text,
        'expireMonth': _expiryMonthController.text,
        'expireYear': _expiryYearController.text,
        'cvc': _cvcController.text,
      };

      // Alıcı bilgilerini hazırla (Firebase Auth'dan alınacak)
      final buyerInfo = {
        'name': 'Test',
        'surname': 'User',
        'email': 'test@example.com',
        'identityNumber': '11111111111',
        'address': 'Test Address',
        'city': 'Istanbul',
        'zipCode': '34000',
        'ip': '127.0.0.1',
      };

      final result = await PaymentService.initiatePayment(
        userId: 'current_user_id', // Firebase Auth'dan alınacak
        subscriptionPlan: widget.subscriptionPlan,
        amount: widget.amount,
        currency: widget.currency,
        cardInfo: cardInfo,
        buyerInfo: buyerInfo,
      );

      if (result['success']) {
        // Başarılı ödeme
        await _handleSuccessfulPayment(result['paymentId']);
      } else {
        setState(() {
          _errorMessage = result['errorMessage'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ödeme işlemi sırasında hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSuccessfulPayment(String paymentId) async {
    // Abonelik oluştur
    await SubscriptionService.createSubscription(
      userId: 'current_user_id',
      plan: widget.subscriptionPlan,
      paymentId: paymentId,
    );

    if (mounted) {
      Navigator.of(context).pop(true); // Başarılı ödeme ile geri dön
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text(
          'Ödeme',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB22B69),
                Color(0xFF2889B8),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ödeme Özeti
              _buildPaymentSummary(),
              const SizedBox(height: 24),
              
              // Kart Bilgileri
              _buildCardInfo(),
              const SizedBox(height: 24),
              
              // Hata Mesajı
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              
              // Ödeme Butonu
              _buildPaymentButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB22B69),
            Color(0xFF2889B8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB22B69).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ödeme Özeti',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Plan:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.subscriptionPlan,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tutar:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kart Bilgileri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          
          // Kart Numarası
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Kart Numarası',
              hintText: '1234 5678 9012 3456',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kart numarası gerekli';
              }
              if (value.length < 16) {
                return 'Geçerli bir kart numarası girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Kart Sahibi
          TextFormField(
            controller: _cardHolderController,
            decoration: const InputDecoration(
              labelText: 'Kart Sahibi',
              hintText: 'Ad Soyad',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kart sahibi adı gerekli';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Son Kullanma Tarihi ve CVC
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryMonthController,
                  decoration: const InputDecoration(
                    labelText: 'Ay',
                    hintText: 'MM',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ay gerekli';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _expiryYearController,
                  decoration: const InputDecoration(
                    labelText: 'Yıl',
                    hintText: 'YYYY',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Yıl gerekli';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvcController,
                  decoration: const InputDecoration(
                    labelText: 'CVC',
                    hintText: '123',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'CVC gerekli';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB22B69),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Text(
                'Ödemeyi Tamamla',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
