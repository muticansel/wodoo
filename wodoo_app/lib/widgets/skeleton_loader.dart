import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

class ProgramCardSkeleton extends StatelessWidget {
  const ProgramCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoader(
                width: 50,
                height: 50,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(
                      width: double.infinity,
                      height: 20,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    const SizedBox(height: 8),
                    const SkeletonLoader(
                      width: 200,
                      height: 14,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MainLiftCardSkeleton extends StatelessWidget {
  const MainLiftCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const SkeletonLoader(
            width: 50,
            height: 50,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(
                  width: 150,
                  height: 18,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                const SizedBox(height: 4),
                const SkeletonLoader(
                  width: 100,
                  height: 14,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
          ),
          const SkeletonLoader(
            width: 80,
            height: 40,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ],
      ),
    );
  }
}
