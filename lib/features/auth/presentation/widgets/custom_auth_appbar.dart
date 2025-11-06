import 'package:flutter/material.dart';

class CustomAuthAppbar extends StatelessWidget {
  final String? title;
  final TextStyle? titleStyle;
  final double topPadding;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const CustomAuthAppbar({
    super.key,
    this.title,
    this.titleStyle,
    this.topPadding = 80,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        SizedBox(height: topPadding),

        Text(
          title ?? "Balanced Meal",
          style: titleStyle ??
              theme.textTheme.headlineLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 32,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        // Subtitle or tagline
        Text(
          "Healthy eating made simple",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF959595), // AppTheme.textSecondaryColor
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
