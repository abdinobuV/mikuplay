// ============================================================
// FILE INI DISIMPAN DI:
// lib/core/router/app_router.dart
// GANTI SELURUH ISI FILE LAMA
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/signup_step1_screen.dart';
import '../../features/auth/presentation/screens/signup_step2_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../shared/widgets/animated_bottom_nav.dart';
import '../../shared/widgets/mini_player.dart';
import '../animations/page_transitions.dart';

class Routes {
  Routes._();
  static const String splash         = '/';
  static const String onboarding     = '/onboarding';
  static const String login          = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String signupStep1    = '/signup/step1';
  static const String signupStep2    = '/signup/step2';
  static const String home           = '/home';
  static const String search         = '/search';
  static const String library        = '/library';
  static const String profile        = '/profile';
}

/// Adapter untuk GoRouterState agar bisa digunakan di page_transitions.dart
class _GoRouterAdapter implements GoRouterStateAdapter {
  final GoRouterState state;
  _GoRouterAdapter(this.state);
  @override
  ValueKey<String> get pageKey => state.pageKey;
}

// ── Shell nav key ────────────────────────────────────────────
final _shellNavKey = GlobalKey<NavigatorState>();

// ── Router ───────────────────────────────────────────────────
final GoRouter appRouter = GoRouter(
  initialLocation: Routes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: Routes.splash,
        pageBuilder: (_, s) => MikuTransitions.scaleUp(child: const SplashScreen(), state: _GoRouterAdapter(s))),
    GoRoute(path: Routes.onboarding,
        pageBuilder: (_, s) => MikuTransitions.fade(child: const OnboardingScreen(), state: _GoRouterAdapter(s))),
    GoRoute(path: Routes.login,
        pageBuilder: (_, s) => MikuTransitions.slideUp(child: const LoginScreen(), state: _GoRouterAdapter(s))),
    GoRoute(path: Routes.forgotPassword,
        pageBuilder: (_, s) => MikuTransitions.slideRight(child: const ForgotPasswordScreen(), state: _GoRouterAdapter(s))),
    GoRoute(path: Routes.signupStep1,
        pageBuilder: (_, s) => MikuTransitions.slideRight(child: const SignupStep1Screen(), state: _GoRouterAdapter(s))),
    GoRoute(path: Routes.signupStep2,
        pageBuilder: (_, s) => MikuTransitions.slideRight(child: const SignupStep2Screen(), state: _GoRouterAdapter(s))),

    ShellRoute(
      navigatorKey: _shellNavKey,
      builder: (context, state, child) {
        int tab = 0;
        final loc = state.uri.toString();
        if (loc.startsWith(Routes.search))  tab = 1;
        if (loc.startsWith(Routes.library)) tab = 2;
        if (loc.startsWith(Routes.profile)) tab = 3;
        return _MainShell(activeTab: tab, child: child,
          onNavTap: (i) {
            switch (i) {
              case 0: context.go(Routes.home);    break;
              case 1: context.go(Routes.search);  break;
              case 2: context.go(Routes.library); break;
              case 3: context.go(Routes.profile); break;
            }
          },
        );
      },
      routes: [
        GoRoute(path: Routes.home,
            pageBuilder: (_, s) => MikuTransitions.slideUp(child: const HomeScreen(), state: _GoRouterAdapter(s))),
        GoRoute(path: Routes.search,
            pageBuilder: (_, s) => MikuTransitions.fade(child: const SearchScreen(), state: _GoRouterAdapter(s))),
        GoRoute(path: Routes.library,
            pageBuilder: (_, s) => MikuTransitions.fade(child: const LibraryScreen(), state: _GoRouterAdapter(s))),
        GoRoute(path: Routes.profile,
            pageBuilder: (_, s) => MikuTransitions.fade(child: const ProfileScreen(), state: _GoRouterAdapter(s))),
      ],
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    backgroundColor: const Color(0xFF03045E),
    body: Center(child: Text('Not found: ${state.uri}',
        style: const TextStyle(color: Colors.white))),
  ),
);

class _MainShell extends StatelessWidget {
  final int activeTab;
  final Widget child;
  final ValueChanged<int> onNavTap;
  const _MainShell({required this.activeTab, required this.child,
    required this.onNavTap});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF03045E),
    body: child,
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Mini Player (Tanpa Melayang/Gantung) ──────────
        // Hanya muncul jika di tab Home (Index 0)
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: activeTab == 0
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: MiniPlayer(onTap: () {}),
                )
              : const SizedBox.shrink(),
        ),
        // ── Navigation Bar ─────────────────────────────────
        AnimatedBottomNav(
            selectedIndex: activeTab, onTap: onNavTap),
      ],
    ),
  );
}