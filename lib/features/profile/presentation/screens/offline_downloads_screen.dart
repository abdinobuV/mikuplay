import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/download_service.dart';
import '../../../../core/models/song_model.dart';
import 'package:disk_space_2/disk_space_2.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OfflineDownloadsScreen extends StatefulWidget {
  const OfflineDownloadsScreen({super.key});

  @override
  State<OfflineDownloadsScreen> createState() => _OfflineDownloadsScreenState();
}

class _OfflineDownloadsScreenState extends State<OfflineDownloadsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Songs'];

  List<Song> _downloadedSongs = [];
  bool _isLoading = true;

  double _totalDiskSpaceMB = 0;
  double _freeDiskSpaceMB = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final total = await DiskSpace.getTotalDiskSpace;
      final free = await DiskSpace.getFreeDiskSpace;
      
      final songs = await DownloadService.instance.getDownloadedSongs();
      
      if (mounted) {
        setState(() {
          _totalDiskSpaceMB = total ?? 0;
          _freeDiskSpaceMB = free ?? 0;
          _downloadedSongs = songs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading offline downloads: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteSong(Song song) async {
    final success = await DownloadService.instance.deleteDownload(song);
    if (success) {
      await _loadData(); // refresh list and storage
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${song.title} removed from downloads', style: const TextStyle(fontFamily: 'Inter')),
            backgroundColor: AppColors.teal,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate storage
    final usedDiskSpaceMB = _totalDiskSpaceMB - _freeDiskSpaceMB;
    final usedPercentage = _totalDiskSpaceMB > 0 ? (usedDiskSpaceMB / _totalDiskSpaceMB) : 0.0;
    
    // Formatting to GB if > 1000 MB
    String _formatStorage(double mb) {
      if (mb >= 1000) {
        return '${(mb / 1024).toStringAsFixed(1)} GB';
      }
      return '${mb.toStringAsFixed(0)} MB';
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.teal),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Offline Downloads',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            left: -60,
            top: 61,
            child: Container(
              width: 262,
              height: 262,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.06),
              ),
            ),
          ),
          Positioned(
            left: 262,
            top: 404,
            child: Container(
              width: 202,
              height: 202,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.04),
              ),
            ),
          ),
          
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
                : Column(
                    children: [
                      const SizedBox(height: 10),
                      // Storage Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.deepCyanOp(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Storage Used',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppColors.skyOp(0.8),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _formatStorage(usedDiskSpaceMB),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'of ${_formatStorage(_totalDiskSpaceMB)}',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: AppColors.skyOp(0.6),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppColors.navy,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: usedPercentage.clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.teal,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${(usedPercentage * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      color: AppColors.teal,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Filters
                      SizedBox(
                        height: 32,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          itemBuilder: (context, index) {
                            final isSelected = index == _selectedFilterIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFilterIndex = index;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.teal : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppColors.teal : AppColors.skyOp(0.3),
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _filters[index],
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected ? AppColors.navy : AppColors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Downloads List
                      Expanded(
                        child: _downloadedSongs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.download_done_rounded, size: 80, color: AppColors.tealOp(0.3)),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No Downloads Yet',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.whiteOp(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _downloadedSongs.length,
                                itemBuilder: (context, index) {
                                  final song = _downloadedSongs[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.deepCyanOp(0.12),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Cover
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.tealOp(0.1),
                                            border: Border.all(
                                              color: AppColors.tealOp(0.3),
                                              width: 1,
                                            ),
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
                                        const SizedBox(width: 14),
                                        // Info
                                        Expanded(
                                          child: Column(
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
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${song.artist} · ${song.album}',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 12,
                                                  color: AppColors.skyOp(0.6),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.tealOp(0.15),
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: AppColors.tealOp(0.3),
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'HQ', // Real quality depends on actual file bitrate
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 8,
                                                    color: AppColors.teal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Size & Delete
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Downloaded',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 11,
                                                color: AppColors.tealOp(0.8),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            GestureDetector(
                                              onTap: () => _deleteSong(song),
                                              child: Icon(
                                                Icons.close_rounded,
                                                color: AppColors.red.withValues(alpha: 0.8),
                                                size: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
