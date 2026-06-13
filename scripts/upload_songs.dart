import 'dart:io';
import 'package:supabase/supabase.dart';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

void main() async {
  print("=========================================");
  print("🚀 Supabase Auto-Uploader by Antigravity");
  print("=========================================\n");

  // 1. Baca .env file secara manual
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print("❌ File .env tidak ditemukan! Pastikan Anda sudah membuat dan mengisi .env");
    return;
  }

  String supabaseUrl = '';
  String supabaseKey = '';

  for (var line in envFile.readAsLinesSync()) {
    if (line.startsWith('SUPABASE_URL=')) supabaseUrl = line.split('=')[1].trim();
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) supabaseKey = line.split('=')[1].trim();
  }

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty || supabaseUrl == 'YOUR_SUPABASE_PROJECT_URL_HERE') {
    print("❌ Kredensial tidak lengkap!");
    print("👉 Pastikan Anda telah menambahkan SUPABASE_SERVICE_ROLE_KEY di dalam file .env");
    print("💡 Anda bisa menemukannya di Supabase Dashboard -> Project Settings -> API -> service_role secret.");
    return;
  }

  // 2. Inisialisasi Supabase Client
  final client = SupabaseClient(supabaseUrl, supabaseKey);

  // 3. Baca folder assets/audio
  final audioDir = Directory('assets/audio');
  if (!audioDir.existsSync()) {
    print("⚠️ Folder assets/audio tidak ditemukan.");
    return;
  }

  final files = audioDir.listSync().whereType<File>().toList();
  if (files.isEmpty) {
    print("⚠️ Tidak ada file lagu di dalam assets/audio.");
    return;
  }

  print("📦 Ditemukan ${files.length} lagu lokal. Memulai proses unggah...\n");

  for (var file in files) {
    // Mengambil nama file murni tanpa URL-encoding (mendukung spasi)
    final fileName = file.path.split(Platform.pathSeparator).last;
    
    // Ekstrak nama judul dari nama file (menghapus ekstensi dan mengubah underscore jadi spasi)
    final title = fileName.replaceAll('.mp3', '').replaceAll('.m4a', '').replaceAll('_', ' ');

    try {
      print("⏳ Mengunggah '$fileName' ke Storage...");
      
      // Upload Audio ke bucket 'music_assets/audio'
      final audioStoragePath = 'audio/$fileName';
      
      await client.storage.from('miku_media').uploadBinary(
        audioStoragePath,
        file.readAsBytesSync(),
        fileOptions: const FileOptions(upsert: true),
      );
      final audioUrl = client.storage.from('miku_media').getPublicUrl(audioStoragePath);

      // --- MENCARI DAN MENGUNGGAH COVER IMAGE ---
      String imageUrl = '';
      final possibleExtensions = ['.jpg', '.png', '.jpeg'];
      File? coverFile;
      
      for (var ext in possibleExtensions) {
        // Coba cari gambar dengan nama yang persis sama di folder assets/images/
        final tempFile = File('assets/images/$title$ext');
        if (tempFile.existsSync()) {
          coverFile = tempFile;
          break;
        }
      }

      if (coverFile != null) {
        print("🖼️  Menemukan cover untuk '$title'. Mengunggah cover...");
        final coverFileName = coverFile.uri.pathSegments.last;
        final coverStoragePath = 'covers/$coverFileName';
        
        await client.storage.from('miku_media').uploadBinary(
          coverStoragePath,
          coverFile.readAsBytesSync(),
          fileOptions: const FileOptions(upsert: true),
        );
        imageUrl = client.storage.from('miku_media').getPublicUrl(coverStoragePath);
      } else {
        print("⚠️  Tidak menemukan gambar cover untuk '$title' (Abaikan jika tidak ada).");
      }

      print("📝 Mendaftarkan '$title' ke Database...");
      
      // Insert ke tabel songs
      await client.from('songs').insert({
        'title': title,
        'artist': 'Unknown Artist', // Default artist
        'image_url': imageUrl.isEmpty ? null : imageUrl,
        'audio_url': audioUrl,
        'duration': '3:00', // Default duration
      });

      print("✅ Sukses: $title");
      
      // Mengirim Push Notification
      print("📨 Mengirim push notification...");
      await sendNotification(title);
      print("");

    } catch (e) {
      print("❌ Gagal memproses $fileName: $e\n");
    }
  }

  print("🎉 Semua lagu berhasil dipindahkan ke Supabase!");
  exit(0);
}

Future<void> sendNotification(String songTitle) async {
  final serviceAccountFile = File('firebase-service-account.json');
  if (!serviceAccountFile.existsSync()) {
    print('⚠️ firebase-service-account.json tidak ditemukan, lewati pengiriman notifikasi.');
    return;
  }

  try {
    final accountJson = jsonDecode(serviceAccountFile.readAsStringSync());
    final projectId = accountJson['project_id'];

    final accountCredentials = ServiceAccountCredentials.fromJson(accountJson);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = http.Client();
    final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
      accountCredentials,
      scopes,
      client,
    );

    final response = await client.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${accessCredentials.accessToken.data}',
      },
      body: jsonEncode({
        'message': {
          'topic': 'new_songs',
          'notification': {
            'title': 'Lagu Baru Tersedia! 🎵',
            'body': 'Dengarkan lagu "$songTitle" sekarang di MikuPlay!',
          },
          'android': {
            'notification': {
              'sound': 'default',
            }
          }
        }
      }),
    );

    if (response.statusCode == 200) {
      print('🔔 Notifikasi lagu "$songTitle" berhasil dikirim!');
    } else {
      print('❌ Gagal mengirim notifikasi: ${response.body}');
    }
    client.close();
  } catch (e) {
    print('❌ Error mengirim notifikasi: $e');
  }
}
