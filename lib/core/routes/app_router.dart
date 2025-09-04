import 'package:balanced_meal/features/cart/presentation/cart_page.dart';
import 'package:balanced_meal/features/onboarding/presentation/onboarding_page.dart';
import 'package:balanced_meal/features/order/presentation/create_order_page.dart';
import 'package:balanced_meal/features/user_details/presentation/user_details_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/user-details',
        name: 'user-details',
        builder: (context, state) => const UserDetailsPage(),
      ),
      GoRoute(
        path: '/create-order',
        name: 'create-order',
        builder: (context, state) => const CreateOrderPage(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),
    ],
  );
}
