import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/song_model.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../core/services/playlist_service.dart';
import '../../../../core/services/download_service.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/responsive_lyrics_view.dart';
import '../widgets/add_to_playlist_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';

class SongDetailScreen extends StatefulWidget {
  final Song? song;
  const SongDetailScreen({super.key, required this.song});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  bool _isDownloading = false;
  Color? _dominantColor;

  @override
  void initState() {
    super.initState();
    _extractDominantColor();
  }

  Future<void> _extractDominantColor() async {
    if (widget.song == null) return;
    final imageUrl = widget.song!.imageUrl;
    
    ImageProvider imageProvider;
    if (imageUrl.startsWith('assets/')) {
      imageProvider = AssetImage(imageUrl);
    } else {
      imageProvider = CachedNetworkImageProvider(imageUrl);
    }

    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 20,
      );
      if (mounted) {
        setState(() {
          _dominantColor = paletteGenerator.dominantColor?.color;
        });
      }
    } catch (e) {
      debugPrint('Failed to extract color: $e');
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(0)}K';
    return number.toString();
  }

  void _showLyrics() {
    if (widget.song == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResponsiveLyricsView(
        song: widget.song!,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    if (song == null) return const Scaffold(body: Center(child: Text('Song not found')));

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 15) {
            Navigator.pop(context);
          }
        },
        child: Stack(
        children: [
          // Ambient background glow based on cover
          Positioned(
            top: -150,
            left: -50,
            right: -50,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _dominantColor?.withValues(alpha: 0.3) ?? AppColors.tealOp(0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.arrow_back, color: AppColors.whiteOp(0.7), size: 24),
                          ),
                        ),
                        const Text(
                          'Song Detail',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(width: 40), // Balance the title
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Album Art with glowing effects
                  Center(
                    child: Hero(
                      tag: 'album-art-${song.id}',
                      child: Container(
                        width: 240.w,
                        height: 240.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (_dominantColor != null)
                              BoxShadow(
                                color: _dominantColor!.withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: 0,
                              ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 30,
                              spreadRadius: 8,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: song.imageUrl.startsWith('assets/')
                              ? Image.asset(song.imageUrl, fit: BoxFit.cover)
                              : CachedNetworkImage(
                                  imageUrl: song.imageUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => const Icon(Icons.music_note, color: AppColors.teal),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title & Artist
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        Text(
                          song.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${song.artist} • ${song.album} ${song.year.isNotEmpty ? "• ${song.year}" : ""}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.skyOp(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 4 Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StreamBuilder<bool>(
                        stream: PlaylistService.instance.isFavorite(song.id),
                        builder: (context, snapshot) {
                          final isLiked = snapshot.data ?? false;
                          return _ActionBtn(
                            icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            label: 'Like',
                            color: isLiked ? AppColors.red : null,
                            isActive: isLiked,
                            onTap: () => PlaylistService.instance.toggleFavorite(song),
                          );
                        }
                      ),
                      const SizedBox(width: 24),
                      _ActionBtn(
                        icon: Icons.add, 
                        label: 'Add', 
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AddToPlaylistBottomSheet(song: song),
                          );
                        }
                      ),
                      const SizedBox(width: 24),
                      _isDownloading 
                          ? const SizedBox(width: 48, child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2))))
                          : _ActionBtn(
                              icon: Icons.download_rounded, 
                              label: 'Download', 
                              onTap: () async {
                                setState(() => _isDownloading = true);
                                final success = await DownloadService.instance.downloadSong(song, null);
                                setState(() => _isDownloading = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success ? 'Download complete' : 'Download failed'),
                                      backgroundColor: success ? AppColors.teal : AppColors.red,
                                    )
                                  );
                                }
                              }
                            ),
                      const SizedBox(width: 24),
                      _ActionBtn(icon: Icons.lyrics_rounded, label: 'Lyrics', onTap: _showLyrics),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Waveform Dummy
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      children: [
                        // Responsive Animated Waveform
                        _AnimatedWaveform(song: song),
                        const SizedBox(height: 8),
                        StreamBuilder<Duration>(
                          stream: AudioPlayerService().positionStream,
                          builder: (context, snapshot) {
                            final currentSong = AudioPlayerService().currentSong;
                            final isCurrentSong = currentSong?.id == song.id;
                            final position = isCurrentSong ? (snapshot.data ?? Duration.zero) : Duration.zero;
                            
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(position), style: const TextStyle(color: AppColors.teal, fontSize: 12)),
                                Text(_formatDuration(song.duration), style: TextStyle(color: AppColors.whiteOp(0.5), fontSize: 12)),
                              ],
                            );
                          }
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Stats Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatItem(value: _formatNumber(song.plays == 0 ? 808000 : song.plays), label: 'Plays'),
                        _StatItem(value: _formatNumber(song.likedCount == 0 ? 42000 : song.likedCount), label: 'Liked'),
                        _StatItem(value: song.year.isEmpty ? '2007' : song.year, label: 'Year'),
                        _StatItem(value: _formatDuration(song.duration), label: 'Duration'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Play Now Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: GestureDetector(
                      onTap: () async {
                        await AudioPlayerService().setSong(song);
                        if (context.mounted) {
                          context.push(Routes.nowPlaying);
                        }
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.tealOp(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, color: AppColors.navy, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Play Now',
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? (color ?? AppColors.teal).withValues(alpha: 0.15) : AppColors.whiteOp(0.05),
              border: Border.all(
                color: isActive ? (color ?? AppColors.teal) : AppColors.whiteOp(0.1),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color ?? (isActive ? AppColors.teal : AppColors.whiteOp(0.7)), size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? (color ?? AppColors.teal) : AppColors.whiteOp(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
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
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.skyOp(0.6),
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _AnimatedWaveform extends StatefulWidget {
  final Song song;
  const _AnimatedWaveform({required this.song});

  @override
  State<_AnimatedWaveform> createState() => _AnimatedWaveformState();
}

class _AnimatedWaveformState extends State<_AnimatedWaveform> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _audioService = AudioPlayerService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSeek(double dx, double maxWidth) async {
    final fraction = (dx / maxWidth).clamp(0.0, 1.0);
    final seekPosition = Duration(milliseconds: (widget.song.duration.inMilliseconds * fraction).round());
    
    if (_audioService.currentSong?.id != widget.song.id) {
      await _audioService.setSong(widget.song);
    }
    await _audioService.seek(seekPosition);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate how many bars can fit.
        // Each bar is 3px wide with 1.5px margin on each side = 6px total per bar.
        final int barCount = (constraints.maxWidth / 6).floor();

        return StreamBuilder<Duration>(
          stream: _audioService.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final isCurrentSong = _audioService.currentSong?.id == widget.song.id;
            
            final double currentFraction = isCurrentSong 
                ? (position.inMilliseconds / (widget.song.duration.inMilliseconds > 0 ? widget.song.duration.inMilliseconds : 1)).clamp(0.0, 1.0)
                : 0.0;
            
            final int highlightedBars = (barCount * currentFraction).round();

            return GestureDetector(
              onTapDown: (details) => _handleSeek(details.localPosition.dx, constraints.maxWidth),
              onPanUpdate: (details) => _handleSeek(details.localPosition.dx, constraints.maxWidth),
              child: Container(
                height: 36, // Max height for the waveform
                color: Colors.transparent, // Important for gesture detection
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(barCount, (index) {
                    // Create an organic looking initial height
                    final baseHeight = 10.0 + (index % 5) * 3.0 + (index % 7) * 2.0;
                    final isPlayed = index < highlightedBars;

                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        // Add a subtle sine wave offset based on the index and animation time
                        // to create a breathing/moving effect.
                        final offset = (index * 0.2) + (_controller.value * 2 * 3.14159);
                        final animatedHeight = isCurrentSong
                          ? baseHeight + (5 * (0.5 * (1 + (offset % 2.0 - 1.0).abs()))) // Animate if playing
                          : baseHeight;

                        return Container(
                          width: 3,
                          height: animatedHeight > 36 ? 36 : animatedHeight,
                          decoration: BoxDecoration(
                            color: isPlayed ? AppColors.teal : AppColors.whiteOp(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            );
          }
        );
      },
    );
  }
}
