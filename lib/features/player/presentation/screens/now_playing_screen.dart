import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../core/models/song_model.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService();

    return StreamBuilder<Song?>(
      stream: audioService.currentSongStream,
      builder: (context, songSnapshot) {
        final song = songSnapshot.data;
        if (song == null) return const Scaffold(body: Center(child: Text('No song playing')));

        return Scaffold(
          backgroundColor: AppColors.navy,
          body: Stack(
            children: [
              // Background Decoration
              Positioned(
                top: -150,
                right: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tealOp(0.03),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar (Custom App Bar)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.whiteOp(0.7), size: 20),
                                const SizedBox(width: 8),
                                Text('Back', style: TextStyle(color: AppColors.whiteOp(0.7), fontSize: 16)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.more_horiz_rounded, color: AppColors.whiteOp(0.7), size: 28),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Circular Album Art (Sesuai Figma)
                    Center(
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.tealOp(0.4), width: 1.5),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Hero(
                          tag: 'album-art-${song.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: song.imageUrl.startsWith('assets/')
                                  ? Image.asset(song.imageUrl, fit: BoxFit.cover)
                                  : Image.network(song.imageUrl, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Song Info: Title & Artist
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        children: [
                          Text(
                            song.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${song.artist} • ${song.album}',
                            style: TextStyle(
                              color: AppColors.skyOp(0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons (Add & Like)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SmallActionButton(icon: Icons.add_rounded, onTap: () {}),
                          _SmallActionButton(
                            icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            onTap: () => setState(() => _isLiked = !_isLiked),
                            color: _isLiked ? AppColors.red : null,
                            active: _isLiked,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Progress Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: StreamBuilder<Duration>(
                        stream: audioService.positionStream,
                        builder: (context, positionSnapshot) {
                          final position = positionSnapshot.data ?? Duration.zero;
                          return StreamBuilder<Duration>(
                            stream: audioService.durationStream,
                            builder: (context, durationSnapshot) {
                              final total = durationSnapshot.data ?? Duration.zero;
                              return ProgressBar(
                                progress: position,
                                total: total,
                                progressBarColor: AppColors.teal,
                                baseBarColor: AppColors.whiteOp(0.1),
                                thumbColor: AppColors.teal,
                                barHeight: 4,
                                thumbRadius: 6,
                                thumbCanPaintOutsideBar: false,
                                timeLabelTextStyle: TextStyle(color: AppColors.whiteOp(0.5), fontSize: 13),
                                onSeek: audioService.seek,
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Main Controls Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Seek Backward 10s
                          IconButton(
                            onPressed: () => audioService.seekBackward(),
                            icon: Icon(Icons.replay_10_rounded, color: AppColors.whiteOp(0.6), size: 28),
                          ),
                          // Previous
                          IconButton(
                            onPressed: () => audioService.skipToPrevious(),
                            icon: const Icon(Icons.skip_previous_rounded, color: AppColors.white, size: 36),
                          ),
                          // Play/Pause
                          StreamBuilder<PlayerState>(
                            stream: audioService.playerStateStream,
                            builder: (context, stateSnapshot) {
                              final playing = stateSnapshot.data?.playing ?? false;
                              return GestureDetector(
                                onTap: () => playing ? audioService.pause() : audioService.play(),
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.teal,
                                  ),
                                  child: Icon(
                                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    size: 40,
                                    color: AppColors.navy,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Next
                          IconButton(
                            onPressed: () => audioService.skipToNext(),
                            icon: const Icon(Icons.skip_next_rounded, color: AppColors.white, size: 36),
                          ),
                          // Seek Forward 10s
                          IconButton(
                            onPressed: () => audioService.seekForward(),
                            icon: Icon(Icons.forward_10_rounded, color: AppColors.whiteOp(0.6), size: 28),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Bottom Indicator
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.whiteOp(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool active;

  const _SmallActionButton({
    required this.icon,
    required this.onTap,
    this.color,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: active ? (color ?? AppColors.teal) : AppColors.whiteOp(0.2), width: 1.5),
          color: active ? (color ?? AppColors.teal).withOpacity(0.1) : Colors.transparent,
        ),
        child: Icon(icon, color: color ?? (active ? AppColors.teal : AppColors.whiteOp(0.5)), size: 24),
      ),
    );
  }
}
