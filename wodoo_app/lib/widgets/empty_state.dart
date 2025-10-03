import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;
  final Color? backgroundColor;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: (iconColor ?? const Color(0xFFB22B69)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    icon,
                    size: 50,
                    color: iconColor ?? const Color(0xFFB22B69),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Title with fade animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Description with slide animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 32),
            
            // Button with scale animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: ElevatedButton.icon(
                    onPressed: onButtonPressed,
                    icon: const Icon(Icons.add),
                    label: Text(buttonText!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB22B69),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingEmptyState extends StatelessWidget {
  final String title;
  final String description;

  const LoadingEmptyState({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing loading animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB22B69).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB22B69)),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
