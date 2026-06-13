import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  // Gunakan Supabase client yang sudah diinisialisasi
  final _supabase = Supabase.instance.client;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Upload file ke Supabase Storage dan mengembalikan URL publiknya
  /// [file] adalah file yang akan diupload (misal dari image_picker)
  /// [bucketName] adalah nama bucket yang Anda buat di dashboard Supabase (misal: 'miku_media')
  /// [folderName] adalah nama folder opsional di dalam bucket (misal: 'avatars' atau 'covers')
  Future<String?> uploadFile({
    required File file,
    required String bucketName,
    String folderName = 'general',
  }) async {
    try {
      // 1. Dapatkan user yang sedang login dari Firebase
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception("User belum login");
      }

      // 2. Tentukan nama unik untuk file agar tidak tertimpa jika upload file dengan nama yang sama
      // Format: namafolder/UID_Firebase/timestamp_namafileasli
      final fileName = file.path.split('/').last.split('\\').last; 
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$folderName/${user.uid}/${timestamp}_$fileName';

      // 3. Upload file ke Supabase
      await _supabase.storage.from(bucketName).upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      // 4. Dapatkan Public URL
      final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
      
    } catch (e) {
      debugPrint("Error upload ke Supabase: $e");
      return null;
    }
  }

  /// Menghapus file dari Supabase Storage
  Future<bool> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
       await _supabase.storage.from(bucketName).remove([filePath]);
       return true;
    } catch(e) {
      debugPrint("Error hapus file dari Supabase: $e");
      return false;
    }
  }
}
