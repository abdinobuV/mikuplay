import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class MoreArtistScreen extends StatelessWidget {
  const MoreArtistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back,
                        color: AppColors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: AppColors.skyOp(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // List of Artists
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  _ArtistCard(
                    name: 'Emu Otori',
                    imagePath: 'assets/images/artists/otori.png',
                    color: const Color.fromARGB(255, 228, 25, 147),
                    onTap: () => context.push('/artist/otori'),
                  ),
                  const SizedBox(height: 24),
                  _ArtistCard(
                    name: 'Hoshino Ichika',
                    imagePath: 'assets/images/artists/ichika.png',
                    color: const Color(0xFF4D80E5),
                    onTap: () => context.push('/artist/ichika'),
                  ),
                  const SizedBox(height: 24),
                  _ArtistCard(
                    name: 'Kagamine Rin',
                    imagePath: 'assets/images/artists/rin.png',
                    color: const Color(0xFFFAC515),
                    onTap: () => context.push('/artist/rin'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final Color color;
  final VoidCallback onTap;

  const _ArtistCard({
    required this.name,
    required this.imagePath,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 140,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Card Background
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 20,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // Character Image (Placeholder using Icon if not found)
            Positioned(
              right: 16,
              bottom: 30, // To sit above the bottom bar
              child: SizedBox(
                width: 100,
                height: 140,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person, size: 60, color: color),
                    );
                  },
                ),
              ),
            ),

            // Bottom Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.9),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
