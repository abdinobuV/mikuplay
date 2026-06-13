import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/custom_playlist_model.dart';
import '../../../../core/services/playlist_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

// ── Filter tab
enum _FilterTab { all, playlist, album, favorites }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  _FilterTab _activeFilter = _FilterTab.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // ── Dekorasi kanan atas ──
          Positioned(
            left: 252,
            top: -40,
            child: Container(
              width: 202,
              height: 202,
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
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final ctrl = TextEditingController();
                              return AlertDialog(
                                backgroundColor: AppColors.card,
                                title: const Text('New Playlist', style: TextStyle(color: AppColors.white, fontFamily: 'Inter')),
                                content: TextField(
                                  controller: ctrl,
                                  style: const TextStyle(color: AppColors.white, fontFamily: 'Inter'),
                                  decoration: InputDecoration(
                                    hintText: 'Playlist Name',
                                    hintStyle: TextStyle(color: AppColors.whiteOp(0.5)),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel', style: TextStyle(color: AppColors.sky, fontFamily: 'Inter')),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (ctrl.text.trim().isNotEmpty) {
                                        PlaylistService.instance.createCustomPlaylist(ctrl.text.trim());
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('Create', style: TextStyle(color: AppColors.teal, fontFamily: 'Inter')),
                                  ),
                                ],
                              );
                            }
                          );
                        },
                        child: Container(
                          width: 34,
                          height: 34,
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

                // ── Filter Pills ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _FilterPill(
                        label: 'All',
                        isActive: _activeFilter == _FilterTab.all,
                        onTap: () => setState(() => _activeFilter = _FilterTab.all),
                      ),
                      const SizedBox(width: 10),
                      _FilterPill(
                        label: 'Playlist',
                        isActive: _activeFilter == _FilterTab.playlist,
                        onTap: () => setState(() => _activeFilter = _FilterTab.playlist),
                      ),
                      const SizedBox(width: 10),
                      _FilterPill(
                        label: 'Favorites',
                        isActive: _activeFilter == _FilterTab.favorites,
                        onTap: () => setState(() => _activeFilter = _FilterTab.favorites),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Playlist List ───────────────────────────────────
                Expanded(
                  child: StreamBuilder<List<CustomPlaylist>>(
                    stream: PlaylistService.instance.streamCustomPlaylists(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.teal));
                      }
                      final playlists = snapshot.data ?? [];
                      if (playlists.isEmpty) {
                        return Center(
                          child: Text(
                            'No playlists yet. Create one!',
                            style: TextStyle(color: AppColors.skyOp(0.6), fontFamily: 'Inter'),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: playlists.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _PlaylistItem(
                          data: playlists[i],
                          onTap: () {
                            context.push(Routes.customPlaylist, extra: playlists[i]);
                          },
                        ),
                      );
                    }
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

// ── Filter pill ──────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
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
              color: isActive ? AppColors.navy : AppColors.sky,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Playlist item ───────────
class _PlaylistItem extends StatelessWidget {
  final CustomPlaylist data;
  final VoidCallback onTap;

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

            // ── Thumbnail icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.tealOp(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.tealOp(0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: data.imageUrl != null && data.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: data.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(Icons.queue_music_rounded, color: AppColors.teal),
                    )
                  : const Center(
                      child: Icon(Icons.queue_music_rounded, color: AppColors.teal),
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
                  Text(
                    '${data.songCount} songs',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.skyOp(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // ── Chevron › ────────────────
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
