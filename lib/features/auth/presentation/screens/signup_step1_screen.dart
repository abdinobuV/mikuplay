import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart'; // Tambahan Import

class SignupStep1Screen extends StatefulWidget {
  const SignupStep1Screen({super.key});

  @override
  State<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends State<SignupStep1Screen> {
  final _formKey       = GlobalKey<FormState>();
  final _usernameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _agreed         = true;
  bool _isLoading      = false; // State tambahan untuk loading

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Fungsi Sign Up Terhubung ke Firebase ─────────────────────
  Future<void> _onNext() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please agree to MikuPlay's Terms & Conditions"),
          backgroundColor: AppColors.card,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true); // Nyalakan loading

    // Proses pembuatan akun ke Firebase
    final result = await AuthService.instance.signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false); // Matikan loading

    // Jika sukses daftar, baru dilanjutkan ke halaman Step 2
    if (result.success) {
      context.push(Routes.signupStep2);
    } else {
      // Jika gagal (email sudah terpakai, dll), tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Pendaftaran gagal'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          Positioned(left: -60, top: -61, child: _circle(202)),
          Positioned(left: 262, top: 606, child: _circle(222)),
          Positioned(left: 202, top: -61, child: _circle(242, opacity: 0.04)),

          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 13),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.go(Routes.login),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: Text(
                            '← Sign In',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              color: AppColors.skyOp(0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 68),

                    const Center(
                      child: Text(
                        'Sign Up for MikuPlay',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Center(
                      child: Text(
                        'Start your music journey today',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.skyOp(0.75),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    const Center(child: StepIndicator(activeStep: 1)),
                    const SizedBox(height: 22),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Username'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _usernameCtrl,
                            hint: '@mikufan',
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter a username';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          _fieldLabel('Email'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailCtrl,
                            hint: 'abdi@email.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter your email';
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          _fieldLabel('Password'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _passCtrl,
                            hint: '••••••••••',
                            obscure: _obscurePass,
                            suffixIcon: _eyeButton(
                              _obscurePass,
                                  () => setState(() => _obscurePass = !_obscurePass),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter a password';
                              if (v.length < 6) return 'Minimum 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          _fieldLabel('Confirm Password'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _confirmCtrl,
                            hint: '••••••••••',
                            obscure: _obscureConfirm,
                            suffixIcon: _eyeButton(
                              _obscureConfirm,
                                  () => setState(
                                      () => _obscureConfirm = !_obscureConfirm),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Confirm your password';
                              }
                              if (v != _passCtrl.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          TermsCheckbox(
                            agreed: _agreed,
                            onChanged: (val) =>
                                setState(() => _agreed = val ?? false),
                          ),
                          const SizedBox(height: 22),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teal,
                                foregroundColor: AppColors.navy,
                                disabledBackgroundColor: AppColors.tealOp(0.5),
                                shape: const StadiumBorder(),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppColors.navy))
                                  : const Text(
                                'Customize your Profile',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, {double opacity = 0.07}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.tealOp(opacity),
    ),
  );

  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.sky,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        color: AppColors.white,
      ),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
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
      validator: validator,
    );
  }

  Widget _eyeButton(bool obscure, VoidCallback onTap) => IconButton(
    icon: Icon(
      obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      size: 18,
      color: AppColors.skyOp(0.5),
    ),
    onPressed: onTap,
  );
}

class StepIndicator extends StatelessWidget {
  final int activeStep;
  const StepIndicator({super.key, required this.activeStep});

  static const _labels = ['Account', 'Profile', 'Done'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < 3; i++) ...[
          _StepCircle(
            number: i + 1,
            label: _labels[i],
            isActive: (i + 1) == activeStep,
            isDone: (i + 1) < activeStep,
          ),
          if (i < 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                width: 67,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.skyOp(0.2),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isDone;
  const _StepCircle({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.teal
                : (isDone
                ? AppColors.tealOp(0.3)
                : AppColors.card),
            border: isActive
                ? null
                : Border.all(color: AppColors.skyOp(0.3), width: 1),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? AppColors.navy
                    : AppColors.skyOp(0.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: isActive ? AppColors.teal : AppColors.skyOp(0.4),
          ),
        ),
      ],
    );
  }
}

class TermsCheckbox extends StatelessWidget {
  final bool agreed;
  final ValueChanged<bool?> onChanged;
  const TermsCheckbox({super.key, required this.agreed, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onChanged(!agreed),
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.tealOp(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.tealOp(0.5),
                width: 1,
              ),
            ),
            child: agreed
                ? const Center(
              child: Text(
                '✓',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                  height: 1,
                ),
              ),
            )
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "I agree to MikuPlay's Terms & Conditions",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.skyOp(0.7),
            ),
          ),
        ),
      ],
    );
  }
}