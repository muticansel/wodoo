import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final Color? borderColor;
  final Color? focusColor;
  final double? borderRadius;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.borderColor,
    this.focusColor,
    this.borderRadius,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null) ...[
                Text(
                  widget.label!,
                  style: TextStyle(
                    color: _isFocused 
                        ? (widget.focusColor ?? const Color(0xFFB22B69))
                        : Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                validator: widget.validator,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                enabled: widget.enabled,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  filled: true,
                  fillColor: widget.enabled 
                      ? Colors.grey[50] 
                      : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                    borderSide: BorderSide(
                      color: widget.borderColor ?? Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                    borderSide: BorderSide(
                      color: widget.borderColor ?? Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                    borderSide: BorderSide(
                      color: widget.focusColor ?? const Color(0xFFB22B69),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SearchField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;

  const SearchField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            enabled: widget.enabled,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint ?? 'Ara...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              prefixIcon: widget.prefixIcon ?? Icon(
                Icons.search,
                color: _isFocused 
                    ? const Color(0xFFB22B69)
                    : Colors.grey[400],
              ),
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: widget.enabled 
                  ? Colors.grey[50] 
                  : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(
                  color: Color(0xFFB22B69),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
