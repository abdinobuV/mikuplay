import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

/// Semua nama route dikumpulkan di sini
/// agar tidak ada typo saat navigasi
class AppRoutes {
  AppRoutes._();

  static const String splash  = '/';
  static const String login   = '/login';
  static const String signup  = '/signup';
  static const String home    = '/home';
}

/// Router utama aplikasi menggunakan GoRouter
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true, // matikan saat release
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      // Transisi: fade masuk seperti di Figma prototype
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const LoginScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      // Transisi: slide dari bawah ke atas (sesuai Figma)
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const Scaffold(
          body: Center(child: Text('Home Screen — coming soon')),
        ),
        transitionsBuilder: (context, animation, _, child) {
          final tween = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ),
  ],
);