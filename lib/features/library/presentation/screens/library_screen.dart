// ============================================================
// FILE INI DISIMPAN DI:
// lib/features/library/presentation/screens/library_screen.dart
//
// BUAT FOLDER JIKA BELUM ADA:
// lib/features/library/
// lib/features/library/presentation/
// lib/features/library/presentation/screens/
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// ── Filter tab
enum _FilterTab { all, playlist, album, favorites }

// ── Data playlist (Figma: 5 playlist dengan warna berbeda)
class _PlaylistData {
  final String name;
  final String songCount;
  final Color  thumbColor; // warna icon & border thumbnail
  const _PlaylistData({
    required this.name,
    required this.songCount,
    required this.thumbColor,
  });
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  _FilterTab _activeFilter = _FilterTab.all;

  // Figma: 5 playlist dengan nama, jumlah lagu, dan warna persis dari desain
  static const _playlists = [
    _PlaylistData(
      name: 'Miku Classics',
      songCount: '24 songs',
      thumbColor: Color(0xFF00B4D8), // teal
    ),
    _PlaylistData(
      name: 'Chill Vocaloid',
      songCount: '18 songs',
      thumbColor: Color(0xFF0077B6), // deep cyan
    ),
    _PlaylistData(
      name: 'Kagamine Best',
      songCount: '31 songs',
      thumbColor: Color(0xFFE5B233), // amber
    ),
    _PlaylistData(
      name: 'New Vocaloid',
      songCount: '12 songs',
      thumbColor: Color(0xFF66CC99), // green
    ),
    _PlaylistData(
      name: 'Evening Playlist',
      songCount: '9 songs',
      thumbColor: Color(0xFF8066E5), // purple
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // ── Dekorasi kanan atas (Figma: left=252, top=-40, size=202) ──
          Positioned(
            left: 252, top: -40,
            child: Container(
              width: 202, height: 202,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 17),

                // ── Header: title + add button ─────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title (Figma: 22.2px bold, top=61)
                      const Text(
                        'My Playlists',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      // Add button (Figma: size=34, rounded=99, bg=teal)
                      GestureDetector(
                        onTap: () {
                          // TODO: buka dialog buat playlist baru
                        },
                        child: Container(
                          width: 34, height: 34,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.teal,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Filter Pills (Figma: All=teal, rest=card+border) ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _FilterPill(
                        label: 'All',
                        isActive: _activeFilter == _FilterTab.all,
                        onTap: () => setState(
                                () => _activeFilter = _FilterTab.all),
                      ),
                      const SizedBox(width: 10),
                      _FilterPill(
                        label: 'Playlist',
                        isActive: _activeFilter == _FilterTab.playlist,
                        onTap: () => setState(
                                () => _activeFilter = _FilterTab.playlist),
                      ),
                      const SizedBox(width: 10),
                      _FilterPill(
                        label: 'Album',
                        isActive: _activeFilter == _FilterTab.album,
                        onTap: () => setState(
                                () => _activeFilter = _FilterTab.album),
                      ),
                      const SizedBox(width: 10),
                      _FilterPill(
                        label: 'Favorites',
                        isActive: _activeFilter == _FilterTab.favorites,
                        onTap: () => setState(
                                () => _activeFilter = _FilterTab.favorites),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Playlist List ───────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _playlists.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _PlaylistItem(
                      data: _playlists[i],
                      onTap: () {
                        // TODO: navigate ke detail playlist
                      },
                    ),
                  ),
                ),

                // Space untuk bottom nav
                const SizedBox(height: 90),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter pill (Figma: h=30, rounded=99) ──────────────────────
class _FilterPill extends StatelessWidget {
  final String       label;
  final bool         isActive;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          // Figma: aktif = teal solid, tidak aktif = card + sky border
          color: isActive ? AppColors.teal : AppColors.card,
          borderRadius: BorderRadius.circular(99),
          border: isActive
              ? null
              : Border.all(color: AppColors.skyOp(0.3), width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              // Figma: aktif=navy, tidak aktif=sky
              color: isActive ? AppColors.navy : AppColors.sky,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Playlist item (Figma: h=69, rounded=14, bg=card) ───────────
class _PlaylistItem extends StatelessWidget {
  final _PlaylistData data;
  final VoidCallback  onTap;

  const _PlaylistItem({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 69,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.deepCyanOp(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 9),

            // ── Thumbnail icon (Figma: size=48, rounded=10, colored)
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: data.thumbColor.withAlpha((0.2 * 255).toInt()),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: data.thumbColor.withAlpha((0.4 * 255).toInt()),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '♫',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: data.thumbColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),

            // ── Info ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nama playlist (Figma: 14.1px semi bold)
                  Text(
                    data.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Jumlah lagu (Figma: 11.1px, sky 60%)
                  Text(
                    data.songCount,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.skyOp(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // ── Chevron › (Figma: 18.2px, sky 30%) ────────────────
            Text(
              '›',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.skyOp(0.3),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}