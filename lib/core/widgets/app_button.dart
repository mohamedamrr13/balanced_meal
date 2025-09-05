import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final IconData? icon;
  final bool useGradient;
  final List<Color>? gradientColors;
  final double borderRadius;
  final bool enableHapticFeedback;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.icon,
    this.useGradient = false,
    this.gradientColors,
    this.borderRadius = 16,
    this.enableHapticFeedback = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _resetAnimation();
  }

  void _onTapCancel() {
    _resetAnimation();
  }

  void _resetAnimation() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _handleTap() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: isDisabled ? null : _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: widget.width ?? double.infinity,
              height: widget.height ?? 60,
              decoration: BoxDecoration(
                gradient: !isDisabled && widget.useGradient
                    ? LinearGradient(
                        colors: widget.gradientColors ??
                            [
                              primaryColor,
                              primaryColor.withOpacity(0.8),
                            ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: !widget.useGradient
                    ? (isDisabled
                        ? const Color(0xFFEAECF0)
                        : widget.backgroundColor ?? primaryColor)
                    : null,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: isDisabled
                    ? null
                    : [
                        BoxShadow(
                          color: (widget.backgroundColor ?? primaryColor)
                              .withOpacity(_isPressed ? 0.2 : 0.3),
                          blurRadius: _isPressed ? 8 : 12,
                          offset: Offset(0, _isPressed ? 2 : 4),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: widget.isLoading
                      ? Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.textColor ?? Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: isDisabled
                                    ? const Color(0xFF959595)
                                    : widget.textColor ?? Colors.white,
                                size: (widget.fontSize ?? 16) + 2,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                widget.text,
                                style: TextStyle(
                                  fontSize: widget.fontSize ?? 16,
                                  fontWeight:
                                      widget.fontWeight ?? FontWeight.w600,
                                  color: isDisabled
                                      ? const Color(0xFF959595)
                                      : widget.textColor ?? Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
