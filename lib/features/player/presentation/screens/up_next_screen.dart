import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/song_model.dart';
import '../../../../core/services/audio_player_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UpNextScreen extends StatelessWidget {
  const UpNextScreen({super.key});

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService();

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back, color: AppColors.whiteOp(0.8), size: 24),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Up Next',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Now Playing Card
            StreamBuilder<Song?>(
              stream: audioService.currentSongStream,
              builder: (context, snapshot) {
                final currentSong = snapshot.data;
                if (currentSong == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.whiteOp(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.tealOp(0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: currentSong.imageUrl.startsWith('assets/')
                                ? Image.asset(currentSong.imageUrl, fit: BoxFit.cover)
                                : CachedNetworkImage(
                                    imageUrl: currentSong.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${currentSong.title} — ${currentSong.artist}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'now playing',
                                style: TextStyle(
                                  color: AppColors.teal,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.whiteOp(0.1),
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: AppColors.teal, size: 24),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Up Next Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Up Next',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Playlist Queue
            Expanded(
              child: StreamBuilder<List<Song>>(
                stream: audioService.playlistStream,
                builder: (context, playlistSnapshot) {
                  final playlist = playlistSnapshot.data ?? [];
                  return StreamBuilder<Song?>(
                    stream: audioService.currentSongStream,
                    builder: (context, currentSongSnapshot) {
                      final currentSong = currentSongSnapshot.data;
                      
                      // Find upcoming songs
                      int currentIndex = -1;
                      if (currentSong != null) {
                        currentIndex = playlist.indexWhere((s) => s.id == currentSong.id);
                      }
                      
                      final upNextSongs = currentIndex != -1 && currentIndex < playlist.length - 1
                          ? playlist.sublist(currentIndex + 1)
                          : playlist;

                      if (upNextSongs.isEmpty) {
                        return Center(
                          child: Text(
                            'No upcoming songs in queue',
                            style: TextStyle(color: AppColors.whiteOp(0.5), fontFamily: 'Inter'),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        itemCount: upNextSongs.length,
                        itemBuilder: (context, index) {
                          final song = upNextSongs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.whiteOp(0.05),
                                    border: Border.all(color: AppColors.whiteOp(0.1)),
                                  ),
                                  child: ClipOval(
                                    child: song.imageUrl.startsWith('assets/')
                                        ? Image.asset(song.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.music_note, color: AppColors.teal))
                                        : CachedNetworkImage(
                                            imageUrl: song.imageUrl,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url, error) => const Icon(Icons.music_note, color: AppColors.teal),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Inter',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        song.artist,
                                        style: TextStyle(
                                          color: AppColors.skyOp(0.6),
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatDuration(song.duration),
                                  style: TextStyle(
                                    color: AppColors.skyOp(0.6),
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
