// ============================================================
// FILE INI DISIMPAN DI:
// lib/core/services/firestore_service.dart
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ── Model data user di Firestore ──────────────────────────────
class UserProfile {
  final String  uid;
  final String  email;
  final String  username;
  final String? photoUrl;
  final String  provider;       // 'email' atau 'google'
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool    onboardingDone; // ← flag skip onboarding

  const UserProfile({
    required this.uid,
    required this.email,
    required this.username,
    this.photoUrl,
    required this.provider,
    required this.createdAt,
    required this.lastLoginAt,
    required this.onboardingDone,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid:             map['uid']             as String,
      email:           map['email']           as String,
      username:        map['username']        as String,
      photoUrl:        map['photoUrl']        as String?,
      provider:        map['provider']        as String,
      createdAt:       (map['createdAt']      as Timestamp).toDate(),
      lastLoginAt:     (map['lastLoginAt']    as Timestamp).toDate(),
      onboardingDone:  map['onboardingDone']  as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid':            uid,
    'email':          email,
    'username':       username,
    'photoUrl':       photoUrl,
    'provider':       provider,
    'createdAt':      Timestamp.fromDate(createdAt),
    'lastLoginAt':    Timestamp.fromDate(lastLoginAt),
    'onboardingDone': onboardingDone,
  };
}

// ── Firestore Service ─────────────────────────────────────────
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Secure storage — untuk cache lokal terenkripsi (token, flag, dll.)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Referensi koleksi
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  // ────────────────────────────────────────────────────────────
  // CREATE USER PROFILE
  // Memakai set() dengan merge:false untuk anti-duplikasi.
  // Jika UID sudah ada, fungsi ini tidak akan overwrite data lama.
  // ────────────────────────────────────────────────────────────
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String username,
    String? photoUrl,
    required String provider,
  }) async {
    final docRef = _users.doc(uid);
    final doc    = await docRef.get();

    if (doc.exists) {
      // User sudah ada — hanya update lastLoginAt, jangan overwrite
      await docRef.update({'lastLoginAt': FieldValue.serverTimestamp()});
      return;
    }

    // User baru — buat dokumen lengkap
    await docRef.set({
      'uid':            uid,
      'email':          email.toLowerCase().trim(),
      'username':       username,
      'photoUrl':       photoUrl,
      'provider':       provider,
      'createdAt':      FieldValue.serverTimestamp(),
      'lastLoginAt':    FieldValue.serverTimestamp(),
      'onboardingDone': false,
      'songs':          0,
      'playlists':      0,
      'favorites':      0,
    });

    // Cache uid di secure storage (terenkripsi di device)
    await _secureStorage.write(key: 'user_uid', value: uid);
  }

  // ────────────────────────────────────────────────────────────
  // GET USER PROFILE
  // ────────────────────────────────────────────────────────────
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserProfile.fromMap(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  // ── Stream real-time untuk ProfileScreen ─────────────────────
  Stream<UserProfile?> streamUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserProfile.fromMap(snap.data()!);
    });
  }

  // ────────────────────────────────────────────────────────────
  // UPDATE LAST LOGIN
  // ────────────────────────────────────────────────────────────
  Future<void> updateLastLogin(String uid) async {
    await _users.doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  // ────────────────────────────────────────────────────────────
  // UPDATE PROFIL (username / foto)
  // ────────────────────────────────────────────────────────────
  Future<void> updateUserProfile({
    required String uid,
    String? username,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (data.isEmpty) return;
    await _users.doc(uid).update(data);
  }

  // ────────────────────────────────────────────────────────────
  // ONBOARDING SELESAI — set flag agar tidak muncul lagi
  // ────────────────────────────────────────────────────────────
  Future<void> markOnboardingDone(String uid) async {
    await _users.doc(uid).update({'onboardingDone': true});
    // Cache juga di secure storage (faster check tanpa hit Firestore)
    await _secureStorage.write(key: 'onboarding_done_$uid', value: 'true');
  }

  // ── Cek apakah onboarding sudah selesai (dari cache dulu) ────
  Future<bool> isOnboardingDone(String uid) async {
    // Cek cache lokal terlebih dahulu (tidak perlu hit Firestore)
    final cached = await _secureStorage.read(key: 'onboarding_done_$uid');
    if (cached == 'true') return true;

    // Jika tidak ada cache, cek Firestore
    final profile = await getUserProfile(uid);
    final done    = profile?.onboardingDone ?? false;

    // Cache hasilnya
    if (done) {
      await _secureStorage.write(key: 'onboarding_done_$uid', value: 'true');
    }
    return done;
  }

  // ────────────────────────────────────────────────────────────
  // CLEAR SECURE STORAGE (saat logout)
  // ────────────────────────────────────────────────────────────
  Future<void> clearLocalCache() async {
    await _secureStorage.deleteAll();
  }

  // ────────────────────────────────────────────────────────────
  // CEK DUPLIKASI USERNAME
  // ────────────────────────────────────────────────────────────
  Future<bool> isUsernameAvailable(String username) async {
    final query = await _users
        .where('username', isEqualTo: username.trim())
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }
}