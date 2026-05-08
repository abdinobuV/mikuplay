// ============================================================
// FILE INI DISIMPAN DI:
// lib/features/auth/presentation/screens/signup_step2_screen.dart
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import 'signup_step1_screen.dart'; // untuk _StepIndicator & _TermsCheckbox

class SignupStep2Screen extends StatefulWidget {
  const SignupStep2Screen({super.key});

  @override
  State<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends State<SignupStep2Screen> {
  File? _pickedImage;
  bool _agreed   = true;   // dari Figma: checkbox sudah tercentang
  bool _isLoading = false;

  // URL foto default dari Figma (node 168:80)
  static const _defaultAvatarUrl =
      'https://www.figma.com/api/mcp/asset/e9d9c913-fea3-4427-a001-5c9751d01bc4';

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
    );
    if (picked != null && mounted) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _createAccount() async {
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
    setState(() => _isLoading = true);
    // TODO: ganti dengan API call sesungguhnya
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // ── Dekorasi kiri atas (Figma: left=-60, top=-61, size=202) ──
          Positioned(
            left: -60, top: -61,
            child: _circle(202),
          ),
          // ── Dekorasi kanan bawah (Figma: left=262, top=606, size=222) ──
          Positioned(
            left: 262, top: 606,
            child: _circle(222),
          ),
          // ── Dekorasi kanan atas (Figma: left=202, top=-61, size=242) ──
          Positioned(
            left: 202, top: -61,
            child: _circle(242, opacity: 0.04),
          ),

          // ── Konten scroll ─────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Back button (Figma: left=20, top=57) ──────
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 13),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.pop(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text(
                          '← Back',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: AppColors.skyOp(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 148),

                  // ── Step indicator (step 2 aktif) ─────────────
                  const Center(
                    child: StepIndicator(activeStep: 2),
                  ),
                  const SizedBox(height: 64),

                  // ── Avatar picker (Figma: center, size=196) ───
                  // node 168:128 — lingkaran teal + foto + pencil
                  Center(child: _AvatarPicker(
                    pickedImage: _pickedImage,
                    defaultUrl: _defaultAvatarUrl,
                    onTap: _pickFromGallery,
                  )),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'Tap to change profile photo',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.skyOp(0.45),
                      ),
                    ),
                  ),

                  const SizedBox(height: 88),

                  // ── Checkbox + button (padding horizontal 28) ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        TermsCheckbox(
                          agreed: _agreed,
                          onChanged: (v) => setState(() => _agreed = v ?? false),
                        ),
                        const SizedBox(height: 22),

                        // ── Create Account button ─────────────────
                        // (Figma: h=52, rounded=99, text="Create Account")
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teal,
                              foregroundColor: AppColors.navy,
                              shape: const StadiumBorder(),
                              elevation: 0,
                              disabledBackgroundColor: AppColors.tealOp(0.5),
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
                              'Create Account',
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
}

// ── Avatar picker widget (sesuai Figma node 168:128–132) ─────
// Lingkaran besar teal, foto di tengah, pencil button pojok kanan atas
class _AvatarPicker extends StatelessWidget {
  final File? pickedImage;
  final String defaultUrl;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.pickedImage,
    required this.defaultUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        children: [
          // ── Ring luar teal (Figma: size=196.2, teal border) ──
          Center(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 196,
                height: 196,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tealOp(0.12),
                  border: Border.all(
                    color: AppColors.tealOp(0.5),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: _avatarContent(),
                ),
              ),
            ),
          ),

          // ── Pencil button (Figma: left=253.96, top=330.13) ───
          // Posisi: pojok kanan atas avatar
          Positioned(
            right: 10,
            top: 10,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 43,
                height: 43,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal,
                ),
                child: const Center(
                  child: Icon(
                    Icons.edit_outlined,
                    size: 22,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarContent() {
    if (pickedImage != null) {
      return Image.file(pickedImage!, fit: BoxFit.cover);
    }
    // Tampilkan foto default dari Figma
    return Image.network(
      defaultUrl,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.card,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.teal,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.card,
        child: const Center(
          child: Icon(Icons.person_outline_rounded,
              size: 72, color: AppColors.sky),
        ),
      ),
    );
  }
}