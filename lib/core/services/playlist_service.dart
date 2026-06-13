import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song_model.dart';
import '../models/custom_playlist_model.dart';
import 'auth_service.dart';

class PlaylistService {
  PlaylistService._internal();
  static final PlaylistService instance = PlaylistService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of favorite songs for the current user
  Stream<List<Song>> streamFavoriteSongs() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Song.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Check if a specific song is a favorite
  Stream<bool> isFavorite(String songId) {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value(false);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(songId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Song song) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(song.id);

    final userRef = _db.collection('users').doc(user.uid);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
      // Decrement favorites count in user profile
      await userRef.update({'favorites': FieldValue.increment(-1)});
    } else {
      final data = song.toMap();
      data['addedAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);
      // Increment favorites count in user profile
      await userRef.update({'favorites': FieldValue.increment(1)});
    }
  }

  // Update a local downloaded path for a song in favorites if it exists
  Future<void> updateFavoriteLocalPath(String songId, String? localPath) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(songId);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.update({'localPath': localPath});
    }
  }

  // ==========================================
  // CUSTOM PLAYLISTS
  // ==========================================

  Stream<List<CustomPlaylist>> streamCustomPlaylists() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('custom_playlists')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CustomPlaylist.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> createCustomPlaylist(String name) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('custom_playlists')
        .doc();

    await docRef.set({
      'name': name,
      'songCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Increment playlists count in user profile
    await _db.collection('users').doc(user.uid).update({'playlists': FieldValue.increment(1)});
  }

  Stream<List<Song>> streamCustomPlaylistSongs(String playlistId) {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('custom_playlists')
        .doc(playlistId)
        .collection('songs')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Song.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addSongToCustomPlaylist(String playlistId, Song song) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final songDocRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('custom_playlists')
        .doc(playlistId)
        .collection('songs')
        .doc(song.id);

    final doc = await songDocRef.get();
    if (!doc.exists) {
      final data = song.toMap();
      data['addedAt'] = FieldValue.serverTimestamp();
      await songDocRef.set(data);

      // Update count and optionally imageUrl of playlist
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('custom_playlists')
          .doc(playlistId)
          .update({
        'songCount': FieldValue.increment(1),
        'imageUrl': song.imageUrl,
      });
    }
  }

  Future<void> removeSongFromCustomPlaylist(String playlistId, String songId) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final songDocRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('custom_playlists')
        .doc(playlistId)
        .collection('songs')
        .doc(songId);

    final doc = await songDocRef.get();
    if (doc.exists) {
      await songDocRef.delete();
      
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('custom_playlists')
          .doc(playlistId)
          .update({
        'songCount': FieldValue.increment(-1),
      });
    }
  }
}
