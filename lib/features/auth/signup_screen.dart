import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Sign Up for MikuPlay", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Start your music journey today", style: TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator("1", isActive: true),
                  Container(width: 40, height: 2, color: AppColors.surface),
                  _buildStepIndicator("2", isActive: false),
                  Container(width: 40, height: 2, color: AppColors.surface),
                  _buildStepIndicator("3", isActive: false),
                ],
              ),
              const SizedBox(height: 40),
              _buildTextField(label: "Username", hint: "miku_vocal"),
              const SizedBox(height: 20),
              _buildTextField(label: "Email", hint: "miku@vocaloid.jp"),
              const SizedBox(height: 20),
              _buildTextField(label: "Password", hint: "••••••••", isPassword: true),
              const SizedBox(height: 20),
              _buildTextField(label: "Confirm Password", hint: "••••••••", isPassword: true),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {},
                  child: const Text("Continue to Profile", style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String step, {required bool isActive}) {
    return Container(
      width: 30, height: 30,
      decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? AppColors.primary : AppColors.surface),
      child: Center(
        child: Text(step, style: TextStyle(color: isActive ? AppColors.background : AppColors.textGrey, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textGrey),
            filled: true, fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
