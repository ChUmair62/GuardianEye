import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/officers_page.dart';
import 'pages/suspects_page.dart';
import 'pages/interviews_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardPage(),
    ),

    GoRoute(
      path: '/officers',
      builder: (context, state) => const OfficersPage(),
    ),

    GoRoute(
      path: '/suspects',
      builder: (context, state) => const SuspectsPage(),
    ),

    GoRoute(
      path: '/interviews',
      builder: (context, state) => const InterviewsPage(),
    ),
  ],
);
