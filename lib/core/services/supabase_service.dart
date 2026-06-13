import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/song_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;

  final SupabaseClient _client = Supabase.instance.client;

  SupabaseService._internal();

  /// Mengambil semua lagu dari Supabase
  Future<List<Song>> getAllSongs() async {
    try {
      final response = await _client.from('songs').select();
      
      return (response as List).map((song) => Song(
        id: song['id'].toString(),
        title: song['title'].toString(),
        artist: song['artist'].toString(),
        album: 'MikuPlay',
        imageUrl: song['image_url']?.toString() ?? '',
        audioUrl: song['audio_url'].toString(),
        duration: _parseDuration(song['duration']?.toString() ?? '0:00'),
      )).toList();
    } catch (e) {
      debugPrint("Supabase getAllSongs error: $e");
      return [];
    }
  }

  /// Mencari lagu berdasarkan judul atau artis
  Future<List<Song>> searchSongs(String query) async {
    try {
      final response = await _client
          .from('songs')
          .select()
          .or('title.ilike.%$query%,artist.ilike.%$query%');
      
      return (response as List).map((song) => Song(
        id: song['id'].toString(),
        title: song['title'].toString(),
        artist: song['artist'].toString(),
        album: 'MikuPlay',
        imageUrl: song['image_url']?.toString() ?? '',
        audioUrl: song['audio_url'].toString(),
        duration: _parseDuration(song['duration']?.toString() ?? '0:00'),
      )).toList();
    } catch (e) {
      debugPrint("Supabase searchSongs error: $e");
      return [];
    }
  }

  /// Konversi durasi "MM:SS" ke Duration
  Duration _parseDuration(String durationStr) {
    try {
      final parts = durationStr.split(':');
      if (parts.length == 2) {
        return Duration(
          minutes: int.parse(parts[0]),
          seconds: int.parse(parts[1]),
        );
      } else if (parts.length == 3) {
        return Duration(
          hours: int.parse(parts[0]),
          minutes: int.parse(parts[1]),
          seconds: int.parse(parts[2]),
        );
      }
    } catch (e) {
      // Abaikan jika format salah
    }
    return const Duration(minutes: 3); // Default
  }

  /// Mengambil daftar Top Charts berdasarkan jumlah plays
  Future<List<Song>> getTopCharts({int limit = 3}) async {
    try {
      // Mencoba mengambil data berdasarkan kolom plays jika ada
      final response = await _client
          .from('songs')
          .select()
          .order('plays', ascending: false)
          .limit(limit);
          
      return _mapSongs(response as List);
    } catch (e) {
      debugPrint("Supabase getTopCharts error (mungkin kolom plays belum ada): $e");
      // Fallback: Ambil lagu apa saja dan asumsikan sebagai top charts sementara
      try {
        final fallbackResponse = await _client.from('songs').select().limit(limit);
        return _mapSongs(fallbackResponse as List);
      } catch (e2) {
        return [];
      }
    }
  }

  /// Helper untuk map data ke model Song
  List<Song> _mapSongs(List data) {
    return data.map((song) => Song(
      id: song['id'].toString(),
      title: song['title'].toString(),
      artist: song['artist'].toString(),
      album: 'MikuPlay',
      imageUrl: song['image_url']?.toString() ?? '',
      audioUrl: song['audio_url'].toString(),
      duration: _parseDuration(song['duration']?.toString() ?? '0:00'),
      plays: int.tryParse(song['plays']?.toString() ?? '0') ?? 0,
    )).toList();
  }

  /// Memperbarui durasi lagu di database
  Future<void> updateSongDuration(String songId, Duration realDuration) async {
    try {
      final minutes = realDuration.inMinutes;
      final seconds = (realDuration.inSeconds % 60).toString().padLeft(2, '0');
      final durationStr = '$minutes:$seconds';

      await _client
          .from('songs')
          .update({'duration': durationStr})
          .eq('id', songId);
          
      debugPrint("✅ Durasi untuk lagu $songId berhasil di-auto-heal menjadi $durationStr");
    } catch (e) {
      debugPrint("❌ Gagal auto-heal durasi: $e");
    }
  }
}
