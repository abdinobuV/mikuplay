class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String imageUrl;
  final String audioUrl;
  final Duration duration;
  final int plays;
  final int likedCount;
  final String year;
  final String? lyrics;
  final String? localPath;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.imageUrl,
    required this.audioUrl,
    required this.duration,
    this.plays = 0,
    this.likedCount = 0,
    this.year = '',
    this.lyrics,
    this.localPath,
  });

  factory Song.fromMap(Map<String, dynamic> map, String id) {
    return Song(
      id: id,
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      album: map['album'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      duration: Duration(seconds: map['durationSeconds'] ?? 0),
      plays: map['plays'] ?? 0,
      likedCount: map['likedCount'] ?? 0,
      year: map['year'] ?? '',
      lyrics: map['lyrics'],
      localPath: map['localPath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'durationSeconds': duration.inSeconds,
      'plays': plays,
      'likedCount': likedCount,
      'year': year,
      'lyrics': lyrics,
      'localPath': localPath,
    };
  }
}
