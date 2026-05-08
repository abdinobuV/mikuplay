import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/splash/splash_screen.dart';

void main() {
  runApp(const MikuPlayApp());
}

class MikuPlayApp extends StatelessWidget {
  const MikuPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MikuPlay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        fontFamily: 'Inter', // Menggunakan font Inter secara global
      ),
      home: const SplashScreen(),
    );
  }
}