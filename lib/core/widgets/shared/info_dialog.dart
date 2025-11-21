import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final IconData? icon;
  final Color? iconColor;

  const InfoDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: icon != null
          ? Icon(icon, size: 48, color: iconColor ?? theme.colorScheme.primary)
          : null,
      title: Text(title),
      content: SingleChildScrollView(child: content),
      actions: actions ??
          [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget>? actions,
    IconData? icon,
    Color? iconColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => InfoDialog(
        title: title,
        content: content,
        actions: actions,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }
}
