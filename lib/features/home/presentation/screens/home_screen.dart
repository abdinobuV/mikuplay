import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class _TrackData {
  final String title;
  final String artist;
  final String duration;
  final String? imagePath;
  const _TrackData({required this.title, required this.artist, required this.duration, this.imagePath});
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ── Data lagu recently played (dari Figma) ──────────────────
  static const _recentTracks = [
    _TrackData(
      title: 'World is Mine',
      artist: 'ryo',
      duration: '4:09',
      imagePath: 'world_is_mine.png',
    ),
    _TrackData(
      title: 'Decorator',
      artist: 'Livetune',
      duration: '5:02',
      imagePath: 'decorator_art.png',
    ),
    _TrackData(
      title: 'Hibikase',
      artist: 'GigaP',
      duration: '3:58',
      imagePath: 'hibikase_art.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // Dekorasi kanan atas (khusus tab Home)
          Positioned(
            left: 262, top: -61,
            child: Container(
              width: 222, height: 222,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.05),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 44),
              _Navbar(onNotificationTap: () {}),
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _SearchBar(),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Trending Vocaloid'),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _FeaturedCard(onTap: () {}),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Recently Played', showSeeAll: false),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: _recentTracks.map((track) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TrackRow(data: track, onTap: () {}),
                        )).toList(),
                      ),
                    ),
                    // Beri space agar konten tidak tertutup Mini Player di bawah
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showSeeAll = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          if (showSeeAll)
            GestureDetector(
              onTap: () {},
              child: const Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.teal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// WIDGETS
// ══════════════════════════════════════════════════════════════

class _Navbar extends StatelessWidget {
  final VoidCallback onNotificationTap;
  const _Navbar({required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.navy, Color(0xFF0609C4)],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.deepCyanOp(0.2), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 39, height: 39,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.3),
                border: Border.all(color: AppColors.tealOp(0.5), width: 1),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.teal),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Hey, Abdi ',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onNotificationTap,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined, size: 24, color: AppColors.white),
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.tealOp(0.25), width: 1),
      ),
      child: const Center(
        child: Text(
          'Search songs, artists, playlists...',
          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.white),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final VoidCallback onTap;
  const _FeaturedCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.tealOp(0.2), width: 1.5),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 140, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.tealOp(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.tealOp(0.3)),
                    ),
                    child: const Text(
                      'TRENDING',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Melt — ryo',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hatsune Miku · 2007\n808K plays',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.skyOp(0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -40, top: -10, bottom: -10,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha((0.4 * 255).toInt()), blurRadius: 15, spreadRadius: 2),
                    ],
                  ),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/melt_cover_art.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.tealOp(0.2),
                            child: const Icon(Icons.music_note, color: AppColors.teal, size: 40),
                          ),
                        ),
                        Container(color: Colors.black.withAlpha((0.1 * 255).toInt())),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 25, bottom: 15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.5 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '4:33',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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

class _TrackRow extends StatelessWidget {
  final _TrackData   data;
  final VoidCallback onTap;
  const _TrackRow({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 57,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.deepCyanOp(0.15), width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 9),
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.15),
                border: Border.all(color: AppColors.tealOp(0.3), width: 1),
              ),
              child: ClipOval(
                child: data.imagePath != null
                    ? Image.asset(
                        'assets/images/${data.imagePath}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildMusicIcon(),
                      )
                    : _buildMusicIcon(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.artist,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.skyOp(0.7)),
                  ),
                ],
              ),
            ),
            Text(
              data.duration,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.skyOp(0.5)),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicIcon() {
    return Center(child: Icon(Icons.music_note_rounded, size: 18, color: AppColors.tealOp(0.6)));
  }
}
