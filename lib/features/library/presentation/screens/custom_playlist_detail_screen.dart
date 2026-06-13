import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/song_model.dart';
import '../../../../core/models/custom_playlist_model.dart';
import '../../../../core/services/playlist_service.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomPlaylistDetailScreen extends StatelessWidget {
  final CustomPlaylist playlist;

  const CustomPlaylistDetailScreen({super.key, required this.playlist});

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _playAll(BuildContext context, List<Song> songs) async {
    if (songs.isEmpty) return;
    final audioService = AudioPlayerService();
    audioService.setPlaylist(songs);
    await audioService.setSong(songs.first);
    if (context.mounted) {
      context.push(Routes.nowPlaying);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.teal),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          playlist.name,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            left: -60,
            top: 61,
            child: Container(
              width: 262,
              height: 262,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.06),
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<List<Song>>(
              stream: PlaylistService.instance.streamCustomPlaylistSongs(playlist.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.teal));
                }
                
                final songs = snapshot.data ?? [];

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    // Playlist Header Info
                    Center(
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: AppColors.tealOp(0.1),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: playlist.imageUrl != null && playlist.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: playlist.imageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => const Icon(Icons.queue_music_rounded, color: AppColors.teal, size: 60),
                              ),
                            )
                          : const Icon(Icons.queue_music_rounded, color: AppColors.teal, size: 60),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${songs.length} songs',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.skyOp(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Play Button
                    if (songs.isNotEmpty)
                      GestureDetector(
                        onTap: () => _playAll(context, songs),
                        child: Container(
                          width: 160,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, color: AppColors.navy),
                              SizedBox(width: 8),
                              Text(
                                'Play All',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Songs List
                    Expanded(
                      child: songs.isEmpty
                          ? Center(
                              child: Text(
                                'No songs in this playlist yet.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: AppColors.skyOp(0.6),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: songs.length,
                              itemBuilder: (context, index) {
                                final song = songs[index];
                                return GestureDetector(
                                  onTap: () async {
                                    final audioService = AudioPlayerService();
                                    audioService.setPlaylist(songs);
                                    await audioService.setSong(song);
                                    if (context.mounted) {
                                      context.push(Routes.nowPlaying);
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.deepCyanOp(0.12),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.tealOp(0.1),
                                            border: Border.all(
                                              color: AppColors.tealOp(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: song.imageUrl.startsWith('assets/')
                                                ? Image.asset(song.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Center(child: Icon(Icons.music_note_rounded, color: AppColors.teal, size: 20)))
                                                : CachedNetworkImage(
                                                    imageUrl: song.imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.music_note_rounded, color: AppColors.teal, size: 20)),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                song.title,
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${song.artist} · ${song.album}',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 12,
                                                  color: AppColors.skyOp(0.6),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              _formatDuration(song.duration),
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                                color: AppColors.skyOp(0.6),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: Icon(Icons.remove_circle_outline_rounded, color: AppColors.red.withValues(alpha: 0.7), size: 20),
                                              onPressed: () {
                                                PlaylistService.instance.removeSongFromCustomPlaylist(playlist.id, song.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
