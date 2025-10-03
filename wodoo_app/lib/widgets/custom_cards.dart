import 'package:flutter/material.dart';

class CustomCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? elevation;
  final Color? shadowColor;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? borderColor;
  final double? borderWidth;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.shadowColor,
    this.onTap,
    this.isSelected = false,
    this.borderColor,
    this.borderWidth,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2,
      end: (widget.elevation ?? 2) + 4,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: widget.margin,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                border: widget.isSelected || widget.borderColor != null
                    ? Border.all(
                        color: widget.borderColor ?? const Color(0xFFB22B69),
                        width: widget.borderWidth ?? 2,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: (widget.shadowColor ?? Colors.grey).withOpacity(0.1),
                    blurRadius: _elevationAnimation.value,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(16),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? elevation;
  final Color? shadowColor;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.shadowColor,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOut,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomCard(
              padding: widget.padding,
              margin: widget.margin,
              backgroundColor: widget.backgroundColor,
              borderRadius: widget.borderRadius,
              elevation: widget.elevation,
              shadowColor: widget.shadowColor,
              onTap: widget.onTap,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class GradientCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<Color>? gradientColors;
  final double? borderRadius;
  final double? elevation;
  final Color? shadowColor;
  final VoidCallback? onTap;
  final AlignmentGeometry? gradientBegin;
  final AlignmentGeometry? gradientEnd;

  const GradientCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.gradientColors,
    this.borderRadius,
    this.elevation,
    this.shadowColor,
    this.onTap,
    this.gradientBegin,
    this.gradientEnd,
  });

  @override
  State<GradientCard> createState() => _GradientCardState();
}

class _GradientCardState extends State<GradientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: widget.margin,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradientColors ?? [
                    const Color(0xFFB22B69),
                    const Color(0xFF2889B8),
                  ],
                  begin: widget.gradientBegin ?? Alignment.topLeft,
                  end: widget.gradientEnd ?? Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                boxShadow: [
                  BoxShadow(
                    color: (widget.shadowColor ?? Colors.grey).withOpacity(0.2),
                    blurRadius: widget.elevation ?? 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(16),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
