// ============================================================
// FILE INI DISIMPAN DI:
// lib/main.dart
// GANTI SELURUH ISI FILE LAMA
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // AUTO-GENERATED oleh flutterfire configure
import 'app.dart';

void main() async {
  // Wajib dipanggil sebelum Firebase.initializeApp
  WidgetsFlutterBinding.ensureInitialized();

  // ── Inisialisasi Firebase ──────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Paksa portrait mode ────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Status bar transparan (sesuai desain Figma) ────────────
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:         Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const MikuPlayApp());
}