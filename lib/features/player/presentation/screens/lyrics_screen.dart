import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/song_model.dart';
import '../../../../core/services/audio_player_service.dart';

class LyricsScreen extends StatelessWidget {
  const LyricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService();

    // Dummy lyrics
    final lyrics = [
      "こんなにそばにいるのに",
      "どうして君は気づかないんだろう",
      "気持ちを伝えたいのに",
      "言葉になってくれない",
      "",
      "Yobarete mo inai no ni",
      "Dare yori saki ni kite shimatta",
      "Kawaii kimi no yokogao",
      "Miharu dake de mune ga itai",
      "Kimi ga suki da to sakebitai",
      "Dakedo hazukashikute",
      "",
      "こんなにそばにいるのに",
      "どうして君は気づかないんだろう",
      "気持ちを伝えたいのに",
      "言葉になってくれない",
      "",
      "Yobarete mo inai no ni",
      "Dare yori saki ni kite shimatta",
      "Kawaii kimi no yokogao",
      "Miharu dake de mune ga itai",
      "Kimi ga suki da to sakebitai",
      "Dakedo hazukashikute",
    ];

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: 100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.tealOp(0.15), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF0609C4).withValues(alpha: 0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
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
                            'Lyrics',
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

                const SizedBox(height: 16),

                // Header
                StreamBuilder<Song?>(
                  stream: audioService.currentSongStream,
                  builder: (context, snapshot) {
                    final song = snapshot.data;
                    return Column(
                      children: [
                        Text(
                          song?.title ?? 'Unknown Song',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song?.artist ?? 'Unknown Artist',
                          style: TextStyle(
                            color: AppColors.skyOp(0.8),
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Scrollable Lyrics
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    itemCount: lyrics.length,
                    itemBuilder: (context, index) {
                      final line = lyrics[index];
                      // Highlight the 6th line as dummy current
                      final isCurrent = index == 5; 
                      return Padding(
                        padding: EdgeInsets.only(bottom: line.isEmpty ? 16.0 : 12.0),
                        child: Text(
                          line,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isCurrent ? AppColors.teal : AppColors.whiteOp(0.5),
                            fontSize: isCurrent ? 18 : 16,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bottom Playing Bar
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.whiteOp(0.08),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.whiteOp(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: StreamBuilder<Song?>(
                stream: audioService.currentSongStream,
                builder: (context, songSnapshot) {
                  final song = songSnapshot.data;
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          song != null ? '${song.title} — ${song.artist}' : 'No song playing',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      StreamBuilder<PlayerState>(
                        stream: audioService.playerStateStream,
                        builder: (context, stateSnapshot) {
                          final playing = stateSnapshot.data?.playing ?? false;
                          return GestureDetector(
                            onTap: () => playing ? audioService.pause() : audioService.play(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.teal,
                              ),
                              child: Icon(
                                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: AppColors.navy,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
