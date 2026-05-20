# MikuPlay

**MikuPlay** adalah aplikasi pemutar musik bertema Vocaloid yang dikembangkan menggunakan Flutter. Proyek ini mengadopsi prinsip *Clean Architecture* dengan pendekatan *Feature-first* untuk memastikan kode yang terstruktur, mudah dipelihara, dan dapat dikembangkan lebih lanjut.

---

- **Nama:** Abdi Raihan Wibowo
- **NIM:** 5253151026

---

## 🚀 Progres Proyek & Kemajuan

Pengembangan MikuPlay dibagi menjadi beberapa fase strategis sesuai dengan panduan struktur pada `mikuplay_flutter_structure.md`. Berikut adalah status saat ini:

### ✅ Fase 1 — Setup & Core (Selesai)
- Inisialisasi proyek dan struktur folder.
- Konfigurasi tema global (`AppColors`, `AppTheme`).
- Implementasi sistem navigasi menggunakan `GoRouter`.
- Setup Firebase Core dan konfigurasi dasar.

### ✅ Fase 2 — Alur Otentikasi (Selesai)
- Implementasi `SplashScreen` dengan navigasi otomatis.
- Pengembangan `OnboardingScreen` (3 halaman).
- Layar Login, Signup (Step 1 & 2), dan Forgot Password.

### ✅ Fase 3 — Navigasi Utama (Selesai)
- Implementasi `ShellRoute` untuk navigasi bawah yang konsisten.
- Layar Utama (`HomeScreen`), Pencarian (`SearchScreen`), Perpustakaan (`LibraryScreen`), dan Profil (`ProfileScreen`).
- Komponen UI kustom seperti `MikuBottomNav` dan `MiniPlayer`.

### 🏗️ Fase 4 — Music Player (Sedang Berjalan)
- Integrasi `just_audio` dan `audio_service` untuk pemutaran audio di latar belakang.
- Pengembangan layar `NowPlayingScreen`.
- Implementasi fitur animasi seperti `LikeButton` dan `TapScaleWidget`.

### ⏳ Fase Selanjutnya (Direncanakan)
- **Fase 5:** Halaman Artis (Miku, KAITO, GUMI, dll).
- **Fase 6:** Fitur lanjutan Profil (Riwayat, Favorit, Unduhan/Hive Offline).
- **Fase 7:** Poles akhir, animasi transisi, dan QA Testing.

---

## 🛠️ Teknologi & Arsitektur
Aplikasi ini dibangun dengan teknologi modern untuk memberikan pengalaman pengguna yang mulus:
- **Framework:** Flutter 3.x
- **State Management:** Riverpod (Partial)
- **Navigasi:** GoRouter
- **Audio:** just_audio, audio_service
- **Backend:** Firebase (Auth, Firestore)
- **Local Storage:** Hive & Flutter Secure Storage
- **UI:** Material 3, Lottie, Custom Animations

---

Untuk informasi lebih lanjut mengenai struktur teknis detail, silakan merujuk ke file [mikuplay_flutter_structure.md](mikuplay_flutter_structure.md).
