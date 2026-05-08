// ============================================================
// FILE INI DISIMPAN DI:
// lib/features/auth/presentation/screens/onboarding_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

// ── Data tiap halaman onboarding (sesuai Figma) ──────────────
class _PageData {
  final String imageUrl;   // URL ilustrasi dari Figma
  final String title;
  final String subtitle;
  final String buttonLabel;

  const _PageData({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
  });
}

// Figma node 19:17 — ilustrasi Hibikase artwork
const _obPages = [
  _PageData(
    imageUrl:
    'onboarding_1.png',
    title: 'Discover Your\nFavorite Vocaloid Music',
    subtitle:
    'Enjoy thousands of Hatsune Miku, KAITO,\nMEIKO, and all your favorite Vocaloid songs.',
    buttonLabel: 'Start Exploring',
  ),
  _PageData(
    imageUrl:
    'onboarding_2.png',
    title: 'Real-Time Lyrics\nAs the Music Plays',
    subtitle:
    'Follow every word with a perfectly\nsynchronized lyrics display.',
    buttonLabel: 'Next',
  ),
  _PageData(
    imageUrl:
    'onboarding_3.png',
    title: 'Create Playlists\nThat Match Your Mood',
    subtitle:
    'Organize your favorite songs in personal\nplaylists you can share with friends.',
    buttonLabel: 'Get Started',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < _obPages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(Routes.login);
    }
  }

  void _onSkip() => context.go(Routes.login);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // ── Dekorasi kiri (Figma: left=-81, top=101, w=322) ──
          Positioned(
            left: -81,
            top: 101,
            child: _DecoEllipse(
              width: 322,
              height: 323,
              color: AppColors.tealOp(0.07),
            ),
          ),
          // ── Dekorasi kanan bawah (Figma: left=151, top=505, w=262) ──
          Positioned(
            left: 151,
            top: 505,
            child: _DecoEllipse(
              width: 262,
              height: 262,
              color: AppColors.tealOp(0.07),
            ),
          ),

          // ── PageView ──────────────────────────────────────────
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _obPages.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) => _OnboardingPage(data: _obPages[i]),
          ),

          // ── Bottom controls (dot + button + skip) ────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomControls(
              currentIndex: _currentIndex,
              pageCount: _obPages.length,
              buttonLabel: _obPages[_currentIndex].buttonLabel,
              onNext: _onNext,
              onSkip: _onSkip,
              pageCtrl: _pageCtrl,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Satu halaman onboarding ──────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status bar space
        const SizedBox(height: 44),

        // ── Ilustrasi (Figma: center, w=285, h=287) ───────────
        // top: calc(50% - 157.5px) → sekitar 264px dari atas
        Expanded(
          flex: 5,
          child: Center(
            child: _IllustrationWidget(imageUrl: data.imageUrl),
          ),
        ),

        // ── Teks area (Figma: left=28) ────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title (Figma: font-bold, 28.3px, color=#F8F9FA, tracking=-0.8)
              Text(
                data.title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  letterSpacing: -0.8,
                  height: 1.28,
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle (Figma: font-regular, 14.1px, color=#90E0EF)
              Text(
                data.subtitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.sky,
                  height: 1.57,
                ),
              ),
            ],
          ),
        ),

        // Space for bottom controls
        const SizedBox(height: 175),
      ],
    );
  }
}

// ── Ilustrasi dengan concentric circles (sesuai Figma node 19:24) ──
class _IllustrationWidget extends StatelessWidget {
  final String imageUrl;
  const _IllustrationWidget({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 285,
      height: 287,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran dekorasi luar (Figma: left=45, top=61, w=302, h=303)
          Positioned(
            left: 45,
            top: 61,
            child: _DecoEllipse(width: 302, height: 303, color: AppColors.tealOp(0.08)),
          ),
          // Lingkaran tengah (Figma: left=96, top=111, size=202)
          Positioned(
            left: 96,
            top: 111,
            child: _DecoEllipse(width: 202, height: 202, color: AppColors.tealOp(0.08)),
          ),
          // Lingkaran kecil (Figma: left=146, top=162, size=101)
          Positioned(
            left: 146,
            top: 162,
            child: _DecoEllipse(width: 101, height: 101, color: AppColors.tealOp(0.12)),
          ),
          // Gambar utama
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/$imageUrl',
              width: 285,
              height: 287,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 285,
                height: 287,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.tealOp(0.3),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '♫',
                    style: TextStyle(
                      fontSize: 80,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Kontrol bawah: dot indicator + button + skip ─────────────
class _BottomControls extends StatelessWidget {
  final int currentIndex;
  final int pageCount;
  final String buttonLabel;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final PageController pageCtrl;

  const _BottomControls({
    required this.currentIndex,
    required this.pageCount,
    required this.buttonLabel,
    required this.onNext,
    required this.onSkip,
    required this.pageCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.navy.withOpacity(0.0),
            AppColors.navy.withOpacity(0.95),
            AppColors.navy,
          ],
          stops: const [0.0, 0.2, 0.5],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Dot indicator (Figma: left=28, top=634, size=8) ──
          SmoothPageIndicator(
            controller: pageCtrl,
            count: pageCount,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.teal,      // #00B4D8
              dotColor: AppColors.skyOp(0.4),
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 2.5,
              spacing: 10,
            ),
          ),
          const SizedBox(height: 20),

          // ── Tombol utama (Figma: h=52, rounded=99, bg=#00B4D8) ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: AppColors.navy,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Skip (Figma: left=176, color=rgba(144,224,239,0.6)) ──
          Center(
            child: GestureDetector(
              onTap: onSkip,
              child: Text(
                'Skip',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.skyOp(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dekorasi lingkaran background ────────────────────────────
class _DecoEllipse extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  const _DecoEllipse({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}