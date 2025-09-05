import 'package:flutter/material.dart';

class GoogleSignButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final double? width;
  final double? height;
  final double borderRadius;
  final Widget? customIcon;

  const GoogleSignButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 60,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              )
            : customIcon ??
                Image.asset(
                  'assets/icons/IconGoogle.png',
                  height: 20,
                  width: 20,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback icon with Google colors
                    return Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4285F4), // Google Blue
                            Color(0xFF34A853), // Google Green
                            Color(0xFFFBBC05), // Google Yellow
                            Color(0xFFEA4335), // Google Red
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.g_mobiledata,
                        color: Colors.white,
                        size: 16,
                      ),
                    );
                  },
                ),
        label: isLoading
            ? const SizedBox.shrink()
            : Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: onPressed != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
        style: OutlinedButton.styleFrom(
          backgroundColor: onPressed != null
              ? colorScheme.surface
              : colorScheme.surface.withOpacity(0.5),
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(
            width: 2,
            color: onPressed != null
                ? const Color(0xFFEAECF0) // AppTheme.borderColor
                : const Color(0xFFEAECF0).withOpacity(0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
          overlayColor: colorScheme.primary.withOpacity(0.08),
        ),
      ),
    );
  }
}

// Extension for easy theme access (optional - add to a separate theme_extensions.dart file)
extension ThemeExtensions on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Direct access to your app's colors
  Color get primaryColor => const Color(0xFFF25700);
  Color get secondaryColor => const Color(0xFF4B39EF);
  Color get backgroundColor => const Color(0xFFFBFBFB);
  Color get surfaceColor => Colors.white;
  Color get textPrimaryColor => Colors.black;
  Color get textSecondaryColor => const Color(0xFF959595);
  Color get borderColor => const Color(0xFFEAECF0);
}
