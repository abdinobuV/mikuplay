import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMsg;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
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
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final result = await AuthService.instance.sendPasswordResetEmail(
      _emailCtrl.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.success) {
        _emailSent = true;
      } else {
        _errorMsg = result.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(children: [
          // Dekorasi
          Positioned(left: -60, top: -61, child: _circle(202, 0.07)),
          Positioned(left: 262, top: 606, child: _circle(222, 0.05)),

          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _emailSent
                  ? _SuccessView(
                      key: const ValueKey('success'),
                      email: _emailCtrl.text.trim(),
                      onBack: () => context.pop(),
                      onResend: _sendResetLink,
                    )
                  : _FormView(
                      key: const ValueKey('form'),
                      formKey: _formKey,
                      emailCtrl: _emailCtrl,
                      isLoading: _isLoading,
                      errorMsg: _errorMsg,
                      onSend: _sendResetLink,
                      onBack: () => context.pop(),
                    ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _circle(double size, double op) => Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: AppColors.tealOp(op)));
}

// ── Form View ─────────────────────────────────────────────────
class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final String? errorMsg;
  final VoidCallback onSend;
  final VoidCallback onBack;

  const _FormView(
      {super.key,
      required this.formKey,
      required this.emailCtrl,
      required this.isLoading,
      this.errorMsg,
      required this.onSend,
      required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Form(
        key: formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 13),

          GestureDetector(
            onTap: onBack,
            child: Text('← Sign In',
                style: TextStyle(fontSize: 15, color: AppColors.skyOp(0.7))),
          ),
          const SizedBox(height: 52),

          // Icon
          Center(
              child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.12),
                border: Border.all(color: AppColors.tealOp(0.5), width: 1.5)),
            child: Center(
                child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.tealOp(0.2)),
                    child: const Icon(Icons.lock_outline_rounded,
                        size: 32, color: AppColors.teal))),
          )),
          const SizedBox(height: 28),

          const Center(
              child: Text('Forgot Password?',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: -0.6))),
          const SizedBox(height: 12),

          Center(
              child: Text(
                  "No worries! Enter your email address\n"
                  "and we'll send you a reset link.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.skyOp(0.75),
                      height: 1.55))),
          const SizedBox(height: 40),

          // Error banner
          if (errorMsg != null) ...[
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.red.withOpacity(0.4))),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 16, color: AppColors.red),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(errorMsg!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.red))),
                ])),
            const SizedBox(height: 16),
          ],

          // Email label
          Text('Email address',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.sky)),
          const SizedBox(height: 8),

          // Email field
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 13, color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'miku@vocaloid.jp',
              filled: true,
              fillColor: AppColors.card,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.skyOp(0.2))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.skyOp(0.2))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.teal)),
              hintStyle: TextStyle(fontSize: 13, color: AppColors.skyOp(0.3)),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!v.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 28),

          // Send button
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
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.navy))
                  : const Text('Send Reset Link',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 28),

          Center(
              child: GestureDetector(
            onTap: onBack,
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: AppColors.skyOp(0.65)),
                children: const [
                  TextSpan(text: 'Remember your password?  '),
                  TextSpan(
                      text: 'Sign In',
                      style: TextStyle(
                          color: AppColors.teal, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          )),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}

// ── Success View ──────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final String email;
  final VoidCallback onBack;
  final VoidCallback onResend;

  const _SuccessView(
      {super.key,
      required this.email,
      required this.onBack,
      required this.onResend});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(children: [
        const SizedBox(height: 120),

        Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.12),
                border: Border.all(color: AppColors.tealOp(0.5), width: 1.5)),
            child: const Center(
                child: Icon(Icons.mark_email_read_rounded,
                    size: 44, color: AppColors.teal))),
        const SizedBox(height: 28),

        const Text('Check Your Email!',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                letterSpacing: -0.6)),
        const SizedBox(height: 12),

        // Box info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.tealOp(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tealOp(0.3))),
          child: Column(children: [
            Text("We've sent a password reset link to:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.skyOp(0.75))),
            const SizedBox(height: 8),
            Text(email,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal)),
            const SizedBox(height: 8),
            Text(
                "Click the link in the email to reset your password.\n"
                "The link expires in 1 hour.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: AppColors.skyOp(0.6), height: 1.5)),
          ]),
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: AppColors.navy,
              shape: const StadiumBorder(),
            ),
            child: const Text('Back to Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 20),

        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Didn't receive it? ",
              style: TextStyle(fontSize: 13, color: AppColors.skyOp(0.55))),
          GestureDetector(
              onTap: onResend,
              child: const Text('Resend email',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.teal,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.teal))),
        ]),
        const SizedBox(height: 40),
      ]),
    );
  }
}
