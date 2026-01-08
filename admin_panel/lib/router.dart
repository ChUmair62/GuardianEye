import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/officers_page.dart';
import 'pages/suspects_page.dart';
import 'pages/interviews_page.dart';
import 'pages/splash_page.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          _buildPage(state, const LoginPage()),
    ),

    GoRoute(
     path: '/splash',
      pageBuilder: (context, state) =>
      _buildPage(state, const SplashPage()),
),


    GoRoute(
       path: '/dashboard',
       pageBuilder: (context, state) =>
      _buildPage(state, const DashboardPage()),
),


    GoRoute(
      path: '/officers',
      pageBuilder: (context, state) =>
          _buildPage(state, const OfficersPage()),
    ),

    GoRoute(
      path: '/suspects',
      pageBuilder: (context, state) =>
          _buildPage(state, const SuspectsPage()),
    ),

    GoRoute(
      path: '/interviews',
      pageBuilder: (context, state) =>
          _buildPage(state, const InterviewsPage()),
    ),
  ],
);

/// 🎬 UI-ONLY page transition
CustomTransitionPage _buildPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );

      final slide = Tween<Offset>(
        begin: const Offset(0.04, 0),
        end: Offset.zero,
      ).animate(fade);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: child,
        ),
      );
    },
  );
}
