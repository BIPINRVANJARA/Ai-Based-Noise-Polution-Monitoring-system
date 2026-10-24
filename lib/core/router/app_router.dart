import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noiseguard/features/onboarding/screens/onboarding_screen.dart';
import 'package:noiseguard/features/auth/screens/login_screen.dart';
import 'package:noiseguard/features/auth/screens/register_screen.dart';
import 'package:noiseguard/features/auth/screens/forgot_password_screen.dart';
import 'package:noiseguard/features/dashboard/screens/dashboard_screen.dart';
import 'package:noiseguard/features/maps/screens/map_screen.dart';
import 'package:noiseguard/features/analytics/screens/analytics_screen.dart';
import 'package:noiseguard/features/alerts/screens/alerts_screen.dart';
import 'package:noiseguard/features/alerts/screens/alert_detail_screen.dart';
import 'package:noiseguard/features/devices/screens/devices_screen.dart';
import 'package:noiseguard/features/devices/screens/device_detail_screen.dart';
import 'package:noiseguard/features/reports/screens/reports_screen.dart';
import 'package:noiseguard/features/ai_summary/screens/ai_summary_screen.dart';
import 'package:noiseguard/features/settings/screens/settings_screen.dart';
import 'package:noiseguard/shared/widgets/app_bottom_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  redirect: (BuildContext context, GoRouterState state) async {
    User? currentUser;
    try {
      currentUser = FirebaseAuth.instance.currentUser;
    } catch (_) {
      currentUser = null;
    }

    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    final bool isGuestLoggedIn = prefs.getBool('is_guest_logged_in') ?? false;
    final bool isLoggedIn = (currentUser != null) || isGuestLoggedIn;

    final isGoingToOnboarding = state.matchedLocation == '/onboarding';
    final isGoingToAuth = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/forgot-password';

    // 1. If user is logged in, never show onboarding or login — go straight to dashboard
    if (isLoggedIn) {
      if (isGoingToOnboarding || isGoingToAuth) {
        return '/dashboard';
      }
      return null;
    }

    // 2. If first time opening app, show onboarding
    if (!hasSeenOnboarding && !isGoingToOnboarding) {
      return '/onboarding';
    }

    // 3. If returning user not logged in, go to login
    if (hasSeenOnboarding && !isLoggedIn && !isGoingToAuth) {
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1A),
          body: navigationShell,
          bottomNavigationBar: AppBottomNav(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/maps',
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/alerts',
              builder: (context, state) => const AlertsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/alert/:id',
      builder: (context, state) => AlertDetailScreen(
        id: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/devices',
      builder: (context, state) => const DevicesScreen(),
    ),
    GoRoute(
      path: '/device/:id',
      builder: (context, state) => DeviceDetailScreen(
        id: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/ai-summary',
      builder: (context, state) => const AiSummaryScreen(),
    ),
  ],
);
