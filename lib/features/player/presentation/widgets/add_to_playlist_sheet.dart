import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/song_model.dart';
import '../../../../core/models/custom_playlist_model.dart';
import '../../../../core/services/playlist_service.dart';

class AddToPlaylistBottomSheet extends StatefulWidget {
  final Song song;

  const AddToPlaylistBottomSheet({super.key, required this.song});

  @override
  State<AddToPlaylistBottomSheet> createState() => _AddToPlaylistBottomSheetState();
}

class _AddToPlaylistBottomSheetState extends State<AddToPlaylistBottomSheet> {
  final TextEditingController _playlistNameController = TextEditingController();
  bool _isCreating = false;

  void _createNewPlaylist() async {
    final name = _playlistNameController.text.trim();
    if (name.isEmpty) return;
    
    setState(() => _isCreating = true);
    await PlaylistService.instance.createCustomPlaylist(name);
    _playlistNameController.clear();
    setState(() => _isCreating = false);
  }

  void _addToPlaylist(CustomPlaylist playlist) async {
    await PlaylistService.instance.addSongToCustomPlaylist(playlist.id, widget.song);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to ${playlist.name}', style: const TextStyle(fontFamily: 'Inter')),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.whiteOp(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Add to Playlist',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          
          // Create New Playlist Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _playlistNameController,
                    style: const TextStyle(color: AppColors.white, fontFamily: 'Inter'),
                    decoration: InputDecoration(
                      hintText: 'New playlist name...',
                      hintStyle: TextStyle(color: AppColors.whiteOp(0.5)),
                      filled: true,
                      fillColor: AppColors.whiteOp(0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isCreating ? null : _createNewPlaylist,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isCreating 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2))
                      : const Text(
                          'Create',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          
          // Playlists List
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: StreamBuilder<List<CustomPlaylist>>(
              stream: PlaylistService.instance.streamCustomPlaylists(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.teal));
                }
                
                final playlists = snapshot.data ?? [];
                
                if (playlists.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'You don\'t have any playlists yet.',
                        style: TextStyle(color: AppColors.whiteOp(0.5), fontFamily: 'Inter'),
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.whiteOp(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: playlist.imageUrl != null && playlist.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: playlist.imageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => const Icon(Icons.music_note, color: AppColors.teal),
                              ),
                            )
                          : const Icon(Icons.queue_music_rounded, color: AppColors.teal),
                      ),
                      title: Text(
                        playlist.name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      subtitle: Text(
                        '${playlist.songCount} songs',
                        style: TextStyle(
                          color: AppColors.whiteOp(0.6),
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                      onTap: () => _addToPlaylist(playlist),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
