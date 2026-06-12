import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/song_model.dart';
import '../../../../core/services/audio_player_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LrcLine {
  final Duration time;
  final String text;

  LrcLine({required this.time, required this.text});
}

class ResponsiveLyricsView extends StatefulWidget {
  final Song song;
  final VoidCallback onClose;

  const ResponsiveLyricsView({super.key, required this.song, required this.onClose});

  @override
  State<ResponsiveLyricsView> createState() => _ResponsiveLyricsViewState();
}

class _ResponsiveLyricsViewState extends State<ResponsiveLyricsView> {
  final List<LrcLine> _lyrics = [];
  final ScrollController _scrollController = ScrollController();
  final itemHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _parseLyrics();
  }

  void _parseLyrics() {
    if (widget.song.lyrics == null || widget.song.lyrics!.isEmpty) return;
    
    final lines = widget.song.lyrics!.split('\n');
    final RegExp timeRegex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]');

    for (var line in lines) {
      final match = timeRegex.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds = int.parse(match.group(3)!.padRight(3, '0'));
        
        final text = line.substring(match.end).trim();
        if (text.isNotEmpty) {
          _lyrics.add(LrcLine(
            time: Duration(minutes: minutes, seconds: seconds, milliseconds: milliseconds),
            text: text,
          ));
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveLine(int index) {
    if (_scrollController.hasClients && index >= 0) {
      // Calculate scroll position to center the active line
      final screenHeight = MediaQuery.of(context).size.height;
      final targetOffset = (index * itemHeight) - (screenHeight / 2) + (itemHeight / 2) + 100;
      
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: widget.song.imageUrl.startsWith('assets/')
                ? Image.asset(widget.song.imageUrl, fit: BoxFit.cover)
                : CachedNetworkImage(
                    imageUrl: widget.song.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(color: AppColors.navy),
                  ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          
          // Header
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24), // Extra top margin to prevent clipping
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
                        onPressed: widget.onClose,
                      ),
                      const Text(
                        'Lyrics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the title
                    ],
                  ),
                ),
                
                // Lyrics List
                Expanded(
                  child: _lyrics.isEmpty
                      ? const Center(
                          child: Text(
                            "No lyrics available",
                            style: TextStyle(color: Colors.white54, fontSize: 18),
                          ),
                        )
                      : StreamBuilder<Duration>(
                          stream: AudioPlayerService().positionStream,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            
                            // Find active line index
                            int activeIndex = -1;
                            for (int i = 0; i < _lyrics.length; i++) {
                              if (position >= _lyrics[i].time) {
                                activeIndex = i;
                              } else {
                                break;
                              }
                            }

                            // Auto scroll to active line
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToActiveLine(activeIndex);
                            });

                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(top: 100, bottom: 200, left: 24, right: 24),
                              itemCount: _lyrics.length,
                              itemBuilder: (context, index) {
                                final isActive = index == activeIndex;
                                final isPassed = index < activeIndex;

                                return GestureDetector(
                                  onTap: () {
                                    AudioPlayerService().seek(_lyrics[index].time);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: itemHeight,
                                    alignment: Alignment.centerLeft,
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(
                                        begin: isActive ? 0.0 : 1.5,
                                        end: isActive ? 0.0 : 1.5,
                                      ),
                                      duration: const Duration(milliseconds: 300),
                                      builder: (context, blur, child) {
                                        return ImageFiltered(
                                          imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                                          child: child,
                                        );
                                      },
                                      child: Text(
                                        _lyrics[index].text,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: isActive ? 28 : 24,
                                          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                                          color: isActive 
                                              ? Colors.white 
                                              : (isPassed ? Colors.white.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.3)),
                                          height: 1.2,
                                          shadows: isActive ? [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.5),
                                              blurRadius: 10,
                                            )
                                          ] : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
