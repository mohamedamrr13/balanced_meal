import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_state_providers.dart';

class ResetDataDialog extends StatelessWidget {
  const ResetDataDialog({super.key});

  void _handleReset(BuildContext context) {
    Navigator.of(context).pop();
    context.read<AppStateProvider>().resetUserData();
    context.push('/');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset All Data'),
      content: const Text(
        'This will delete all your saved data including meals and profile information. This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _handleReset(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
