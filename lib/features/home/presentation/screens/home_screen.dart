// ============================================================
// FILE INI DISIMPAN DI:
// lib/features/home/presentation/screens/home_screen.dart
//
// BUAT FOLDER BARU JIKA BELUM ADA:
// lib/features/home/
// lib/features/home/presentation/
// lib/features/home/presentation/screens/
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0; // 0=Home, 1=Search, 2=Library, 3=Profile

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
          // ── Dekorasi kanan atas (Figma: left=262, top=-61, size=222) ──
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

          // ── Konten scroll utama ───────────────────────────────
          Column(
            children: [
              // Status bar space
              const SizedBox(height: 44),

              // ── Navbar (Figma: top=44, h=65) ─────────────────
              _Navbar(
                onNotificationTap: () {},
              ),

              // ── Scrollable content ────────────────────────────
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 16),

                    // ── Search Bar (Figma: left=20, top=125) ─────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const _SearchBar(),
                    ),
                    const SizedBox(height: 20),

                    // ── Trending Vocaloid header ──────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Trending Vocaloid',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
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
                    ),
                    const SizedBox(height: 10),

                    // ── Featured Card (Figma: h=141, rounded=16) ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _FeaturedCard(
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Recently Played header ────────────────────
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Recently Played',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Track List ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: _recentTracks.map((track) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TrackRow(
                            data: track,
                            onTap: () {},
                          ),
                        )).toList(),
                      ),
                    ),

                    // Space untuk mini player + bottom nav
                    const SizedBox(height: 160),
                  ],
                ),
              ),
            ],
          ),

          // ── Mini Player (Figma: top=711, h=61) ───────────────
          // Menempel di atas bottom nav
          Positioned(
            left: 0, right: 0,
            bottom: 77, // tinggi bottom nav
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _MiniPlayer(
                onTap: () {},
              ),
            ),
          ),

          // ── Bottom Navigation Bar ─────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomNavBar(
              selectedIndex: _selectedNavIndex,
              onTap: (i) => setState(() => _selectedNavIndex = i),
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

// ── Navbar (Figma: gradient bg, avatar, name, bell) ────────────
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
          colors: [Color(0xFF03045E), Color(0xFF0609C4)],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.deepCyanOp(0.2),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // ── Avatar (Figma: size=39, lingkaran) ──
            Container(
              width: 39, height: 39,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.3),
                border: Border.all(
                  color: AppColors.tealOp(0.5),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 22,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Greeting ──────────────────────────────────────
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

            // ── Bell icon dengan notif dot ─────────────────────
            GestureDetector(
              onTap: onNotificationTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: AppColors.white,
                  ),
                  // Notif dot merah (Figma: size=8, red)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.red,
                      ),
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

// ── Search Bar (Figma: rounded=99, bg=card, border=teal) ───────
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: navigate ke search screen
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: AppColors.tealOp(0.25),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'Search songs, artists, playlists...',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.skyOp(0.4),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Featured Card (Figma: h=141, rounded=16) ───────────────────
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
          border: Border.all(
            color: AppColors.tealOp(0.2),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // ── Konten teks kiri ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 140, 0), // beri ruang untuk gambar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TRENDING badge
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
                  // Title
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
                  // Subtitle (lebih terang agar terbaca)
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

            // ── Album art (Setengah lingkaran) ──────────────────
            Positioned(
              right: -40, // geser keluar untuk efek setengah lingkaran
              top: -10,
              bottom: -10,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
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
                        // Overlay sedikit gelap agar teks durasi kontras
                        Container(color: Colors.black.withOpacity(0.1)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Durasi (di atas lingkaran) ─────────────────
            Positioned(
              right: 25,
              bottom: 15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
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

// ── Track Row (Figma: h=57, rounded=12, bg=card) ───────────────
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
          border: Border.all(
            color: AppColors.deepCyanOp(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 9),

            // ── Thumbnail (Figma: size=38, lingkaran) ─
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.15),
                border: Border.all(
                  color: AppColors.tealOp(0.3),
                  width: 1,
                ),
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

            // ── Teks ──────────────────────────────────────────
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
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.skyOp(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // ── Durasi ────────────────────────────────────────
            Text(
              data.duration,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.skyOp(0.5),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicIcon() {
    return Center(
      child: Icon(
        Icons.music_note_rounded,
        size: 18,
        color: AppColors.tealOp(0.6),
      ),
    );
  }
}

// ── Mini Player (Figma: h=61, rounded=14) ──────────────────────
class _MiniPlayer extends StatelessWidget {
  final VoidCallback onTap;
  const _MiniPlayer({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 61,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.tealOp(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 11),

            // ── Album art mini (Figma: size=36) ────
            ClipOval(
              child: Image.asset(
                'assets/images/melt_cover_art.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tealOp(0.2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.music_note_rounded,
                      size: 18,
                      color: AppColors.tealOp(0.7),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // ── Info ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Melt — ryo',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Now Playing',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),

            // ── Play button (Figma: bg=#00748C, size=30) ───────
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00748C),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 20,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 8),

            // ── Next button (Figma: bg=sky 10%, border=sky 30%) ─
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.skyOp(0.1),
                border: Border.all(
                  color: AppColors.skyOp(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.skip_next_rounded,
                size: 20,
                color: AppColors.skyOp(0.8),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicIcon() {
    return Center(
      child: Icon(
        Icons.music_note_rounded,
        size: 18,
        color: AppColors.tealOp(0.6),
      ),
    );
  }
}

// ── Bottom Navigation Bar (Figma: h=77, bg=#050933) ────────────
class _BottomNavBar extends StatelessWidget {
  final int          selectedIndex;
  final ValueChanged<int> onTap;
  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_filled,        label: 'Home'),
    _NavItem(icon: Icons.search_rounded,     label: 'Search'),
    _NavItem(icon: Icons.library_music_rounded, label: 'Library'),
    _NavItem(icon: Icons.person_rounded,     label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 77,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.deepCyanOp(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final isActive = i == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _items[i].icon,
                    size: 24,
                    color: isActive ? AppColors.teal : AppColors.white,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _items[i].label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: isActive ? AppColors.teal : AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DATA MODELS
// ══════════════════════════════════════════════════════════════

class _TrackData {
  final String title;
  final String artist;
  final String duration;
  final String? imagePath;

  const _TrackData({
    required this.title,
    required this.artist,
    required this.duration,
    this.imagePath,
  });
}

class _NavItem {
  final IconData icon;
  final String   label;
  const _NavItem({required this.icon, required this.label});
}