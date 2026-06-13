import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song_model.dart';
import 'auth_service.dart';

class HistoryRecord {
  final Song song;
  final DateTime playedAt;

  HistoryRecord({required this.song, required this.playedAt});
}

class HistoryService {
  HistoryService._internal();
  static final HistoryService instance = HistoryService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of recently played songs with timestamps
  Stream<List<HistoryRecord>> streamHistoryRecords({int limit = 50}) {
    final user = AuthService.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('playedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final song = Song.fromMap(data, doc.id);
        final timestamp = data['playedAt'] as Timestamp?;
        final playedAt = timestamp?.toDate() ?? DateTime.now();
        return HistoryRecord(song: song, playedAt: playedAt);
      }).toList();
    });
  }

  // Record a played song
  Future<void> addSongToHistory(Song song) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .doc(song.id);

    final data = song.toMap();
    data['playedAt'] = FieldValue.serverTimestamp();

    // Use set with merge true to update playedAt if it already exists
    await docRef.set(data, SetOptions(merge: true));
  }

  // Clear all history
  Future<void> clearHistory() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final historyRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('history');

    final snapshot = await historyRef.get();
    final batch = _db.batch();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
