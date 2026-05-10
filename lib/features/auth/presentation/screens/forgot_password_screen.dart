import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _isLoading  = false;
  bool _emailSent  = false;

  // Animasi fade-in saat masuk halaman
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: ganti dengan API call sesungguhnya
    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) setState(() { _isLoading = false; _emailSent = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // ── Dekorasi kiri atas ────────────────────────────
            Positioned(
              left: -60, top: -61,
              child: _circle(202, 0.07),
            ),
            // ── Dekorasi kanan bawah ──────────────────────────
            Positioned(
              left: 262, top: 606,
              child: _circle(222, 0.05),
            ),
            // ── Dekorasi kanan atas ───────────────────────────
            Positioned(
              left: 202, top: -61,
              child: _circle(242, 0.04),
            ),

            // ── Konten utama ──────────────────────────────────
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _emailSent
                    ? _SuccessView(
                  key: const ValueKey('success'),
                  email: _emailCtrl.text,
                  onBack: () => context.pop(),
                )
                    : _FormView(
                  key: const ValueKey('form'),
                  formKey: _formKey,
                  emailCtrl: _emailCtrl,
                  isLoading: _isLoading,
                  onSend: _sendResetLink,
                  onBack: () => context.pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.tealOp(opacity),
    ),
  );
}

// ── Tampilan form (sebelum email terkirim) ────────────────────
class _FormView extends StatelessWidget {
  final GlobalKey<FormState>    formKey;
  final TextEditingController   emailCtrl;
  final bool                    isLoading;
  final VoidCallback            onSend;
  final VoidCallback            onBack;

  const _FormView({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.onSend,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 13),

            // ── Back button ────────────────────────────────────
            GestureDetector(
              onTap: onBack,
              child: Text(
                '← Sign In',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: AppColors.skyOp(0.7),
                ),
              ),
            ),
            const SizedBox(height: 52),

            // ── Ikon kunci dalam lingkaran teal ───────────────
            Center(
              child: Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tealOp(0.12),
                  border: Border.all(
                    color: AppColors.tealOp(0.5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.tealOp(0.2),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 32,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Title ──────────────────────────────────────────
            const Center(
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Subtitle ───────────────────────────────────────
            Center(
              child: Text(
                "No worries! Enter your email address\nand we'll send you a reset link.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.skyOp(0.75),
                  height: 1.55,
                ),
              ),
            ),
            const SizedBox(height: 48),

            // ── Label Email ────────────────────────────────────
            Text(
              'Email address',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.sky,
              ),
            ),
            const SizedBox(height: 8),

            // ── Input Email (sama persis dengan login screen) ──
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.white,
              ),
              decoration: InputDecoration(
                hintText: 'miku@vocaloid.jp',
                filled: true,
                fillColor: AppColors.card,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 13, vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.skyOp(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.skyOp(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.teal),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.red),
                ),
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.skyOp(0.3),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your email';
                if (!v.contains('@')) return 'Enter a valid email address';
                return null;
              },
            ),
            const SizedBox(height: 32),

            // ── Tombol Send Reset Link ─────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: AppColors.navy,
                  disabledBackgroundColor: AppColors.tealOp(0.5),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.navy,
                  ),
                )
                    : const Text(
                  'Send Reset Link',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Kembali ke login ───────────────────────────────
            Center(
              child: GestureDetector(
                onTap: onBack,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.skyOp(0.65),
                    ),
                    children: const [
                      TextSpan(text: 'Remember your password?  '),
                      TextSpan(
                        text: 'Sign In',
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
    );
  }
}

// ── Tampilan sukses (setelah email terkirim) ──────────────────
class _SuccessView extends StatelessWidget {
  final String       email;
  final VoidCallback onBack;

  const _SuccessView({
    super.key,
    required this.email,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 120),

          // ── Ikon centang dalam lingkaran ───────────────────
          Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tealOp(0.12),
              border: Border.all(
                color: AppColors.tealOp(0.5),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.check_rounded,
                size: 48,
                color: AppColors.teal,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── Title ──────────────────────────────────────────
          const Text(
            'Check Your Email!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 14),

          // ── Subtitle ───────────────────────────────────────
          Text(
            "We've sent a password reset link to\n$email",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.skyOp(0.75),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 48),

          // ── Tombol Back to Sign In ─────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: AppColors.navy,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                'Back to Sign In',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Resend ─────────────────────────────────────────
          Text(
            "Didn't receive the email? Check your spam or",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.skyOp(0.55),
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onBack,
            child: const Text(
              'try another email address',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.teal,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.teal,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}