import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../core/models/song_model.dart';
import '../../../../core/router/app_router.dart';

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
        if (song == null) return const Scaffold(backgroundColor: AppColors.navy, body: Center(child: Text('No song playing', style: TextStyle(color: Colors.white))));

        return Scaffold(
          backgroundColor: AppColors.navy,
          body: Stack(
            children: [
              // Background Decoration
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tealOp(0.1),
                    gradient: RadialGradient(
                      colors: [AppColors.tealOp(0.2), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                right: -100,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFF0609C4).withOpacity(0.3), Colors.transparent],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back, color: AppColors.whiteOp(0.8), size: 20),
                                  const SizedBox(width: 8),
                                  Text('Back', style: TextStyle(color: AppColors.whiteOp(0.8), fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.more_horiz_rounded, color: AppColors.whiteOp(0.8), size: 28),
                            onPressed: () => context.push(Routes.upNext),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Circular Album Art
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
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 15),
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

                    const Spacer(flex: 2),

                    // Title, Artist, Add, Like Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _SmallActionButton(icon: Icons.add_rounded, onTap: () {}),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  song.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Inter',
                                    letterSpacing: -0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${song.artist} • ${song.album}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.skyOp(0.8),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inter',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
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
                                baseBarColor: AppColors.whiteOp(0.15),
                                thumbColor: AppColors.teal,
                                barHeight: 4,
                                thumbRadius: 6,
                                thumbCanPaintOutsideBar: false,
                                timeLabelTextStyle: TextStyle(color: AppColors.whiteOp(0.6), fontSize: 13, fontFamily: 'Inter'),
                                onSeek: audioService.seek,
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.repeat_one_rounded, color: AppColors.whiteOp(0.6), size: 26),
                          ),
                          IconButton(
                            onPressed: () => audioService.skipToPrevious(),
                            icon: const Icon(Icons.skip_previous_rounded, color: AppColors.white, size: 36),
                          ),
                          StreamBuilder<PlayerState>(
                            stream: audioService.playerStateStream,
                            builder: (context, stateSnapshot) {
                              final playing = stateSnapshot.data?.playing ?? false;
                              return GestureDetector(
                                onTap: () => playing ? audioService.pause() : audioService.play(),
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.teal,
                                    boxShadow: [
                                      BoxShadow(color: AppColors.tealOp(0.4), blurRadius: 15, offset: const Offset(0, 5)),
                                    ],
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
                          IconButton(
                            onPressed: () => audioService.skipToNext(),
                            icon: const Icon(Icons.skip_next_rounded, color: AppColors.white, size: 36),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.shuffle_rounded, color: AppColors.whiteOp(0.6), size: 26),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Lyrics Preview Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: GestureDetector(
                        onTap: () => context.push(Routes.lyrics),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                          decoration: BoxDecoration(
                            color: AppColors.whiteOp(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.whiteOp(0.1), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "こんなにそばにいるのに",
                                style: TextStyle(color: AppColors.whiteOp(0.5), fontSize: 14, fontFamily: 'Inter'),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "どうして君は気づかないんだろう",
                                style: TextStyle(color: AppColors.teal, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "気持ちを伝えたいのに",
                                style: TextStyle(color: AppColors.whiteOp(0.5), fontSize: 14, fontFamily: 'Inter'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
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
          color: active ? (color ?? AppColors.teal).withOpacity(0.15) : Colors.transparent,
        ),
        child: Icon(icon, color: color ?? (active ? AppColors.teal : AppColors.whiteOp(0.7)), size: 24),
      ),
    );
  }
}
