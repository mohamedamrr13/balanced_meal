import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthNavigationLink extends StatelessWidget {
  final String question;
  final String actionText;
  final String route;

  const AuthNavigationLink({
    super.key,
    required this.question,
    required this.actionText,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            question,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF959595),
            ),
          ),
          TextButton(
            onPressed: () => context.go(route),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
