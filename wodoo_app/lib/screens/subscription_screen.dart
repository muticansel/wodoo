import 'package:flutter/material.dart';
import '../models/subscription_model.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
        leading: Container(
          margin: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          'Abonelik Planları',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Abonelik Planını Seçin',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Size en uygun planı seçerek antrenman programlarına erişim sağlayın.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Subscription Plans
            ...SubscriptionPlan.plans.map((plan) => _buildPlanCard(context, plan)),
            
            const SizedBox(height: 32),
            
            // Subscribe Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedPlanId != null ? _handleSubscribe : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Abonelik Satın Al',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Terms and Conditions
            Text(
              'Abonelik satın alarak kullanım şartlarını kabul etmiş olursunuz.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan) {
    final isSelected = _selectedPlanId == plan.id;
    final isPopular = plan.id == 'yearly';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: isSelected ? 4 : 1,
        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPlanId = plan.id;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                plan.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isPopular) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Popüler',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.description,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: plan.id,
                      groupValue: _selectedPlanId,
                      onChanged: (value) {
                        setState(() {
                          _selectedPlanId = value;
                        });
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₺${plan.price.toInt()}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      plan.currency,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (plan.monthlyPrice != plan.price) ...[
                      Text(
                        '₺${plan.monthlyPrice.toStringAsFixed(1)}/ay',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Features
                Column(
                  children: [
                    _buildFeatureItem('Haftalık antrenman programları'),
                    _buildFeatureItem('Detaylı egzersiz açıklamaları'),
                    _buildFeatureItem('Antrenman geçmişi takibi'),
                    _buildFeatureItem('Bildirim desteği'),
                    _buildFeatureItem('Çoklu dil desteği'),
                    if (isPopular) ...[
                      _buildFeatureItem('Öncelikli müşteri desteği', isHighlighted: true),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: isHighlighted ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isHighlighted ? Colors.orange : Colors.grey[700],
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubscribe() {
    if (_selectedPlanId == null) return;
    
    final selectedPlan = SubscriptionPlan.plans.firstWhere(
      (plan) => plan.id == _selectedPlanId,
    );
    
    // Show payment dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödeme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Seçilen Plan: ${selectedPlan.name}'),
            const SizedBox(height: 8),
            Text('Tutar: ₺${selectedPlan.price.toInt()}'),
            const SizedBox(height: 16),
            const Text('Ödeme işlemi burada gerçekleştirilecek.'),
            const Text('(İyizico entegrasyonu eklenecek)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processPayment(selectedPlan);
            },
            child: const Text('Ödeme Yap'),
          ),
        ],
      ),
    );
  }

  void _processPayment(SubscriptionPlan plan) {
    // TODO: Implement İyizico payment integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${plan.name} planı için ödeme işlemi başlatıldı'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

