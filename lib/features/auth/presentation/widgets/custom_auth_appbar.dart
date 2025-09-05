import 'package:balanced_meal/core/routes/app_router.dart';
import 'package:balanced_meal/core/utils/helper/helper_functions.dart';
import 'package:balanced_meal/core/utils/text_validation.dart';
import 'package:balanced_meal/core/widgets/app_button.dart';
import 'package:balanced_meal/core/widgets/app_textfield.dart';
import 'package:balanced_meal/features/auth/logic/google_cubit/google_cubit.dart';
import 'package:balanced_meal/features/auth/logic/login_cubit/login_cubit.dart';
import 'package:balanced_meal/features/auth/logic/register_cubit/register_cubit.dart';
import 'package:balanced_meal/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

    return Container(
      color: colorScheme.surface,
      child: Column(
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
      ),
    );
  }
}
