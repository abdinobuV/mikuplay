import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MiniPlayer extends StatelessWidget {
  final VoidCallback onTap;
  const MiniPlayer({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 61,
        decoration: BoxDecoration(
          color: AppColors.navySurf, // Menggunakan navySurf agar menyatu dengan background bawah
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.tealOp(0.15), width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 11),
            ClipOval(
              child: Image.asset(
                'assets/images/melt_cover_art.png',
                width: 36, height: 36, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.tealOp(0.2)),
                  child: Center(child: Icon(Icons.music_note_rounded, size: 18, color: AppColors.tealOp(0.7))),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Melt — ryo',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Now Playing',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.teal),
                  ),
                ],
              ),
            ),
            Container(
              width: 30, height: 30,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00748C)),
              child: const Icon(Icons.play_arrow_rounded, size: 20, color: AppColors.white),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.skyOp(0.1),
                border: Border.all(color: AppColors.skyOp(0.3), width: 1),
              ),
              child: Icon(Icons.skip_next_rounded, size: 20, color: AppColors.skyOp(0.8)),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
