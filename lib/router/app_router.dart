import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/trade/trade_form_screen.dart';
import '../screens/analytics/summary_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/overview',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.getString('auth_token') != null;

    final isAuthRoute =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }

    if (isAuthenticated && isAuthRoute) {
      return '/overview';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/overview',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/trade-input',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'];
        return TradeFormScreen(tradeId: id);
      },
    ),
    GoRoute(
      path: '/summary',
      builder: (context, state) => const SummaryScreen(),
    ),
  ],
);
