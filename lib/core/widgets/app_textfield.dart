import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? suffixText;
  final bool obscureText;
  final int? maxLines;
  final Function(String)? onChanged;
  final bool enabled;
  final bool useFloatingLabel;
  final double borderRadius;
  final Color? fillColor;
  final bool showCharacterCounter;
  final int? maxLength;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.suffixIcon,
    this.prefixIcon,
    this.suffixText,
    this.obscureText = false,
    this.maxLines = 1,
    this.onChanged,
    this.enabled = true,
    this.useFloatingLabel = false,
    this.borderRadius = 12,
    this.fillColor,
    this.showCharacterCounter = false,
    this.maxLength,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;

  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Initialize theme-dependent animations here with theme-aware colors
    _borderColorAnimation = ColorTween(
      begin: isDark ? theme.colorScheme.outline : theme.colorScheme.outline.withOpacity(0.5),
      end: theme.colorScheme.primary,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.removeListener(_onFocusChange);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    final shouldShowFloatingLabel =
        widget.useFloatingLabel && (hasText || _isFocused);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && !widget.useFloatingLabel) ...[
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: _isFocused
                  ? theme.colorScheme.primary
                  : (_hasError
                      ? theme.colorScheme.error
                      : theme.textTheme.bodyMedium?.color),
            ),
            child: Text(widget.label!),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: _isFocused && !_hasError
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: widget.controller,
                    focusNode: _focusNode,
                    validator: (value) {
                      final error = widget.validator?.call(value);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _hasError = error != null;
                          });
                        }
                      });
                      return error;
                    },
                    keyboardType: widget.keyboardType,
                    inputFormatters: widget.inputFormatters,
                    obscureText: widget.obscureText,
                    maxLines: widget.maxLines,
                    maxLength: widget.maxLength,
                    onChanged: widget.onChanged,
                    enabled: widget.enabled,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.useFloatingLabel
                          ? (shouldShowFloatingLabel
                              ? null
                              : widget.label ?? widget.hintText)
                          : widget.hintText,
                      hintStyle: TextStyle(
                        color: theme.hintColor,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: widget.prefixIcon != null
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: widget.prefixIcon,
                            )
                          : null,
                      suffixIcon: widget.suffixIcon,
                      suffixText: widget.suffixText,
                      suffixStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: widget.fillColor ??
                          (widget.enabled
                              ? (_isFocused
                                  ? theme.colorScheme.primary.withOpacity(0.05)
                                  : (isDark
                                      ? theme.colorScheme.surfaceContainerHighest
                                      : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)))
                              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3)),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: widget.prefixIcon != null ? 12 : 16,
                        vertical: widget.maxLines == 1 ? 16 : 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(
                          color: _borderColorAnimation.value ??
                              theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(
                          color: theme.colorScheme.error.withOpacity(0.7),
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(
                          color: theme.colorScheme.error,
                          width: 2,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      counterText: widget.showCharacterCounter ? null : '',
                      errorStyle: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Floating label
                  if (widget.useFloatingLabel && widget.label != null)
                    Positioned(
                      left: widget.prefixIcon != null ? 48 : 16,
                      top: shouldShowFloatingLabel ? -8 : 16,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: shouldShowFloatingLabel ? 0.8 : 1.0,
                        alignment: Alignment.centerLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: shouldShowFloatingLabel
                              ? const EdgeInsets.symmetric(horizontal: 4)
                              : EdgeInsets.zero,
                          decoration: shouldShowFloatingLabel
                              ? BoxDecoration(
                                  color: widget.fillColor ??
                                      (theme.scaffoldBackgroundColor),
                                  borderRadius: BorderRadius.circular(4),
                                )
                              : null,
                          child: Text(
                            widget.label!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: shouldShowFloatingLabel
                                  ? (_hasError
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.primary)
                                  : theme.hintColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        // Character counter
        if (widget.showCharacterCounter && widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: (widget.controller?.text.length ?? 0) >
                            widget.maxLength!
                        ? theme.colorScheme.error
                        : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
