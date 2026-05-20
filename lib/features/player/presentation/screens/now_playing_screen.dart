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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: const Text(
              'Song Detail',
              style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(height: 10),
                        // Album Art
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.tealOp(0.1), width: 1),
                                ),
                              ),
                              Hero(
                                tag: 'album-art-${song.id}',
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.tealOp(0.2),
                                        blurRadius: 30,
                                        spreadRadius: 5,
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
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Song Title & Artist
                        Column(
                          children: [
                            Text(
                              song.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${song.artist} · ${song.album} · ${song.year}',
                              style: TextStyle(color: AppColors.skyOp(0.7), fontSize: 14),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ActionButton(
                              icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              label: 'Like',
                              color: _isLiked ? AppColors.red : AppColors.whiteOp(0.6),
                              onTap: () => setState(() => _isLiked = !_isLiked),
                            ),
                            const _ActionButton(icon: Icons.add_rounded, label: 'Add'),
                            const _ActionButton(icon: Icons.download_rounded, label: 'Download'),
                            const _ActionButton(icon: Icons.more_horiz_rounded, label: 'More'),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Visualizer
                        SizedBox(
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(20, (index) {
                              return Container(
                                width: 4,
                                height: 8 + (index % 4) * 5.0,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: index < 10 ? AppColors.teal : AppColors.skyOp(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Progress Bar
                        StreamBuilder<Duration>(
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
                                  timeLabelTextStyle: TextStyle(color: AppColors.skyOp(0.5), fontSize: 12),
                                  onSeek: audioService.seek,
                                );
                              },
                            );
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(value: '${song.plays ~/ 1000}K', label: 'Plays'),
                            _StatItem(value: '${song.likedCount ~/ 1000}K', label: 'Liked'),
                            _StatItem(value: song.year, label: 'Year'),
                            _StatItem(value: _formatDuration(song.duration), label: 'Duration'),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Play Button
                        StreamBuilder<PlayerState>(
                          stream: audioService.playerStateStream,
                          builder: (context, stateSnapshot) {
                            final playing = stateSnapshot.data?.playing ?? false;
                            return ElevatedButton.icon(
                              onPressed: () => playing ? audioService.pause() : audioService.play(),
                              icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 28),
                              label: Text(playing ? 'PAUSE' : 'PLAY NOW'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teal,
                                foregroundColor: AppColors.navy,
                                minimumSize: const Size(double.infinity, 56),
                                shape: const StadiumBorder(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.navyCard,
              border: Border.all(color: AppColors.whiteOp(0.1)),
            ),
            child: Icon(icon, color: color ?? AppColors.whiteOp(0.6), size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color ?? AppColors.skyOp(0.5), fontSize: 11)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: AppColors.skyOp(0.5), fontSize: 11)),
      ],
    );
  }
}
