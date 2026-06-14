// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

void main() async {
  print("=========================================");
  print("🔔 MikuPlay Push Notification Tester");
  print("=========================================\n");

  print("📨 Mengirim Push Notification pengujian...");
  await sendTestNotification();
}

Future<void> sendTestNotification() async {
  final serviceAccountFile = File('firebase-service-account.json');
  if (!serviceAccountFile.existsSync()) {
    print('⚠️ File firebase-service-account.json tidak ditemukan!');
    print(
        '👉 Pastikan Anda sudah mengunduhnya dari Firebase Console dan menaruhnya di folder utama proyek.');
    exit(1);
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
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${accessCredentials.accessToken.data}',
      },
      body: jsonEncode({
        'message': {
          'topic': 'new_songs',
          'notification': {
            'title': 'tes tes tes',
            'body': 'saya akan lawan!',
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
      print(
          '✅ SUKSES! Notifikasi uji coba berhasil dikirim ke semua pengguna!');
    } else {
      print('❌ GAGAL mengirim notifikasi.');
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
    }
    client.close();
  } catch (e) {
    print('❌ Error saat mengirim notifikasi: $e');
  }
}
