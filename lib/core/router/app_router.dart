// ============================================================
// FILE INI DISIMPAN DI:
// lib/core/router/app_router.dart
//
// GANTI SELURUH ISI FILE LAMA DENGAN KODE INI
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

// ── Semua nama route ─────────────────────────────────────────
class Routes {
  Routes._();

  static const String splash         = '/';
  static const String onboarding     = '/onboarding';
  static const String login          = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String signupStep1    = '/signup/step1';
  static const String signupStep2    = '/signup/step2';
  static const String home           = '/home';
}

// ── Jenis transisi ───────────────────────────────────────────

/// Fade (untuk splash → onboarding, login → home)
CustomTransitionPage<T> _fadePage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 450),
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// Slide dari kanan (untuk push: login → signup, back → forgot password)
CustomTransitionPage<T> _slidePage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

/// Slide dari bawah (untuk login/signup → home)
CustomTransitionPage<T> _slideUpPage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

// ── Router utama ─────────────────────────────────────────────
final GoRouter appRouter = GoRouter(
  initialLocation: Routes.splash,
  debugLogDiagnostics: true, // matikan saat build release

  routes: [
    // 1. Splash — auto-navigate ke onboarding setelah 2.8 detik
    GoRoute(
      path: Routes.splash,
      pageBuilder: (context, state) =>
          _fadePage(const SplashScreen(), state),
    ),

    // 2. Onboarding — 3 halaman dengan PageView
    GoRoute(
      path: Routes.onboarding,
      pageBuilder: (context, state) =>
          _fadePage(const OnboardingScreen(), state),
    ),

    // 3. Login
    GoRoute(
      path: Routes.login,
      pageBuilder: (context, state) =>
          _fadePage(const LoginScreen(), state),
    ),

    // 4. Forgot Password
    GoRoute(
      path: Routes.forgotPassword,
      pageBuilder: (context, state) =>
          _slidePage(const ForgotPasswordScreen(), state),
    ),

    // 5. Sign Up Step 1
    GoRoute(
      path: Routes.signupStep1,
      pageBuilder: (context, state) =>
          _slidePage(const SignupStep1Screen(), state),
    ),

    // 6. Sign Up Step 2
    GoRoute(
      path: Routes.signupStep2,
      pageBuilder: (context, state) =>
          _slidePage(const SignupStep2Screen(), state),
    ),

    // 7. Home
    GoRoute(
      path: Routes.home,
      pageBuilder: (context, state) =>
          _slideUpPage(const HomeScreen(), state),
    ),
  ],

  // Error page jika route tidak ditemukan
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF03045E),
    body: Center(
      child: Text(
        'Page not found: ${state.uri}',
        style: const TextStyle(color: Colors.white),
      ),
    ),
  ),
);