import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double? elevation;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.elevation,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
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
      end: 0.95,
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
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.isFullWidth ? double.infinity : widget.width,
              height: widget.height ?? 50,
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? const Color(0xFFB22B69),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: (widget.backgroundColor ?? const Color(0xFFB22B69)).withOpacity(0.3),
                    blurRadius: widget.elevation ?? 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.textColor ?? Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.textColor ?? Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              color: widget.textColor ?? Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isLoading;

  const FloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.isLoading = false,
  });

  @override
  State<FloatingActionButton> createState() => _FloatingActionButtonState();
}

class _FloatingActionButtonState extends State<FloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
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
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? const Color(0xFFB22B69),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.backgroundColor ?? const Color(0xFFB22B69)).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.iconColor ?? Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          widget.icon,
                          color: widget.iconColor ?? Colors.white,
                          size: 24,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class IconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const IconButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.padding,
    this.borderRadius,
  });

  @override
  State<IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<IconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
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
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size ?? 40,
              height: widget.size ?? 40,
              padding: widget.padding ?? const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.transparent,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: widget.iconColor ?? Colors.grey[600],
                  size: (widget.size ?? 40) * 0.6,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
