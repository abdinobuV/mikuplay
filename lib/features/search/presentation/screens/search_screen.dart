// ============================================================
// FILE INI DISIMPAN DI:
// lib/features/search/presentation/screens/search_screen.dart
//
// BUAT FOLDER JIKA BELUM ADA:
// lib/features/search/
// lib/features/search/presentation/
// lib/features/search/presentation/screens/
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/models/song_model.dart';
import '../../../../core/services/audio_player_service.dart';

// ── Data kategori artis (Figma: Cat/Vocaloid, Cat/LUKA, Cat/KAITO, Cat/GUMI)
class _CategoryData {
  final String name;
  final Color  accentColor;   // warna bar kiri & border
  final Color  bgColor;       // background dengan opacity
  const _CategoryData({
    required this.name,
    required this.accentColor,
    required this.bgColor,
  });
}

// ── Data top chart
class _ChartData {
  final String rank;
  final String title;
  final String subtitle;
  final bool   isTop; // rank 01 = full opacity
  const _ChartData({
    required this.rank,
    required this.title,
    required this.subtitle,
    required this.isTop,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  bool _isLoading = false;
  List<Song> _searchResults = [];

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoading = true);
    final results = await SupabaseService().searchSongs(query);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  // Figma categories dengan warna persis dari desain
  static const _categories = [
    _CategoryData(
      name: 'Hatsune Miku',
      accentColor: Color(0xFF00B4D8), // teal
      bgColor:     Color(0xFF00B4D8),
    ),
    _CategoryData(
      name: 'Megurine Luka',
      accentColor: Color(0xFFBC0D87), // pink magenta
      bgColor:     Color(0xFFBC0D87),
    ),
    _CategoryData(
      name: 'KAITO',
      accentColor: Color(0xFF4D80E5), // blue
      bgColor:     Color(0xFF4D80E5),
    ),
    _CategoryData(
      name: 'GUMI',
      accentColor: Color(0xFF4DCC99), // green
      bgColor:     Color(0xFF4DCC99),
    ),
  ];

  static const _charts = [
    _ChartData(rank: '01', title: 'Hibikase — GigaP',
        subtitle: 'Vocaloid · Trending', isTop: true),
    _ChartData(rank: '02', title: 'Freely Tomorrow — Mitchie M',
        subtitle: 'Vocaloid · Trending', isTop: false),
    _ChartData(rank: '03', title: 'Just Be Friends — Dixie Flatline',
        subtitle: 'Vocaloid · Trending', isTop: false),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // ── Dekorasi kiri (Figma: left=-60, top=202, size=242) ──
          Positioned(
            left: -60, top: 202,
            child: Container(
              width: 242, height: 242,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.07),
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 17),

                // ── Title "Explore" (Figma: left=20, top=61, bold 24px) ──
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Explore',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Search Bar (Figma: left=20, top=101, border=teal 40%) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: AppColors.tealOp(0.4),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search songs or artists...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: AppColors.skyOp(0.4),
                        ),
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.skyOp(0.4),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(99),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(99),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(99),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _performSearch,
                      onChanged: (v) {
                        if (v.isEmpty) {
                          setState(() => _searchResults = []);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Hasil Pencarian atau Konten Default ──
                if (_isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: CircularProgressIndicator(color: AppColors.teal),
                  ))
                else if (_searchResults.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Search Results',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white),
                        ),
                        const SizedBox(height: 14),
                        ..._searchResults.map((song) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              AudioPlayerService().setSong(song);
                              context.push(Routes.nowPlaying);
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(image: NetworkImage(song.imageUrl), fit: BoxFit.cover),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
                        const SizedBox(height: 90),
                      ],
                    ),
                  )
                else ...[
                  // ── Categories header ──────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── 2x2 Category Grid ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Row 1: Hatsune Miku | Megurine Luka
                      Row(
                        children: [
                          Expanded(child: _CategoryCard(
                              data: _categories[0], onTap: () => context.push('${Routes.artist}/miku'))),
                          const SizedBox(width: 17),
                          Expanded(child: _CategoryCard(
                              data: _categories[1], onTap: () => context.push('${Routes.artist}/luka'))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Row 2: KAITO | GUMI
                      Row(
                        children: [
                          Expanded(child: _CategoryCard(
                              data: _categories[2], onTap: () => context.push('${Routes.artist}/kaito'))),
                          const SizedBox(width: 17),
                          Expanded(child: _CategoryCard(
                              data: _categories[3], onTap: () => context.push('${Routes.artist}/gumi'))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── More Artist button (Figma: full width, gradient bg) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () => context.push(Routes.moreArtist),
                    child: Container(
                      height: 61,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF030F65), Color(0xFF032876)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4D80E5).withAlpha((0.4 * 255).toInt()),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Accent bar kiri (Figma: w=4, full height, blue)
                          Positioned(
                            left: 0, top: 0, bottom: 0,
                            child: Container(
                              width: 4,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4D80E5),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          // Accent bar kanan
                          Positioned(
                            right: 0, top: 0, bottom: 0,
                            child: Container(
                              width: 4,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4D80E5),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          // Label center
                          const Center(
                            child: Text(
                              'More Artist',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Top Charts header ──────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Top Charts',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Chart Rows ─────────────────────────────────────
                ...List.generate(_charts.length, (i) => Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, bottom: 13),
                  child: _ChartRow(
                    data: _charts[i],
                    onTap: () {},
                  ),
                )),

                // Space untuk bottom nav
                const SizedBox(height: 90),
              ],
            ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category card dengan accent bar kiri (Figma: h=61, rounded=12) ──
class _CategoryCard extends StatelessWidget {
  final _CategoryData data;
  final VoidCallback  onTap;
  const _CategoryCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 61,
        decoration: BoxDecoration(
          color: data.bgColor.withAlpha((0.15 * 255).toInt()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: data.accentColor.withAlpha((0.4 * 255).toInt()),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Accent bar kiri (Figma: w=4, full height, solid accent color)
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: data.accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft:    Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            // Label
            Positioned(
              left: 13, top: 0, bottom: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  data.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
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

// ── Chart row dengan rank number di kiri (Figma: h=50, rounded=10) ──
class _ChartRow extends StatelessWidget {
  final _ChartData   data;
  final VoidCallback onTap;
  const _ChartRow({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Rank number (Figma: 18px bold, teal full opacity jika 01, 40% lainnya)
        SizedBox(
          width: 36,
          child: Text(
            data.rank,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: data.isTop
                  ? AppColors.teal
                  : AppColors.tealOp(0.4),
            ),
          ),
        ),

        // Chart card (Figma: h=50, bg=card, border=deepCyan 15%, rounded=10)
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.deepCyanOp(0.15),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.only(left: 11, top: 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.skyOp(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}