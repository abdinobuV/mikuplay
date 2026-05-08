import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Form controllers
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  // State
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Animasi fade-in saat masuk halaman
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Aksi Sign In ─────────────────────────────────────────
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulasi loading (ganti dengan API call asli)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() => _isLoading = false);
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // ── Lingkaran dekorasi kiri atas ─────────────
            Positioned(
              left: -40,
              top: -40,
              child: Container(
                width: 202,
                height: 202,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tealWithOpacity(0.06),
                ),
              ),
            ),

            // ── Lingkaran dekorasi kanan bawah ───────────
            Positioned(
              left: 222,
              top: 707,
              child: Container(
                width: 242,
                height: 242,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tealWithOpacity(0.04),
                ),
              ),
            ),

            // ── Konten scroll utama ───────────────────────
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 22),

                      // Logo kecil di atas
                      Center(child: _SmallLogo()),

                      const SizedBox(height: 46),

                      // "Welcome back"
                      const Text(
                        'Welcome\nback',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          letterSpacing: -0.8,
                          height: 1.28,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Subtitle
                      Text(
                        'Sign in to continue to MikuPlay',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.skyWithOpacity(0.8),
                        ),
                      ),

                      const SizedBox(height: 46),

                      // ── Label Email ───────────────────────
                      _FieldLabel('Email'),
                      const SizedBox(height: 8),

                      // ── Input Email ───────────────────────
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.white,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'miku@vocaloid.jp',
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!val.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // ── Label Password ────────────────────
                      _FieldLabel('Password'),
                      const SizedBox(height: 8),

                      // ── Input Password ────────────────────
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.skyWithOpacity(0.5),
                              size: 20,
                            ),
                            onPressed: () => setState(
                                  () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (val.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // ── Forgot Password ───────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: navigate to forgot password
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Forgot password coming soon'),
                                backgroundColor: AppColors.navyCard,
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Tombol Sign In ────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: AppColors.navy,
                            shape: const StadiumBorder(),
                            disabledBackgroundColor:
                            AppColors.tealWithOpacity(0.5),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.navy,
                            ),
                          )
                              : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Divider "or sign in with" ─────────
                      Center(
                        child: Text(
                          'or sign in with',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.skyWithOpacity(0.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── Google Button ─────────────────────
                      _GoogleButton(
                        onTap: () {
                          // TODO: implement Google Sign In
                        },
                      ),

                      const SizedBox(height: 44),

                      // ── Link ke Sign Up ───────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () => context.go(AppRoutes.signup),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.skyWithOpacity(0.7),
                              ),
                              children: const [
                                TextSpan(
                                  text: "Don't have an account?  ",
                                ),
                                TextSpan(
                                  text: 'Sign up',
                                  style: TextStyle(
                                    color: AppColors.teal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget Helpers ───────────────────────────────────────────

/// Logo kecil untuk halaman login (sesuai Figma)
class _SmallLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 101,
      height: 101,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring luar
          Container(
            width: 101,
            height: 101,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tealWithOpacity(0.12),
              border: Border.all(
                color: AppColors.tealWithOpacity(0.5),
                width: 1.5,
              ),
            ),
          ),
          // Lingkaran isi
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal,
            ),
            child: const Center(
              child: Text(
                '♪',
                style: TextStyle(
                  fontSize: 22,
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

/// Label di atas input field
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.sky,
      ),
    );
  }
}

/// Tombol Continue with Google
class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.navyCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.skyWithOpacity(0.3),
          ),
        ),
        child: const Center(
          child: Text(
            'Continue with Google',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}