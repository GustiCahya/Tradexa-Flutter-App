import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/trade/trade_form_screen.dart';
import '../screens/analytics/summary_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/overview',
  routes: [
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
