import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/song_model.dart';
import 'playlist_service.dart';

class DownloadService {
  DownloadService._internal();
  static final DownloadService instance = DownloadService._internal();

  final Dio _dio = Dio();
  
  List<Song> _downloadedSongs = [];
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await _loadMetadata();
    _isInitialized = true;
  }

  Future<File> _getMetadataFile() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory songsDir = Directory('${appDocDir.path}/songs');
    if (!await songsDir.exists()) {
      await songsDir.create(recursive: true);
    }
    return File('${songsDir.path}/downloads_metadata.json');
  }

  Future<void> _loadMetadata() async {
    try {
      final file = await _getMetadataFile();
      if (await file.exists()) {
        final String contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        _downloadedSongs = jsonList.map((m) => Song.fromMap(m as Map<String, dynamic>, m['id'] as String)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load downloads metadata: $e');
    }
  }

  Future<void> _saveMetadata() async {
    try {
      final file = await _getMetadataFile();
      final List<Map<String, dynamic>> jsonList = _downloadedSongs.map((s) {
        var map = s.toMap();
        map['id'] = s.id; // ensure ID is saved
        return map;
      }).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Failed to save downloads metadata: $e');
    }
  }

  Future<List<Song>> getDownloadedSongs() async {
    await init();
    return _downloadedSongs;
  }

  // Returns true if success, false otherwise
  Future<bool> downloadSong(Song song, Function(int, int)? onReceiveProgress) async {
    try {
      if (song.audioUrl.startsWith('assets/')) {
        return true; // Local asset
      }

      await init();

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory songsDir = Directory('${appDocDir.path}/songs');
      if (!await songsDir.exists()) {
        await songsDir.create(recursive: true);
      }

      String extension = 'mp3';
      if (song.audioUrl.contains('.')) {
        final parts = song.audioUrl.split('.');
        if (parts.last.length <= 4) {
          extension = parts.last;
        }
      }
      final String savePath = '${songsDir.path}/${song.id}.$extension';

      // If not already downloaded physically
      if (!await File(savePath).exists()) {
        await _dio.download(
          song.audioUrl,
          savePath,
          onReceiveProgress: onReceiveProgress,
        );
      }

      // Add to tracker if not already there
      if (!_downloadedSongs.any((s) => s.id == song.id)) {
        // Create a new song instance with localPath updated
        final newMap = song.toMap();
        newMap['localPath'] = savePath;
        _downloadedSongs.add(Song.fromMap(newMap, song.id));
        await _saveMetadata();
      }

      // Update Favorites as well
      await PlaylistService.instance.updateFavoriteLocalPath(song.id, savePath);

      return true;
    } catch (e) {
      debugPrint('Download failed: $e');
      return false;
    }
  }

  Future<bool> deleteDownload(Song song) async {
    try {
      await init();
      
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory songsDir = Directory('${appDocDir.path}/songs');
      
      String extension = 'mp3';
      if (song.audioUrl.contains('.')) {
        final parts = song.audioUrl.split('.');
        if (parts.last.length <= 4) {
          extension = parts.last;
        }
      }
      final String savePath = '${songsDir.path}/${song.id}.$extension';

      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      _downloadedSongs.removeWhere((s) => s.id == song.id);
      await _saveMetadata();

      // Clear from favorites local path
      await PlaylistService.instance.updateFavoriteLocalPath(song.id, null);

      return true;
    } catch (e) {
      debugPrint('Delete download failed: $e');
      return false;
    }
  }

  Future<String?> getLocalPathIfDownloaded(Song song) async {
    if (song.audioUrl.startsWith('assets/')) {
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
