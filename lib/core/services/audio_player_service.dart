import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/song_model.dart';
import 'download_service.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  final AudioPlayer _player = AudioPlayer();
  ConcatenatingAudioSource? _playlistSource;

  AudioPlayerService._internal() {
    _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
      debugPrint('A stream error occurred: $e');
    });

    _player.positionStream.listen((pos) => _positionSubject.add(pos));
    _player.durationStream.listen((dur) => _durationSubject.add(dur ?? Duration.zero));
    _player.playerStateStream.listen((state) {
      _playerStateSubject.add(state);
    });

    // Dengarkan perubahan sequence (lagu berganti otomatis/lewat notifikasi)
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;
      final currentItem = sequenceState.currentSource;
      if (currentItem != null && currentItem.tag is MediaItem) {
        final mediaItem = currentItem.tag as MediaItem;
        final currentPlaylist = _playlistSubject.value;
        try {
          final matchedSong = currentPlaylist.firstWhere((s) => s.id == mediaItem.id);
          _currentSongSubject.add(matchedSong);
        } catch (_) {}
      }
    });
  }

  final _positionSubject = BehaviorSubject<Duration>.seeded(Duration.zero);
  final _durationSubject = BehaviorSubject<Duration>.seeded(Duration.zero);
  final _playerStateSubject = BehaviorSubject<PlayerState>();
  final _currentSongSubject = BehaviorSubject<Song?>();
  final _playlistSubject = BehaviorSubject<List<Song>>.seeded([]);

  Stream<Duration> get positionStream => _positionSubject.stream;
  Stream<Duration> get durationStream => _durationSubject.stream;
  Stream<PlayerState> get playerStateStream => _playerStateSubject.stream;
  Stream<Song?> get currentSongStream => _currentSongSubject.stream;
  Stream<List<Song>> get playlistStream => _playlistSubject.stream;

  Song? get currentSong => _currentSongSubject.hasValue ? _currentSongSubject.value : null;

  void setPlaylist(List<Song> songs) {
    _playlistSubject.add(songs);
    _playlistSource = null; // Paksa buat ulang audio source saat lagu diputar
  }

  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  Future<void> skipToPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Future<Uri> _getArtUri(String imageUrl) async {
    if (imageUrl.isEmpty) return Uri.parse('');
    if (imageUrl.startsWith('http')) return Uri.parse(imageUrl);

    if (imageUrl.startsWith('assets/')) {
      try {
        final byteData = await rootBundle.load(imageUrl);
        final tempDir = await getTemporaryDirectory();
        final fileName = imageUrl.replaceAll('/', '_');
        final file = File('${tempDir.path}/$fileName');
        if (!await file.exists()) {
          await file.writeAsBytes(byteData.buffer.asUint8List());
        }
        return Uri.file(file.path);
      } catch (e) {
        debugPrint("Error loading asset image: $e");
        return Uri.parse('asset:///$imageUrl');
      }
    }
    return Uri.parse(imageUrl);
  }

  Future<void> setSong(Song song) async {
    debugPrint("Attempting to play song: ${song.title}");
    
    if (_currentSongSubject.hasValue && 
        _currentSongSubject.value?.id == song.id && 
        _player.playing) {
      return;
    }

    try {
      final currentPlaylist = _playlistSubject.value;
      
      // Jika kosong, tambahkan ke playlist
      if (currentPlaylist.isEmpty) {
        _playlistSubject.add([song]);
      } else if (!currentPlaylist.any((s) => s.id == song.id)) {
        // Jika lagu tidak ada di playlist saat ini, kita tambahkan lagu ini ke awal atau akhir playlist
        _playlistSubject.add([...currentPlaylist, song]);
      }

      final updatedPlaylist = _playlistSubject.value;
      final targetIndex = updatedPlaylist.indexWhere((s) => s.id == song.id);

      if (_playlistSource == null) {
        List<AudioSource> children = [];
        for (var s in updatedPlaylist) {
          final artUri = await _getArtUri(s.imageUrl);

          final localPath = await DownloadService.instance.getLocalPathIfDownloaded(s);
          Uri audioUri;

          if (localPath != null && await File(localPath).exists()) {
            audioUri = Uri.file(localPath);
          } else {
            audioUri = s.audioUrl.startsWith('assets/')
                ? Uri.parse('asset:///${s.audioUrl}')
                : Uri.parse(s.audioUrl);
          }

          children.add(
            AudioSource.uri(
              audioUri,
              tag: MediaItem(
                id: s.id,
                album: s.album ?? "MikuPlay",
                title: s.title,
                artist: s.artist,
                artUri: artUri,
              ),
            ),
          );
        }

        _playlistSource = ConcatenatingAudioSource(children: children);
        await _player.setAudioSource(_playlistSource!, initialIndex: targetIndex, initialPosition: Duration.zero);
      } else {
        // Playlist sudah ada, cukup pindah indeks
        await _player.seek(Duration.zero, index: targetIndex);
      }
      
      _currentSongSubject.add(song);
      await _player.play();
      
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  Future<void> play() async => await _player.play();
  Future<void> pause() async => await _player.pause();
  Future<void> seek(Duration position) async => await _player.seek(position);
  Future<void> stop() async => await _player.stop();

  Future<void> seekForward() async {
    final newPosition = _player.position + const Duration(seconds: 10);
    await _player.seek(newPosition);
  }

  Future<void> seekBackward() async {
    final newPosition = _player.position - const Duration(seconds: 10);
    await _player.seek(newPosition);
  }
}
