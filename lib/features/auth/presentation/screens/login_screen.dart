// ============================================================
// FILE INI DISIMPAN DI:
// lib/features/auth/presentation/screens/login_screen.dart
// GANTI SELURUH ISI FILE LAMA
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  bool _obscure        = true;
  bool _isLoading      = false;
  bool _isGoogleLoading = false;
  String? _errorMsg;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 550));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Sign In Email/Password ───────────────────────────────────
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMsg = null; });

    final result = await AuthService.instance.signIn(
      email:    _emailCtrl.text,
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      context.go(Routes.home);
    } else {
      setState(() => _errorMsg = result.errorMessage);
    }
  }

  // ── Google Sign In ────────────────────────────────────────────
  Future<void> _handleGoogleSignIn() async {
    setState(() { _isGoogleLoading = true; _errorMsg = null; });

    final result = await AuthService.instance.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (result.success) {
      context.go(Routes.home);
    } else {
      setState(() => _errorMsg = result.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(children: [
          // Dekorasi
          Positioned(left: -40, top: -40, child: _circle(202, 0.06)),
          Positioned(left: 222, top: 707, child: _circle(242, 0.04)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),
                    const Center(child: _SmallLogo()),
                    const SizedBox(height: 46),

                    // Title
                    const Text('Welcome\nback',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700,
                            color: AppColors.white, letterSpacing: -0.8, height: 1.28)),
                    const SizedBox(height: 14),
                    Text('Sign in to continue to MikuPlay',
                        style: TextStyle(fontSize: 13, color: AppColors.skyOp(0.8))),
                    const SizedBox(height: 46),

                    // Error banner
                    if (_errorMsg != null) ...[
                      _ErrorBanner(message: _errorMsg!),
                      const SizedBox(height: 16),
                    ],

                    // Email field
                    _label('Email'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 13, color: AppColors.white),
                      decoration: _inputDeco('miku@vocaloid.jp'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Password field
                    _label('Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(fontSize: 13, color: AppColors.white),
                      decoration: _inputDeco('••••••••••').copyWith(
                        suffixIcon: _eyeButton(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your password';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => context.push(Routes.forgotPassword),
                        child: const Text('Forgot password?',
                            style: TextStyle(fontSize: 12, color: AppColors.teal)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign In button
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: AppColors.navy,
                          disabledBackgroundColor: AppColors.tealOp(0.5),
                          shape: const StadiumBorder(),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.navy))
                            : const Text('Sign In',
                            style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Center(child: Text('or sign in with',
                        style: TextStyle(fontSize: 12,
                            color: AppColors.skyOp(0.5)))),
                    const SizedBox(height: 16),

                    // Google button
                    _GoogleButton(
                      isLoading: _isGoogleLoading,
                      onTap: _handleGoogleSignIn,
                    ),
                    const SizedBox(height: 40),

                    // Sign up link
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push(Routes.signupStep1),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 13,
                                color: AppColors.skyOp(0.7)),
                            children: const [
                              TextSpan(text: "Don't have an account?  "),
                              TextSpan(text: 'Sign up',
                                  style: TextStyle(color: AppColors.teal,
                                      fontWeight: FontWeight.w600)),
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
        ]),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
          color: AppColors.sky));

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppColors.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.skyOp(0.2))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.skyOp(0.2))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.teal)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.red)),
    hintStyle: TextStyle(fontSize: 13, color: AppColors.skyOp(0.3)),
  );

  Widget _eyeButton() => IconButton(
    icon: Icon(_obscure ? Icons.visibility_outlined
        : Icons.visibility_off_outlined,
        size: 18, color: AppColors.skyOp(0.5)),
    onPressed: () => setState(() => _obscure = !_obscure),
  );

  Widget _circle(double size, double op) => Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle,
          color: AppColors.tealOp(op)));
}

// ── Error Banner ──────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.red.withOpacity(0.4)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.red),
        const SizedBox(width: 10),
        Expanded(child: Text(message,
            style: const TextStyle(fontSize: 12, color: AppColors.red))),
      ]),
    );
  }
}

// ── Google Button ─────────────────────────────────────────────
class _GoogleButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _GoogleButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity, height: 48,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.skyOp(0.3)),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.teal))
              : Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('G', style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w700, color: AppColors.teal)),
            const SizedBox(width: 10),
            const Text('Continue with Google',
                style: TextStyle(fontSize: 14, color: AppColors.white)),
          ]),
        ),
      ),
    );
  }
}

// ── Small Logo ────────────────────────────────────────────────
class _SmallLogo extends StatelessWidget {
  const _SmallLogo();
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 101, height: 101,
        child: Stack(alignment: Alignment.center, children: [
          Container(width: 101, height: 101,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: AppColors.tealOp(0.12),
                  border: Border.all(color: AppColors.tealOp(0.5), width: 1.5))),
          Container(width: 64, height: 64,
              decoration: const BoxDecoration(shape: BoxShape.circle,
                  color: AppColors.teal),
              child: const Center(child: Text('♪',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                      color: AppColors.navy)))),
        ]));
  }
}