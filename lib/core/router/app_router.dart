// ============================================================
// FILE INI DISIMPAN DI:
// lib/core/router/app_router.dart
// GANTI SELURUH ISI FILE LAMA
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/firestore_service.dart';
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

// ── Route constants ──────────────────────────────────────────
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

// ── Durasi transisi ──────────────────────────────────────────
const _fast   = Duration(milliseconds: 280);
const _normal = Duration(milliseconds: 370);
const _slow   = Duration(milliseconds: 460);
const _curve  = Curves.fastOutSlowIn;
const _decel  = Curves.decelerate;

// ── Transition builders ───────────────────────────────────────

// Fade — tab switch
CustomTransitionPage<T> _fade<T>(Widget child, GoRouterState s) =>
    CustomTransitionPage<T>(
      key: s.pageKey,
      child: child,
      transitionDuration: _fast,
      reverseTransitionDuration: _fast,
      transitionsBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(
            parent: anim,
            curve: const Interval(0, 1, curve: Curves.easeIn)),
        child: child,
      ),
    );

// Slide right — drill-down
CustomTransitionPage<T> _slideRight<T>(Widget child, GoRouterState s) =>
    CustomTransitionPage<T>(
      key: s.pageKey,
      child: child,
      transitionDuration: _normal,
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, anim, __, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1, 0), end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: _curve));
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: anim,
              curve: const Interval(0, 0.5, curve: Curves.easeIn)),
        );
        return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child));
      },
    );

// Scale + Fade — splash → onboarding
CustomTransitionPage<T> _scaleFade<T>(Widget child, GoRouterState s) =>
    CustomTransitionPage<T>(
      key: s.pageKey,
      child: child,
      transitionDuration: _slow,
      reverseTransitionDuration: _fast,
      transitionsBuilder: (_, anim, __, child) {
        final scale = Tween<double>(begin: 0.96, end: 1.0)
            .animate(CurvedAnimation(parent: anim, curve: _decel));
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: anim,
              curve: const Interval(0, 0.75, curve: Curves.easeIn)),
        );
        return FadeTransition(
            opacity: fade,
            child: ScaleTransition(scale: scale, child: child));
      },
    );

// Slide Up — login → home
CustomTransitionPage<T> _slideUp<T>(Widget child, GoRouterState s) =>
    CustomTransitionPage<T>(
      key: s.pageKey,
      child: child,
      transitionDuration: _slow,
      reverseTransitionDuration: _normal,
      transitionsBuilder: (_, anim, __, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.06), end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: _decel));
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: anim,
              curve: const Interval(0, 0.65, curve: Curves.easeIn)),
        );
        return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child));
      },
    );

// ── Shell navigator key ───────────────────────────────────────
final _shellNavKey = GlobalKey<NavigatorState>();

// ── Listenable: dengarkan perubahan auth state ────────────────
final _authListenable = _AuthListenable();

class _AuthListenable extends ChangeNotifier {
  _AuthListenable() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}

// ══════════════════════════════════════════════════════════════
// APP ROUTER — dengan redirect logic berbasis auth state
// ══════════════════════════════════════════════════════════════
final GoRouter appRouter = GoRouter(
  initialLocation: Routes.splash,
  debugLogDiagnostics: true,
  refreshListenable: _authListenable,

  // ── REDIRECT LOGIC ─────────────────────────────────────────
  // Berjalan setiap kali auth state berubah.
  // Menentukan ke mana user diarahkan berdasarkan login state.
  redirect: (context, state) async {
    final user      = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final loc        = state.uri.toString();

    final isAuthPage = loc == Routes.splash    ||
        loc == Routes.onboarding ||
        loc == Routes.login      ||
        loc == Routes.signupStep1 ||
        loc == Routes.signupStep2 ||
        loc == Routes.forgotPassword;

    // ── Jika tidak login dan mencoba akses halaman utama ──────
    if (!isLoggedIn && !isAuthPage) {
      return Routes.login;
    }

    // ── Jika sudah login dan masih di halaman auth ────────────
    if (isLoggedIn && isAuthPage) {
      // Cek apakah onboarding sudah selesai
      final done = await FirestoreService.instance.isOnboardingDone(user.uid);
      if (!done) return Routes.onboarding;
      return Routes.home;
    }

    return null; // tidak redirect
  },

  routes: [
    // ── Auth routes ─────────────────────────────────────────
    GoRoute(
      path: Routes.splash,
      pageBuilder: (_, s) => _scaleFade(const SplashScreen(), s),
    ),
    GoRoute(
      path: Routes.onboarding,
      pageBuilder: (_, s) => _scaleFade(const OnboardingScreen(), s),
    ),
    GoRoute(
      path: Routes.login,
      pageBuilder: (_, s) => _slideUp(const LoginScreen(), s),
    ),
    GoRoute(
      path: Routes.forgotPassword,
      pageBuilder: (_, s) => _slideRight(const ForgotPasswordScreen(), s),
    ),
    GoRoute(
      path: Routes.signupStep1,
      pageBuilder: (_, s) => _slideRight(const SignupStep1Screen(), s),
    ),
    GoRoute(
      path: Routes.signupStep2,
      pageBuilder: (_, s) => _slideRight(const SignupStep2Screen(), s),
    ),

    // ── Main app (ShellRoute) ────────────────────────────────
    ShellRoute(
      navigatorKey: _shellNavKey,
      builder: (context, state, child) {
        int tab = 0;
        final loc = state.uri.toString();
        if (loc.startsWith(Routes.search))  tab = 1;
        if (loc.startsWith(Routes.library)) tab = 2;
        if (loc.startsWith(Routes.profile)) tab = 3;

        return _MainShell(
          activeTab: tab,
          child: child,
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
            pageBuilder: (_, s) => _slideUp(const HomeScreen(), s)),
        GoRoute(path: Routes.search,
            pageBuilder: (_, s) => _fade(const SearchScreen(), s)),
        GoRoute(path: Routes.library,
            pageBuilder: (_, s) => _fade(const LibraryScreen(), s)),
        GoRoute(path: Routes.profile,
            pageBuilder: (_, s) => _fade(const ProfileScreen(), s)),
      ],
    ),
  ],

  errorBuilder: (_, state) => Scaffold(
    backgroundColor: const Color(0xFF03045E),
    body: Center(
      child: Text('Not found: ${state.uri}',
          style: const TextStyle(color: Colors.white)),
    ),
  ),
);

// ── Shell dengan AnimatedBottomNav ───────────────────────────
class _MainShell extends StatelessWidget {
  final int activeTab;
  final Widget child;
  final ValueChanged<int> onNavTap;
  const _MainShell({
    required this.activeTab,
    required this.child,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF03045E),
    bottomNavigationBar: AnimatedBottomNav(
        selectedIndex: activeTab, onTap: onNavTap),
    body: child,
  );
}