import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animasi logo (scale + fade masuk) ────────────────────
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // ── Animasi teks (fade masuk setelah logo) ───────────────
  late AnimationController _textController;
  late Animation<double> _textOpacity;

  // ── Animasi loading bar ──────────────────────────────────
  late AnimationController _loadingController;
  late Animation<double> _loadingProgress;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateAfterDelay();
  }

  void _setupAnimations() {
    // Logo: muncul dengan scale + fade dalam 0.8 detik
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Teks: fade in setelah logo selesai
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // Loading bar: fill dari 0 ke 1 selama 2 detik
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    // Jalankan animasi secara berurutan
    _logoController.forward().then((_) {
      _textController.forward();
      _loadingController.forward();
    });
  }

  void _navigateAfterDelay() {
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        // Cukup arahkan ke home, router yang akan menentukan 
        // apakah ke Home, Login, atau Onboarding.
        context.go(Routes.home);
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // ── Lingkaran dekorasi kiri atas ─────────────────
          Positioned(
            left: -60,
            top: -61,
            child: Container(
              width: 282,
              height: 283,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealWithOpacity(0.07),
              ),
            ),
          ),

          // ── Lingkaran dekorasi kanan bawah ───────────────
          Positioned(
            left: 202,
            top: 606,
            child: Container(
              width: 322,
              height: 323,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealWithOpacity(0.05),
              ),
            ),
          ),

          // ── Konten utama ─────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo — lingkaran teal dengan ikon ♪
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: _LogoWidget(),
                ),

                const SizedBox(height: 36),

                // Teks "mikuplay" + subtitle
                FadeTransition(
                  opacity: _textOpacity,
                  child: const Column(
                    children: [
                      Text(
                        'mikuplay',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          letterSpacing: -1.0,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'your vocaloid universe',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Loading bar bawah ─────────────────────────────
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Column(
                children: [
                  // Track (background bar)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 137.5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: AnimatedBuilder(
                        animation: _loadingProgress,
                        builder: (context, _) {
                          return Stack(
                            children: [
                              // Background
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.whiteWithOpacity(0.1),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                              // Fill
                              FractionallySizedBox(
                                widthFactor: _loadingProgress.value,
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: AppColors.teal,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.skyWithOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget logo lingkaran (sesuai desain Figma)
class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring luar (transparan dengan border)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tealWithOpacity(0.08),
              border: Border.all(
                color: AppColors.tealWithOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
          // Ring tengah
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tealWithOpacity(0.12),
              border: Border.all(
                color: AppColors.tealWithOpacity(0.4),
                width: 1,
              ),
            ),
          ),
          // Lingkaran isi teal
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal,
            ),
            child: const Center(
              child: Text(
                '♪',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}