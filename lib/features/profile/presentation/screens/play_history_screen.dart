import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/models/song_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/router/app_router.dart';

class PlayHistoryScreen extends StatelessWidget {
  const PlayHistoryScreen({super.key});

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String _formatTime(DateTime time) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(time.hour)}:${twoDigits(time.minute)}";
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // Background decorations matching the design
          Positioned(
            left: -60, top: 61,
            child: Container(
              width: 262, height: 262,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.tealOp(0.06)),
            ),
          ),
          Positioned(
            left: 262, top: 404,
            child: Container(
              width: 202, height: 202,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.tealOp(0.04)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: StreamBuilder<List<HistoryRecord>>(
                    stream: HistoryService.instance.streamHistoryRecords(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.teal));
                      }
                      
                      final records = snapshot.data ?? [];
                      if (records.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_rounded, size: 80, color: AppColors.tealOp(0.3)),
                              const SizedBox(height: 16),
                              const Text(
                                'No History Yet!',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.teal,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start playing some music\nto see your listening history.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: AppColors.skyOp(0.6),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Group records
                      final now = DateTime.now();
                      final yesterday = now.subtract(const Duration(days: 1));
                      
                      final todayRecords = <HistoryRecord>[];
                      final yesterdayRecords = <HistoryRecord>[];
                      final olderRecords = <HistoryRecord>[];

                      for (var r in records) {
                        if (_isSameDay(r.playedAt, now)) {
                          todayRecords.add(r);
                        } else if (_isSameDay(r.playedAt, yesterday)) {
                          yesterdayRecords.add(r);
                        } else {
                          olderRecords.add(r);
                        }
                      }

                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        children: [
                          if (todayRecords.isNotEmpty) ...[
                            _buildSectionHeader('Today'),
                            const SizedBox(height: 12),
                            ...todayRecords.map((item) => _buildHistoryItem(context, item)),
                            const SizedBox(height: 24),
                          ],
                          
                          if (yesterdayRecords.isNotEmpty) ...[
                            _buildSectionHeader('Yesterday'),
                            const SizedBox(height: 12),
                            ...yesterdayRecords.map((item) => _buildHistoryItem(context, item)),
                            const SizedBox(height: 24),
                          ],
                          
                          if (olderRecords.isNotEmpty) ...[
                            _buildSectionHeader('Older'),
                            const SizedBox(height: 12),
                            ...olderRecords.map((item) => _buildHistoryItem(context, item)),
                            const SizedBox(height: 24),
                          ],

                          _buildClearHistoryButton(),
                          const SizedBox(height: 20),
                        ],
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.deepCyanOp(0.2))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.sky, size: 20),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              'Play History',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.teal,
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, HistoryRecord record) {
    final song = record.song;
    return GestureDetector(
      onTap: () => context.push(Routes.songDetail, extra: song),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.deepCyanOp(0.15)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.1),
                border: Border.all(color: AppColors.tealOp(0.3)),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${song.artist} · ${song.album}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.skyOp(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(record.playedAt),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.skyOp(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDuration(song.duration),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.skyOp(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildClearHistoryButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          HistoryService.instance.clearHistory();
        },
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.red.withValues(alpha: 0.5)),
          ),
          child: const Center(
            child: Text(
              'Clear All History',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
