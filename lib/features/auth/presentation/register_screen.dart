import 'package:balanced_meal/core/routes/app_router.dart';
import 'package:balanced_meal/core/utils/helper/helper_functions.dart';
import 'package:balanced_meal/core/utils/text_validation.dart';
import 'package:balanced_meal/core/widgets/app_button.dart';
import 'package:balanced_meal/core/widgets/app_textfield.dart';
import 'package:balanced_meal/features/auth/logic/google_cubit/google_cubit.dart';
import 'package:balanced_meal/features/auth/logic/register_cubit/register_cubit.dart';
import 'package:balanced_meal/features/auth/presentation/widgets/custom_auth_appbar.dart';
import 'package:balanced_meal/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:balanced_meal/features/auth/presentation/widgets/auth_divider.dart';
import 'package:balanced_meal/features/auth/presentation/widgets/auth_navigation_link.dart';
import 'package:balanced_meal/features/auth/presentation/widgets/terms_privacy_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isEnabled = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const CustomAuthAppbar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Container(
                    constraints:
                        const BoxConstraints(maxWidth: double.infinity),
                    child: Form(
                      key: _formKey,
                      child: BlocConsumer<RegisterCubit, RegisterState>(
                        listener: (context, state) {
                          if (state is RegisterLoading) {
                            setState(() => isEnabled = false);
                          }
                          if (state is RegisterSuccess) {
                            context.go(AppRouter.onboardingRoute);
                          }
                          if (state is RegisterFailure) {
                            setState(() => isEnabled = true);
                            HelperFunctions.showErrorSnackBar(
                              state.errMessage,
                              MessageType.error,
                              context,
                            );
                          }
                        },
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppTextField(
                                enabled: isEnabled,
                                controller: _nameController,
                                hintText: 'Full name',
                                keyboardType: TextInputType.name,
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: Color(0xFF959595),
                                  size: 20,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              AppTextField(
                                enabled: isEnabled,
                                controller: _emailController,
                                hintText: 'Email address',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF959595),
                                  size: 20,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your email";
                                  }
                                  return TextValidation.emailValidator(value);
                                },
                              ),
                              const SizedBox(height: 20),
                              AppTextField(
                                enabled: isEnabled,
                                controller: _passwordController,
                                hintText: 'Password',
                                obscureText: true,
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF959595),
                                  size: 20,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a password";
                                  }
                                  return TextValidation.passwordValidator(
                                      value);
                                },
                              ),
                              const SizedBox(height: 20),
                              AppTextField(
                                enabled: isEnabled,
                                controller: _confirmPasswordController,
                                hintText: 'Confirm password',
                                obscureText: true,
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF959595),
                                  size: 20,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),
                              AppButton(
                                onPressed: isEnabled
                                    ? () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<RegisterCubit>().signIn(
                                                _emailController.text.trim(),
                                                _passwordController.text,
                                              );
                                        }
                                      }
                                    : null,
                                text: 'Create Account',
                                isLoading: state is RegisterLoading,
                              ),
                              const SizedBox(height: 16),
                              const AuthDivider(),
                              const SizedBox(height: 16),
                              BlocConsumer<GoogleCubit, GoogleState>(
                                listener: (context, state) {
                                  if (state is GoogleLoading) {
                                    setState(() => isEnabled = false);
                                  }
                                  if (state is GoogleSuccess) {
                                    setState(() => isEnabled = true);
                                    context.go(AppRouter.userDetailsRoute);
                                  }
                                  if (state is GoogleFailure) {
                                    setState(() => isEnabled = true);
                                    HelperFunctions.showErrorSnackBar(
                                      state.errMessage,
                                      MessageType.error,
                                      context,
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return GoogleSignButton(
                                    onPressed: isEnabled
                                        ? () async {
                                            await context
                                                .read<GoogleCubit>()
                                                .signUpWithGoogle();
                                          }
                                        : null,
                                    text: 'Continue with Google',
                                    isLoading: state is GoogleLoading,
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              const TermsPrivacyNotice(),
                              const SizedBox(height: 32),
                              AuthNavigationLink(
                                question: "Already have an account? ",
                                actionText: 'Sign In',
                                route: AppRouter.loginRoute,
                              ),
                              const SizedBox(height: 40),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
