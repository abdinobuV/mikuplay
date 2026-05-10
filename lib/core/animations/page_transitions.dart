// ============================================================
// FILE INI DISIMPAN DI:
// lib/core/animations/page_transitions.dart
//
// BUAT FOLDER BARU:
// lib/core/animations/
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Kumpulan custom page transitions MikuPlay.
/// Semua transition dirancang subtle, smooth, dan konsisten.
/// Tidak ada bounce lebay — cukup easing yang terasa native.
class MikuTransitions {
  MikuTransitions._();

  // ── Durasi standar ────────────────────────────────────────
  static const Duration fast    = Duration(milliseconds: 300);
  static const Duration normal  = Duration(milliseconds: 400);
  static const Duration slow    = Duration(milliseconds: 500);

  // ── Curve standar ─────────────────────────────────────────
  // fastOutSlowIn = terasa paling natural untuk perpindahan UI
  static const Curve standard = Curves.fastOutSlowIn;
  static const Curve decel    = Curves.decelerate;
  static const Curve ease     = Curves.easeInOut;

  // ----------------------------------------------------------
  // 1. FADE — untuk perpindahan antar tab utama (Home/Search/Library/Profile)
  //    Terasa "in-place", tidak ada pergerakan arah, cocok untuk
  //    tab switching yang sejajar.
  // ----------------------------------------------------------
  static CustomTransitionPage<T> fade<T>({
    required Widget child,
    required GoRouterStateAdapter state,
    Duration duration = fast,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 1.0, curve: Curves.linear),
          ),
          child: child,
        );
      },
    );
  }

  // ----------------------------------------------------------
  // 2. SLIDE RIGHT — untuk push ke halaman detail
  //    (Login → Forgot Password, Signup Step 1 → Step 2)
  //    Terasa seperti navigasi native iOS.
  // ----------------------------------------------------------
  static CustomTransitionPage<T> slideRight<T>({
    required Widget child,
    required GoRouterStateAdapter state,
    Duration duration = normal,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: standard));

        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
          ),
        );

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // 3. SLIDE UP — untuk Login/Signup → Home
  //    Halaman baru "muncul dari bawah", menandakan level baru.
  //    Diperkuat dengan fade agar tidak terlalu drastis.
  // ----------------------------------------------------------
  static CustomTransitionPage<T> slideUp<T>({
    required Widget child,
    required GoRouterStateAdapter state,
    Duration duration = slow,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: normal,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0.0, 0.08), // hanya 8% dari bawah, bukan full
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: decel));

        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
          ),
        );

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // 4. SCALE + FADE — untuk Splash → Onboarding
  //    Efek "zoom in" halus, menandakan app baru dibuka.
  // ----------------------------------------------------------
  static CustomTransitionPage<T> scaleUp<T>({
    required Widget child,
    required GoRouterStateAdapter state,
    Duration duration = slow,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: fast,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final scale = Tween<double>(begin: 0.96, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: decel),
        );
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
          ),
        );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // 5. FADE THROUGH — untuk transisi dalam onboarding (antar page)
  //    Konten lama fade out, konten baru fade in + sedikit slide.
  //    Tidak ada slide penuh — lebih elegan.
  // ----------------------------------------------------------
  static Widget fadeThroughBuilder(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
    final slideIn = Tween<Offset>(
      begin: const Offset(0.04, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: decel));

    return FadeTransition(
      opacity: fadeIn,
      child: SlideTransition(position: slideIn, child: child),
    );
  }
}

/// Adapter agar bisa passing state ke transition tanpa import go_router
/// di file ini — cukup gunakan interface sederhana.
abstract class GoRouterStateAdapter {
  ValueKey<String> get pageKey;
}