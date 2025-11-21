import 'package:flutter/material.dart';

class TermsPrivacyNotice extends StatelessWidget {
  const TermsPrivacyNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF959595),
              fontSize: 12,
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text: 'By creating an account, you agree to our ',
              ),
              TextSpan(
                text: 'Terms of Service',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
