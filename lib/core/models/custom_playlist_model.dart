import 'package:cloud_firestore/cloud_firestore.dart';

class CustomPlaylist {
  final String id;
  final String name;
  final String? imageUrl;
  final int songCount;
  final DateTime createdAt;

  CustomPlaylist({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.songCount,
    required this.createdAt,
  });

  factory CustomPlaylist.fromMap(Map<String, dynamic> map, String documentId) {
    return CustomPlaylist(
      id: documentId,
      name: map['name'] ?? 'Untitled Playlist',
      imageUrl: map['imageUrl'],
      songCount: map['songCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'songCount': songCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
