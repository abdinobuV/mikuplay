import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song_model.dart';
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
  Future<void> updateFavoriteLocalPath(String songId, String localPath) async {
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
}
