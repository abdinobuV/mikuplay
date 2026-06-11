import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class _HistoryItem {
  final String title;
  final String artist;
  final String time;
  final String duration;
  final bool isLiked;

  const _HistoryItem({
    required this.title,
    required this.artist,
    required this.time,
    required this.duration,
    required this.isLiked,
  });
}

class PlayHistoryScreen extends StatelessWidget {
  const PlayHistoryScreen({super.key});

  static const _todayHistory = [
    _HistoryItem(title: 'Melt', artist: 'ryo · Miku', time: '09:41', duration: '4:33', isLiked: true),
    _HistoryItem(title: 'World is Mine', artist: 'ryo · Miku', time: '09:20', duration: '4:09', isLiked: false),
    _HistoryItem(title: 'Decorator', artist: 'Livetune · Miku', time: '08:55', duration: '5:02', isLiked: true),
  ];

  static const _yesterdayHistory = [
    _HistoryItem(title: 'Hibikase', artist: 'GigaP · Miku', time: '3:58', duration: '3:58', isLiked: false),
    _HistoryItem(title: 'Rolling Girl', artist: 'wowaka · Miku', time: '3:30', duration: '3:30', isLiked: true),
    _HistoryItem(title: 'Just Be Friends', artist: 'Dixie Flatline', time: '4:48', duration: '4:48', isLiked: false),
    _HistoryItem(title: 'Freely Tomorrow', artist: 'Mitchie M · Miku', time: '4:31', duration: '4:31', isLiked: true),
  ];

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
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      _buildSectionHeader('Today'),
                      const SizedBox(height: 12),
                      ..._todayHistory.map((item) => _buildHistoryItem(item)),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Yesterday'),
                      const SizedBox(height: 12),
                      ..._yesterdayHistory.map((item) => _buildHistoryItem(item)),
                      const SizedBox(height: 32),
                      _buildClearHistoryButton(),
                      const SizedBox(height: 20),
                    ],
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

  Widget _buildHistoryItem(_HistoryItem item) {
    return Container(
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
            child: const Center(
              child: Icon(Icons.music_note, color: AppColors.teal, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.artist,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.skyOp(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.time,
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
                  Icon(
                    item.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: item.isLiked ? AppColors.red : AppColors.skyOp(0.4),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.duration,
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
    );
  }

  Widget _buildClearHistoryButton() {
    return Center(
      child: GestureDetector(
        onTap: () {},
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
