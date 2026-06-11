import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/song_model.dart';
import 'playlist_service.dart';

class DownloadService {
  DownloadService._internal();
  static final DownloadService instance = DownloadService._internal();

  final Dio _dio = Dio();

  // Returns true if success, false otherwise
  Future<bool> downloadSong(Song song, Function(int, int)? onReceiveProgress) async {
    try {
      if (song.audioUrl.startsWith('assets/')) {
        // Already a local asset, no need to download.
        // We could just return true.
        return true;
      }

      // 1. Get Application Documents Directory (Private)
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      
      // 2. Create a dedicated folder for songs
      final Directory songsDir = Directory('${appDocDir.path}/songs');
      if (!await songsDir.exists()) {
        await songsDir.create(recursive: true);
      }

      // 3. Define save path
      // Extract file extension or default to mp3
      String extension = 'mp3';
      if (song.audioUrl.contains('.')) {
        final parts = song.audioUrl.split('.');
        if (parts.last.length <= 4) {
          extension = parts.last;
        }
      }
      final String savePath = '${songsDir.path}/${song.id}.$extension';

      // 4. Check if already downloaded
      if (await File(savePath).exists()) {
        return true;
      }

      // 5. Download the file
      await _dio.download(
        song.audioUrl,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );

      // 6. Update localPath in Favorites if it's a favorite
      await PlaylistService.instance.updateFavoriteLocalPath(song.id, savePath);

      return true;
    } catch (e) {
      debugPrint('Download failed: $e');
      return false;
    }
  }

  // Check if song is downloaded privately
  Future<String?> getLocalPathIfDownloaded(Song song) async {
    if (song.audioUrl.startsWith('assets/')) {
       // Assets don't need "local path" logic, audio player handles asset:///
       return null;
    }

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory songsDir = Directory('${appDocDir.path}/songs');
      
      String extension = 'mp3';
      if (song.audioUrl.contains('.')) {
        final parts = song.audioUrl.split('.');
        if (parts.last.length <= 4) {
          extension = parts.last;
        }
      }
      final String checkPath = '${songsDir.path}/${song.id}.$extension';

      if (await File(checkPath).exists()) {
        return checkPath;
      }
    } catch (_) {}

    return null;
  }
}
