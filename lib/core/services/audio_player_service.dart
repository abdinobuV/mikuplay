import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song_model.dart';

class AudioPlayerService {
  // Singleton instance
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  final AudioPlayer _player = AudioPlayer();

  AudioPlayerService._internal() {
    _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });

    // Listen to position changes and combine with duration and buffered position
    _player.positionStream.listen((pos) => _positionSubject.add(pos));
    _player.durationStream.listen((dur) => _durationSubject.add(dur ?? Duration.zero));
    _player.playerStateStream.listen((state) {
      print("Player State Change: ${state.processingState}, playing: ${state.playing}");
      _playerStateSubject.add(state);
    });
  }

  // Subjects for streaming state
  final _positionSubject = BehaviorSubject<Duration>.seeded(Duration.zero);
  final _durationSubject = BehaviorSubject<Duration>.seeded(Duration.zero);
  final _playerStateSubject = BehaviorSubject<PlayerState>();
  final _currentSongSubject = BehaviorSubject<Song?>();
  final _playlistSubject = BehaviorSubject<List<Song>>.seeded([]);

  // Getters for streams
  Stream<Duration> get positionStream => _positionSubject.stream;
  Stream<Duration> get durationStream => _durationSubject.stream;
  Stream<PlayerState> get playerStateStream => _playerStateSubject.stream;
  Stream<Song?> get currentSongStream => _currentSongSubject.stream;

  Song? get currentSong => _currentSongSubject.hasValue ? _currentSongSubject.value : null;

  void setPlaylist(List<Song> songs) {
    _playlistSubject.add(songs);
  }

  Future<void> skipToNext() async {
    final songs = _playlistSubject.value;
    final current = currentSong;
    if (songs.isEmpty || current == null) return;

    final currentIndex = songs.indexWhere((s) => s.id == current.id);
    final nextIndex = (currentIndex + 1) % songs.length;
    await setSong(songs[nextIndex]);
  }

  Future<void> setSong(Song song) async {
    print("Attempting to play song: ${song.title} from ${song.audioUrl}");
    
    // Use hasValue and valueOrNull for safety
    if (_currentSongSubject.hasValue && 
        _currentSongSubject.value?.id == song.id && 
        _player.playing) {
      print("Song already playing, skipping setUrl");
      return;
    }
    
    try {
      _currentSongSubject.add(song);
      
      // Stop current playback before switching
      await _player.stop();
      
      if (song.audioUrl.startsWith('assets/')) {
        print("Loading asset: ${song.audioUrl}");
        await _player.setAsset(song.audioUrl);
      } else {
        print("Loading URL: ${song.audioUrl}");
        await _player.setUrl(song.audioUrl);
      }
      
      print("Load successful, calling play()");
      await _player.play();
    } catch (e, stack) {
      print("CRITICAL ERROR loading audio: $e");
      print(stack);
    }
  }

  Future<void> play() async => await _player.play();
  Future<void> pause() async => await _player.pause();
  Future<void> seek(Duration position) async => await _player.seek(position);
  Future<void> stop() async => await _player.stop();

  void dispose() {
    _player.dispose();
    _positionSubject.close();
    _durationSubject.close();
    _playerStateSubject.close();
    _currentSongSubject.close();
  }
}
