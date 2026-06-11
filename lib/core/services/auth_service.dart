// ============================================================
// FILE INI DISIMPAN DI:
// lib/core/services/auth_service.dart
// ============================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';

// ── 1. Hasil operasi auth ─────────────────────────────────────
class AuthResult {
  final bool success;
  final String? errorMessage;
  final User? user;

  const AuthResult._({
    required this.success,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.ok(User user) => AuthResult._(success: true, user: user);

  factory AuthResult.fail(String msg) =>
      AuthResult._(success: false, errorMessage: msg);
}

// ── 3. Auth Service Utama ─────────────────────────────────────
// Class ini khusus mengurus proses Login/Daftar
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();

  // Memanggil FirestoreService yang ada di atas
  final FirestoreService _db = FirestoreService.instance;

  // ── Stream: perubahan status login (listen di router) ───────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── User yang sedang login ────────────────────────────────
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // ────────────────────────────────────────────────────────────
  // SIGN UP — Email & Password
  // ────────────────────────────────────────────────────────────
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
    String? photoUrl,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final user = credential.user!;
      
      // Jalankan secara paralel agar lebih cepat
      await Future.wait([
        user.updateDisplayName(username),
        _db.createUserProfile(
          uid: user.uid,
          email: cleanEmail,
          username: username,
          photoUrl: photoUrl,
          provider: 'email',
        ),
      ]);

      // Kirim email verification tanpa harus memblokir navigasi
      user.sendEmailVerification().ignore();

      return AuthResult.ok(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.fail('Something went wrong. Please try again.');
    }
  }

  // ────────────────────────────────────────────────────────────
  // SIGN IN — Email & Password
  // ────────────────────────────────────────────────────────────
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();

      final credential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      // Update lastLoginAt di Firestore secara background
      _db.updateLastLogin(credential.user!.uid).ignore();

      return AuthResult.ok(credential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.fail('Sign in failed. Please try again.');
    }
  }

  // ────────────────────────────────────────────────────────────
  // GOOGLE SIGN IN
  // ────────────────────────────────────────────────────────────
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _google.signIn();
      if (googleUser == null) {
        return AuthResult.fail('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final user = result.user!;

      final isNewUser = result.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Buat profil baru di Firestore
        await _db.createUserProfile(
          uid: user.uid,
          email: user.email!,
          username: user.displayName ?? 'MikuFan',
          photoUrl: user.photoURL,
          provider: 'google',
        );
      } else {
        // Update lastLoginAt
        await _db.updateLastLogin(user.uid);
      }

      return AuthResult.ok(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        return AuthResult.fail(
          'This email is already registered with a different sign-in method. '
              'Please use email/password to sign in.',
        );
      }
      return AuthResult.fail(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.fail('Google sign-in error: $e');
    }
  }

  // ────────────────────────────────────────────────────────────
  // FORGOT PASSWORD
  // ────────────────────────────────────────────────────────────
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final methods = await _auth.fetchSignInMethodsForEmail(cleanEmail);
      if (methods.isEmpty) {
        return AuthResult._(success: true);
      }

      final actionCodeSettings = ActionCodeSettings(
        url: 'https://mikuplay.page.link/reset-password',
        handleCodeInApp: false,
        androidPackageName: 'com.mikuplay.app',
        androidInstallApp: true,
        androidMinimumVersion: '23',
      );

      await _auth.sendPasswordResetEmail(
        email: cleanEmail,
        actionCodeSettings: actionCodeSettings,
      );

      return AuthResult._(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.fail('Failed to send reset email. Try again.');
    }
  }

  // ────────────────────────────────────────────────────────────
  // SIGN OUT
  // ────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  // ────────────────────────────────────────────────────────────
  // UPDATE PROFIL
  // ────────────────────────────────────────────────────────────
  Future<void> updateProfile({
    String? username,
    String? photoUrl,
  }) async {
    final user = currentUser;
    if (user == null) return;

    if (username != null) await user.updateDisplayName(username);
    if (photoUrl != null) await user.updatePhotoURL(photoUrl);

    await _db.updateUserProfile(
      uid: user.uid,
      username: username,
      photoUrl: photoUrl,
    );
  }

  // ────────────────────────────────────────────────────────────
  // MAPPER ERROR CODE
  // ────────────────────────────────────────────────────────────
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check and try again.';
      case 'operation-not-allowed':
        return 'Sign-in method not enabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}