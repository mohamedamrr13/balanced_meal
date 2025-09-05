import 'package:balanced_meal/core/routes/app_router.dart';
import 'package:balanced_meal/core/utils/helper/helper_functions.dart';
import 'package:balanced_meal/core/utils/text_validation.dart';
import 'package:balanced_meal/core/widgets/app_button.dart';
import 'package:balanced_meal/core/widgets/app_textfield.dart';
import 'package:balanced_meal/features/auth/logic/google_cubit/google_cubit.dart';
import 'package:balanced_meal/features/auth/logic/login_cubit/login_cubit.dart';
import 'package:balanced_meal/features/auth/presentation/widgets/custom_auth_appbar.dart';
import 'package:balanced_meal/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isEnabled = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
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
                  // Welcome back section
                  Text(
                    'Welcome Back!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      color: theme.colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your healthy eating journey',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF959595),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    constraints:
                        const BoxConstraints(maxWidth: double.infinity),
                    child: Form(
                      key: _formKey,
                      child: BlocConsumer<LoginCubit, LoginState>(
                        listener: (context, state) {
                          if (state is LoginLoading) {
                            setState(() => isEnabled = false);
                          }
                          if (state is LoginSuccess) {
                            context.go(AppRouter.userDetailsRoute);
                          }
                          if (state is LoginFailure) {
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
                                controller: _emailController,
                                hintText: 'Email address',
                                keyboardType: TextInputType.emailAddress,
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your password";
                                  }
                                  return TextValidation.passwordValidator(
                                      value);
                                },
                              ),

                              // Forgot password link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Implement forgot password
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),
                              AppButton(
                                onPressed: isEnabled
                                    ? () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<LoginCubit>().login(
                                                _emailController.text.trim(),
                                                _passwordController.text,
                                              );
                                        }
                                      }
                                    : null,
                                text: 'Sign In',
                                isLoading: state is LoginLoading,
                              ),

                              const SizedBox(height: 24),

                              // Divider
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      'OR',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF959595),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),

                              const SizedBox(height: 24),

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

                              const SizedBox(height: 32),

                              // Sign up link
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF959595),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.go(AppRouter.signUpRoute);
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Sign Up',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),
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
