import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    Color backgroundColor;
    IconData defaultIcon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green;
        defaultIcon = Icons.check_circle;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red;
        defaultIcon = Icons.error;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange;
        defaultIcon = Icons.warning;
        break;
      case SnackBarType.info:
        backgroundColor = theme.colorScheme.primary;
        defaultIcon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon ?? defaultIcon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
