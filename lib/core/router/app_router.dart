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
import '../../features/player/presentation/screens/now_playing_screen.dart';
import '../../shared/widgets/animated_bottom_nav.dart';
import '../../shared/widgets/mini_player.dart';
import '../../features/artist/presentation/screens/artist_screen.dart';
import '../../features/artist/presentation/screens/more_artist_screen.dart';
import '../../features/profile/presentation/screens/play_history_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/equalizer_screen.dart';

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
  static const String nowPlaying      = '/now-playing';
  static const String artist         = '/artist';
  static const String moreArtist     = '/more-artist';
  static const String history        = '/profile/history';
  static const String settings       = '/profile/settings';
  static const String equalizer      = '/profile/settings/eq';
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
  // Berjalan setiap kali auth state berubah atau navigasi terjadi.
  redirect: (context, state) async {
    final user       = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final loc        = state.matchedLocation;

    final isSplash       = loc == Routes.splash;
    final isSignupPage   = loc.startsWith('/signup');
    final isBaseAuthPage = isSplash ||
                           loc == Routes.onboarding ||
                           loc == Routes.login ||
                           loc == Routes.forgotPassword;

    // ── Case: NOT LOGGED IN ──
    if (!isLoggedIn) {
      // Jika mencoba akses halaman utama/private, lempar ke login
      if (!isBaseAuthPage && !isSignupPage) {
        return Routes.login;
      }
      return null;
    }

    // ── Case: LOGGED IN ──
    if (isLoggedIn) {
      // Biarkan Splash dan Signup tetap tampil tanpa interupsi
      if (isSplash || isSignupPage) return null;

      // Cek apakah onboarding sudah selesai
      final done = await FirestoreService.instance.isOnboardingDone(user.uid);

      // Jika belum selesai dan tidak sedang di onboarding, paksa ke onboarding
      if (!done && loc != Routes.onboarding) {
        return Routes.onboarding;
      }

      // Jika sudah selesai tapi masih di halaman entry (login/onboarding), lempar ke home
      if (done && (loc == Routes.login || loc == Routes.onboarding)) {
        return Routes.home;
      }
    }

    return null; // tidak ada redirect tambahan
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

    // ── Artist routes ───────────────────────────────────────
    GoRoute(
      path: '${Routes.artist}/:artistName',
      pageBuilder: (_, s) => _slideRight(ArtistScreen(artistName: s.pathParameters['artistName'] ?? ''), s),
    ),
    GoRoute(
      path: Routes.moreArtist,
      pageBuilder: (_, s) => _slideRight(const MoreArtistScreen(), s),
    ),
    GoRoute(
      path: Routes.history,
      pageBuilder: (_, s) => _slideRight(const PlayHistoryScreen(), s),
    ),
    GoRoute(
      path: Routes.settings,
      pageBuilder: (_, s) => _slideRight(const SettingsScreen(), s),
    ),
    GoRoute(
      path: Routes.equalizer,
      pageBuilder: (_, s) => _slideRight(const EqualizerScreen(), s),
    ),

    // ── Player route (Full Screen) ──────────────────────────
    GoRoute(
      path: Routes.nowPlaying,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const NowPlayingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
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
    body: Stack(
      children: [
        child,
        const Positioned(
          left: 0,
          right: 0,
          bottom: 10, // Memberi jarak dari bottom nav
          child: MiniPlayer(),
        ),
      ],
    ),
    bottomNavigationBar: AnimatedBottomNav(
        selectedIndex: activeTab, onTap: onNavTap),
  );
}
