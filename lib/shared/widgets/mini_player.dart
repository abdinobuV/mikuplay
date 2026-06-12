import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/models/song_model.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService();

    return StreamBuilder<Song?>(
      stream: audioService.currentSongStream,
      builder: (context, songSnapshot) {
        final song = songSnapshot.data;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => context.push('/now-playing'),
          child: Container(
            height: 72.h,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.navyCard.withValues(alpha: 0.65), // Transparan untuk efek kaca
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.tealOp(0.3), width: 1.5),
                  ),
                  child: Row(
              children: [
                // Album Art (Bulat sesuai gambar baru)
                Hero(
                  tag: 'album-art-${song.id}',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.tealOp(0.1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: song.imageUrl.startsWith('assets/')
                        ? Image.asset(song.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.music_note, color: AppColors.teal))
                        : CachedNetworkImage(
                            imageUrl: song.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const Icon(Icons.music_note, color: AppColors.teal),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title & Artist
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Now Playing',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Controls: Play & Next
                StreamBuilder<PlayerState>(
                  stream: audioService.playerStateStream,
                  builder: (context, stateSnapshot) {
                    final playing = stateSnapshot.data?.playing ?? false;
                    
                    return Row(
                      children: [
                        // Play/Pause Button
                        GestureDetector(
                          onTap: () => playing ? audioService.pause() : audioService.play(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.teal,
                            ),
                            child: Icon(
                              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: AppColors.navy,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Next Button (Sesuai gambar ke-2)
                        GestureDetector(
                          onTap: () => audioService.skipToNext(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.tealOp(0.5), width: 1.5),
                            ),
                            child: const Icon(
                              Icons.skip_next_rounded,
                              color: AppColors.teal,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
},
    );
  }
}
