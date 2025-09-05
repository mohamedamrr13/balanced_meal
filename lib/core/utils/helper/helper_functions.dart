import 'package:flutter/material.dart';

class HelperFunctions {
  static void showErrorSnackBar(
    String message,
    MessageType errorType,
    BuildContext context,
  ) {
    // Remove any existing snackbars first
    ScaffoldMessenger.of(context).clearSnackBars();

    // Determine icon and colors based on error type
    IconData icon;
    Color iconColor;
    Color backgroundColor;

    switch (errorType) {
      case MessageType.warning:
        icon = Icons.warning;
        iconColor = Colors.orange.shade700;
        backgroundColor = Colors.orange.shade50;
        break;
      case MessageType.error:
        icon = Icons.error;
        iconColor = Colors.red.shade700;
        backgroundColor = Colors.red.shade50;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14, color: iconColor),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        elevation: 4,
      ),
    );
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

enum MessageType { error, warning }
