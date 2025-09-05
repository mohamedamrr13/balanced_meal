import 'package:balanced_meal/features/auth/logic/google_cubit/google_cubit.dart';
import 'package:balanced_meal/features/auth/logic/login_cubit/login_cubit.dart';
import 'package:balanced_meal/features/auth/logic/register_cubit/register_cubit.dart';
import 'package:balanced_meal/features/auth/presentation/login_screen.dart';
import 'package:balanced_meal/features/auth/presentation/register_screen.dart';
import 'package:balanced_meal/features/home/presentation/home.dart';
import 'package:balanced_meal/features/onboarding/presentation/onboarding_page.dart';
import 'package:balanced_meal/features/order/presentation/create_order_page.dart';
import 'package:balanced_meal/features/order/presentation/saved_meals.dart';
import 'package:balanced_meal/features/user_details/presentation/user_details_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  // Route paths
  static const String onboardingRoute = '/';
  static const String loginRoute = '/login';
  static const String signUpRoute = '/signUp';
  static const String userDetailsRoute = '/user-details';
  static const String homeRoute = '/home';
  static const String createOrderRoute = '/create-order';
  static const String savedMealsRoute = '/saved-meals';

  // Route names (for better navigation)
  static const String onboardingName = 'onboarding';
  static const String loginName = 'login';
  static const String signUpName = 'signUp';
  static const String userDetailsName = 'user-details';
  static const String homeName = 'home';
  static const String createOrderName = 'create-order';
  static const String savedMealsName = 'saved-meals';

  static final GoRouter router = GoRouter(
    initialLocation: onboardingRoute,
    routes: [
      GoRoute(
        path: loginRoute,
        name: loginName,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => LoginCubit()),
            BlocProvider(create: (context) => GoogleCubit()),
          ],
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: signUpRoute,
        name: signUpName,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => RegisterCubit()),
            BlocProvider(create: (context) => GoogleCubit()),
          ],
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: onboardingRoute,
        name: onboardingName,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: userDetailsRoute,
        name: userDetailsName,
        builder: (context, state) => const UserDetailsPage(),
      ),
      GoRoute(
        path: homeRoute,
        name: homeName,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: createOrderRoute,
        name: createOrderName,
        builder: (context, state) => const CreateMealPage(),
      ),
      GoRoute(
        path: savedMealsRoute,
        name: savedMealsName,
        builder: (context, state) => const SavedMealsPage(),
      ),
    ],
  );
}
