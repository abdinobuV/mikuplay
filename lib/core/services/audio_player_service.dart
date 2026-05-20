import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song_model.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  final AudioPlayer _player = AudioPlayer();

  AudioPlayerService._internal() {
    _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });

    _player.positionStream.listen((pos) => _positionSubject.add(pos));
    _player.durationStream.listen((dur) => _durationSubject.add(dur ?? Duration.zero));
    _player.playerStateStream.listen((state) {
      _playerStateSubject.add(state);
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

  Song? get currentSong => _currentSongSubject.hasValue ? _currentSongSubject.value : null;

  void setPlaylist(List<Song> songs) {
    _playlistSubject.add(songs);
  }

  Future<void> skipToNext() async {
    final songs = _playlistSubject.value;
    final current = currentSong;
    if (songs.isEmpty || current == null) return;
    final currentIndex = songs.indexWhere((s) => s.id == current.id);
    if (currentIndex == -1) return;
    final nextIndex = (currentIndex + 1) % songs.length;
    await setSong(songs[nextIndex]);
  }

  Future<void> skipToPrevious() async {
    final songs = _playlistSubject.value;
    final current = currentSong;
    if (songs.isEmpty || current == null) return;
    final currentIndex = songs.indexWhere((s) => s.id == current.id);
    if (currentIndex == -1) return;
    final prevIndex = (currentIndex - 1 + songs.length) % songs.length;
    await setSong(songs[prevIndex]);
  }

  Future<void> setSong(Song song) async {
    print("Attempting to play song: ${song.title} from ${song.audioUrl}");
    
    if (_currentSongSubject.hasValue && 
        _currentSongSubject.value?.id == song.id && 
        _player.playing) {
      return;
    }
    
    try {
      _currentSongSubject.add(song);
      await _player.stop();

      // KHUSUS ANDROID: Menggunakan AudioSource.uri dengan tag MediaItem yang sangat spesifik
      // Format URI harus tepat 'asset:///assets/images/...'
      final artUri = song.imageUrl.startsWith('assets/')
          ? Uri.parse('asset:///${song.imageUrl}')
          : Uri.parse(song.imageUrl);

      final audioUri = song.audioUrl.startsWith('assets/')
          ? Uri.parse('asset:///${song.audioUrl}')
          : Uri.parse(song.audioUrl);

      final audioSource = AudioSource.uri(
        audioUri,
        tag: MediaItem(
          id: song.id,
          album: song.album,
          title: song.title,
          artist: song.artist,
          artUri: artUri,
        ),
      );
      
      await _player.setAudioSource(audioSource);
      await _player.play();
    } catch (e) {
      print("Error loading audio: $e");
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
