# MikuPlay

**MikuPlay** adalah aplikasi pemutar musik bertema Vocaloid yang dikembangkan menggunakan Flutter. Proyek ini mengadopsi prinsip *Clean Architecture* dengan pendekatan *Feature-first* untuk memastikan kode yang terstruktur, mudah dipelihara, dan dapat dikembangkan lebih lanjut secara profesional.

---

- **Nama:** Abdi Raihan Wibowo
- **NIM:** 5253151026

---

## 🌟 Fitur-Fitur Utama (Features)

Aplikasi MikuPlay bukan hanya pemutar musik biasa, melainkan dilengkapi dengan pengalaman pengguna (*user experience*) yang menyeluruh:

1. **Pemutar Musik Tingkat Lanjut (Audio Player)**
   - Streaming musik langsung dari penyimpanan *cloud* (Supabase).
   - Fitur lengkap pemutar musik sejati: **Play/Pause, Next/Previous, Shuffle (Acak), dan Repeat (Ulangi)**.
   - Pemutaran musik berjalan di latar belakang (*background audio*) didukung oleh `just_audio_background`.
   - Lirik lagu (*Lyrics Screen*) dan antrean putaran (*Up Next*).

2. **Otentikasi & Akun Pengguna**
   - Sistem pendaftaran dan masuk akun yang dienkripsi menggunakan **Firebase Authentication**.

3. **Daftar Putar Kustom (*Custom Playlists*) & Favorit**
   - Pengguna bisa membuat *playlist* mereka sendiri.
   - Menambahkan dan menghapus lagu ke dalam *playlist*.
   - Fitur "Suka" (*Like*) yang otomatis menyimpannya ke daftar putar "Favorit".
   - Tersinkronisasi secara *real-time* ke *database* **Firestore**.

4. **Riwayat Putaran (*Play History*)**
   - Secara otomatis melacak lagu yang sedang atau telah diputar oleh pengguna.
   - Mengelompokkan riwayat putaran berdasarkan hari (contoh: **"Today"**, **"Yesterday"**, **"Older"**).
   - Opsi untuk menghapus riwayat secara spesifik.

5. **Unduhan Luring (*Offline Downloads*) & Sinkronisasi Penyimpanan**
   - Lagu dapat diunduh untuk didengarkan secara *offline* tanpa internet.
   - Layar khusus **Offline Downloads** untuk mengelola semua file lagu lokal.
   - Sinkronisasi penyimpanan secara dinamis: menampilkan sisa memori/kapasitas (*storage*) perangkat *smartphone* asli milik pengguna (menggunakan `disk_space_2`).

6. **Tangga Lagu Nyata (*Real Top Charts*)**
   - Di halaman *Explore*, terdapat daftar **Top Charts** yang menampilkan lagu-lagu paling sering diputar (*Most Played*) dari *database* secara langsung dan bukan sekadar data palsu/tempelan.

7. **Desain UI/UX Premium & Transisi Halus**
   - Skema warna gelap yang *vibrant* dan *glossy* khas desain UI modern.
   - Transisi *snappy* seperti *Full Slide Up* saat membuka detail lagu.
   - *Card Layout* yang mengikuti desain resmi Figma.

---

## 🚀 Progres Proyek & Kemajuan

Pengembangan MikuPlay dibagi menjadi beberapa fase strategis. Berikut adalah status saat ini:

### ✅ Fase 1 — Setup & Core (Selesai)
- Inisialisasi proyek dan konfigurasi tema global (`AppColors`, `AppTheme`).
- Implementasi sistem navigasi menggunakan `GoRouter`.
- Setup konfigurasi Firebase dan Supabase.

### ✅ Fase 2 — Alur Otentikasi (Selesai)
- Implementasi `SplashScreen` dan `OnboardingScreen`.
- Layar Login, Signup (Step 1 & 2), dan Forgot Password.

### ✅ Fase 3 — Navigasi Utama (Selesai)
- Implementasi `ShellRoute` untuk navigasi bawah yang konsisten.
- Layar Utama (`HomeScreen`), Pencarian (`SearchScreen`), Perpustakaan (`LibraryScreen`), dan Profil (`ProfileScreen`).

### ✅ Fase 4 — Music Player (Selesai)
- Integrasi `just_audio` untuk *streaming* dan `just_audio_background` untuk pemutaran di latar belakang.
- Fitur pemutar tambahan: *Shuffle*, *Repeat*, Lirik.

### ✅ Fase 5 — Halaman Artis (Selesai)
- Implementasi `ArtistScreen` dengan daftar lagu dan desain *Card* yang elegan.

### ✅ Fase 6 — Fitur Lanjutan Profil & Database (Selesai)
- Pembuatan dan integrasi *Custom Playlists*, *Favorites*, *History*, dan *Offline Downloads*.
- Implementasi integrasi lintas basis data: **Firebase Firestore** (untuk data profil, *history*, *playlist*) dan **Supabase** (untuk master lagu dan *Top Charts*).

### ⏳ Fase 7 — QA Testing & Polishing (Sedang Berjalan)
- Penyesuaian mikro-animasi UI, perbaikan UX untuk *overflow*, optimalisasi performa.

---

## 🛠️ Teknologi & Arsitektur
- **Framework:** Flutter 3.x
- **Audio:** just_audio, just_audio_background, audio_video_progress_bar
- **Backend Master Data & Storage:** Supabase
- **Backend User Data & Auth:** Firebase (Authentication & Cloud Firestore)
- **Local Cache & Storage:** flutter_secure_storage, path_provider, disk_space_2
- **Navigasi:** go_router
- **UI:** Material 3, Lottie, Cached Network Image
