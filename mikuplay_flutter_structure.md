# MikuPlay — Flutter Project Structure
> Flutter 3.x · Dart 3 · Clean Architecture · Feature-first · Riverpod

---

## Cara setup awal

```bash
flutter create mikuplay --org com.mikuplay --platforms android,ios
cd mikuplay
```

---

## Struktur Direktori Lengkap

```
mikuplay/
├── android/                          # Android native config
├── ios/                              # iOS native config
├── assets/
│   ├── fonts/
│   │   └── Inter/                    # Inter Regular, Medium, SemiBold, Bold
│   ├── images/
│   │   ├── logo.png
│   │   └── onboarding/
│   │       ├── ob1_music.png
│   │       ├── ob2_lyrics.png
│   │       └── ob3_playlist.png
│   ├── icons/
│   │   └── app_icon.png
│   └── lottie/                       # Animasi Lottie (opsional)
│       ├── like_animation.json
│       └── loading.json
│
├── lib/
│   ├── main.dart                     # Entry point
│   ├── app.dart                      # MaterialApp + GoRouter + ProviderScope
│   │
│   ├── core/                         # Shared across ALL features
│   │   ├── constants/
│   │   │   ├── app_colors.dart       # Hatsune Miku palette tokens
│   │   │   ├── app_typography.dart   # Inter font scale
│   │   │   ├── app_spacing.dart      # 4/8/12/16/24/32/48px scale
│   │   │   ├── app_borders.dart      # Border radius (8/12/16/44px)
│   │   │   └── app_strings.dart      # All UI strings (en-US)
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart        # ThemeData dark (navy base)
│   │   │   ├── color_scheme.dart     # Miku teal/navy/sky/red tokens
│   │   │   └── text_theme.dart       # Inter text styles
│   │   │
│   │   ├── router/
│   │   │   ├── app_router.dart       # GoRouter config + all routes
│   │   │   └── route_names.dart      # Route name constants
│   │   │
│   │   ├── di/
│   │   │   └── injection.dart        # GetIt service locator setup
│   │   │
│   │   ├── network/
│   │   │   ├── dio_client.dart       # Dio instance + interceptors
│   │   │   ├── api_endpoints.dart    # Base URLs + endpoint paths
│   │   │   └── network_info.dart     # Connectivity check
│   │   │
│   │   ├── storage/
│   │   │   ├── hive_storage.dart     # Local cache (downloads, history)
│   │   │   └── secure_storage.dart   # Token storage (flutter_secure_storage)
│   │   │
│   │   ├── utils/
│   │   │   ├── duration_format.dart  # "4:33" formatter
│   │   │   ├── file_size_format.dart # "8.2 MB" formatter
│   │   │   ├── validators.dart       # Email, password validators
│   │   │   └── extensions/
│   │   │       ├── string_ext.dart
│   │   │       ├── context_ext.dart  # MediaQuery, Theme shortcuts
│   │   │       └── datetime_ext.dart
│   │   │
│   │   └── errors/
│   │       ├── failures.dart         # Sealed failure classes
│   │       └── exceptions.dart       # Custom exceptions
│   │
│   ├── shared/                       # Reusable widgets across features
│   │   ├── widgets/
│   │   │   ├── miku_app_bar.dart         # Custom header/navbar
│   │   │   ├── miku_bottom_nav.dart      # Bottom navigation bar
│   │   │   ├── miku_button.dart          # Primary / ghost / pill variants
│   │   │   ├── miku_text_field.dart      # Styled input field
│   │   │   ├── miku_card.dart            # Base card component
│   │   │   ├── miku_badge.dart           # Status badge (green/amber/red)
│   │   │   ├── miku_avatar.dart          # Circular avatar
│   │   │   ├── miku_bottom_sheet.dart    # Modal bottom sheet
│   │   │   ├── miku_toast.dart           # Toast notification (like ♥)
│   │   │   ├── miku_loading.dart         # Loading indicator
│   │   │   ├── track_list_item.dart      # Song row (name, artist, duration)
│   │   │   ├── artist_avatar.dart        # Artist circle with color ring
│   │   │   ├── waveform_visualizer.dart  # Audio waveform bar widget
│   │   │   └── deco_circle.dart          # Background decoration circle
│   │   │
│   │   └── providers/
│   │       └── connectivity_provider.dart
│   │
│   ├── features/
│   │   │
│   │   ├── auth/                     # GROUP 01 · Auth & Onboarding
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── auth_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── user_model.dart
│   │   │   │   │   └── auth_response_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart   # abstract
│   │   │   │   └── use_cases/
│   │   │   │       ├── sign_in_usecase.dart
│   │   │   │       ├── sign_up_usecase.dart
│   │   │   │       ├── sign_out_usecase.dart
│   │   │   │       └── forgot_password_usecase.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart       # Riverpod StateNotifier
│   │   │       └── screens/
│   │   │           ├── splash_screen.dart        # 01
│   │   │           ├── onboarding_screen.dart    # 02 (PageView 3 pages)
│   │   │           ├── login_screen.dart         # 03
│   │   │           ├── signup_screen.dart        # 16
│   │   │           ├── register_screen.dart      # 14
│   │   │           └── forgot_password_screen.dart
│   │   │
│   │   ├── home/                     # GROUP 02 · Main Navigation
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── home_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── featured_track_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── home_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── featured_track_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── home_repository.dart
│   │   │   │   └── use_cases/
│   │   │   │       ├── get_trending_usecase.dart
│   │   │   │       └── get_recent_usecase.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── home_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── home_screen.dart          # 04
│   │   │       └── widgets/
│   │   │           ├── featured_banner.dart
│   │   │           ├── section_header.dart
│   │   │           └── stats_chip.dart
│   │   │
│   │   ├── search/                   # Search & Explore
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── search_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── search_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── search_result_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── search_repository.dart
│   │   │   │   └── use_cases/
│   │   │   │       └── search_usecase.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── search_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── search_screen.dart        # 05
│   │   │       └── widgets/
│   │   │           ├── category_card.dart
│   │   │           └── chart_row.dart
│   │   │
│   │   ├── player/                   # GROUP 03 · Music Player
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── player_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   ├── track_model.dart
│   │   │   │   │   └── lyrics_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── player_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── track_entity.dart
│   │   │   │   │   └── lyrics_line_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── player_repository.dart
│   │   │   │   └── use_cases/
│   │   │   │       ├── play_track_usecase.dart
│   │   │   │       ├── get_queue_usecase.dart
│   │   │   │       └── get_lyrics_usecase.dart
│   │   │   │
│   │   │   ├── services/
│   │   │   │   └── audio_service.dart            # just_audio wrapper
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── player_provider.dart      # play state, progress
│   │   │       │   ├── queue_provider.dart
│   │   │       │   └── lyrics_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── song_detail_screen.dart   # 17
│   │   │       │   ├── now_playing_screen.dart   # 06 + 22 (liked state)
│   │   │       │   ├── queue_screen.dart          # 11
│   │   │       │   └── lyrics_screen.dart         # 12
│   │   │       └── widgets/
│   │   │           ├── album_art.dart
│   │   │           ├── player_controls.dart
│   │   │           ├── progress_bar.dart
│   │   │           ├── volume_slider.dart
│   │   │           ├── like_button.dart           # animated ♡ → ♥
│   │   │           ├── lyrics_view.dart           # sync highlight
│   │   │           ├── mini_player.dart           # bottom bar
│   │   │           └── queue_item.dart
│   │   │
│   │   ├── artist/                   # GROUP 04 · Discover & Artist
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── artist_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── artist_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── artist_repository_impl.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── artist_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── artist_repository.dart
│   │   │   │   └── use_cases/
│   │   │   │       ├── get_artist_usecase.dart
│   │   │   │       └── follow_artist_usecase.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── artist_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── artist_screen.dart        # 23/24/25 (param: artistId)
│   │   │       └── widgets/
│   │   │           ├── artist_hero.dart
│   │   │           ├── artist_stats_bar.dart
│   │   │           ├── top_hits_list.dart
│   │   │           └── album_strip.dart
│   │   │
│   │   ├── library/                  # Playlist & Library
│   │   │   ├── data/
│   │   │   │   └── repositories/
│   │   │   │       └── library_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── playlist_entity.dart
│   │   │   │   └── use_cases/
│   │   │   │       └── get_playlists_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── library_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── library_screen.dart       # 07
│   │   │       └── widgets/
│   │   │           ├── playlist_item.dart
│   │   │           └── filter_pills.dart
│   │   │
│   │   └── profile/                  # GROUP 05 · Profile & Settings
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   │   └── profile_remote_datasource.dart
│   │       │   └── repositories/
│   │       │       └── profile_repository_impl.dart
│   │       │
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   └── profile_entity.dart
│   │       │   └── use_cases/
│   │       │       ├── get_profile_usecase.dart
│   │       │       ├── get_play_history_usecase.dart
│   │       │       ├── get_favorites_usecase.dart
│   │       │       └── get_downloads_usecase.dart
│   │       │
│   │       └── presentation/
│   │           ├── providers/
│   │           │   ├── profile_provider.dart
│   │           │   ├── history_provider.dart
│   │           │   ├── favorites_provider.dart
│   │           │   └── downloads_provider.dart
│   │           ├── screens/
│   │           │   ├── profile_screen.dart           # 08
│   │           │   ├── play_history_screen.dart      # 18
│   │           │   ├── favorites_screen.dart         # 19
│   │           │   ├── downloads_screen.dart         # 20
│   │           │   ├── settings_screen.dart          # 15
│   │           │   ├── equalizer_screen.dart         # 13
│   │           │   ├── notifications_screen.dart     # new
│   │           │   └── help_screen.dart              # 21
│   │           └── widgets/
│   │               ├── profile_header.dart
│   │               ├── menu_item_row.dart
│   │               ├── storage_card.dart
│   │               ├── eq_bar.dart
│   │               └── track_history_item.dart
│   │
└── test/
    ├── unit/
    │   ├── use_cases/
    │   └── providers/
    ├── widget/
    │   ├── shared/
    │   └── features/
    └── integration/
        └── auth_flow_test.dart
```

---

## pubspec.yaml (dependencies)

```yaml
name: mikuplay
description: MikuPlay - Your Vocaloid Universe
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Navigation
  go_router: ^13.0.0

  # Audio Player
  just_audio: ^0.9.36
  just_audio_background: ^0.0.1-beta.10
  audio_service: ^0.18.12

  # Network
  dio: ^5.4.0
  retrofit: ^4.1.0
  pretty_dio_logger: ^1.3.1

  # Local Storage
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0

  # Code Generation / Models
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # DI
  get_it: ^7.6.7

  # UI
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  lottie: ^3.0.0
  shimmer: ^3.0.0

  # Utilities
  dartz: ^0.10.1           # Functional Either (success/failure)
  connectivity_plus: ^5.0.2
  permission_handler: ^11.2.0
  path_provider: ^2.1.2
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  build_runner: ^2.4.8
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  retrofit_generator: ^8.1.0
  riverpod_generator: ^2.3.9
  hive_generator: ^2.0.1
  mockito: ^5.4.4
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/images/onboarding/
    - assets/icons/
    - assets/lottie/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter/Inter-Regular.ttf
        - asset: assets/fonts/Inter/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter/Inter-Bold.ttf
          weight: 700
```

---

## core/constants/app_colors.dart

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary — Hatsune Miku Palette
  static const navy      = Color(0xFF030360);  // background dark
  static const teal      = Color(0xFF00B4D8);  // primary action
  static const deepCyan  = Color(0xFF0077B6);  // secondary
  static const sky       = Color(0xFF90E0EF);  // muted text / border
  static const ice       = Color(0xFFCAF0F8);  // light surface
  static const white     = Color(0xFFF8F9FA);  // text on dark

  // Surfaces
  static const navySurf  = Color(0xFF050535);  // card background
  static const navyCard  = Color(0xFF080850);  // elevated card

  // Semantic
  static const red       = Color(0xFFE63946);  // like / error / badge
  static const green     = Color(0xFF22C55E);  // success / live dot
  static const amber     = Color(0xFFFAC515);  // warning
}
```

---

## core/router/app_router.dart (structure)

```dart
// Routes map 1:1 with Figma screens
//
// /                         → SplashScreen
// /onboarding               → OnboardingScreen (3 pages internal)
// /login                    → LoginScreen
// /signup                   → SignupScreen
// /register                 → RegisterScreen
// /forgot-password          → ForgotPasswordScreen
//
// /home                     → HomeScreen (ShellRoute w/ bottom nav)
//   /home/search            → SearchScreen
//   /home/library           → LibraryScreen
//   /home/profile           → ProfileScreen
//
// /player/:trackId          → NowPlayingScreen
// /player/:trackId/lyrics   → LyricsScreen
// /player/:trackId/queue    → QueueScreen
// /song/:trackId            → SongDetailScreen
//
// /artist/:artistId         → ArtistScreen (Miku / KAITO / GUMI)
//
// /profile/history          → PlayHistoryScreen
// /profile/favorites        → FavoritesScreen
// /profile/downloads        → DownloadsScreen
// /profile/settings         → SettingsScreen
// /profile/settings/eq      → EqualizerScreen
// /profile/notifications    → NotificationsScreen
// /profile/help             → HelpScreen
```

---

## Urutan Pengerjaan yang Disarankan

```
Phase 1  — Setup & Core
  ✅ Project init, pubspec, folder structure
  ✅ AppColors, AppTheme, AppTypography
  ✅ GoRouter setup
  ✅ GetIt DI registration

Phase 2  — Auth Flow (Screens 01–07)
  ✅ SplashScreen (2.5s auto-navigate)
  ✅ OnboardingScreen (PageView, 3 pages)
  ✅ LoginScreen + SignupScreen + RegisterScreen
  ✅ ForgotPasswordScreen

Phase 3  — Main Navigation (Screens 04–08)
  ✅ ShellRoute + MikuBottomNav
  ✅ HomeScreen (Featured + Recent)
  ✅ SearchScreen (categories → artist)
  ✅ LibraryScreen (playlists)
  ✅ ProfileScreen + menu items

Phase 4  — Music Player (Screens 06, 11, 12, 17, 22)
  ✅ AudioService (just_audio)
  ✅ NowPlayingScreen (+ liked state)
  ✅ SongDetailScreen
  ✅ QueueScreen
  ✅ LyricsScreen (sync highlight)
  ✅ MiniPlayer (persistent)

Phase 5  — Artist Pages (Screens 23–25)
  ✅ ArtistScreen (param-based: Miku / KAITO / GUMI)
  ✅ Follow button state
  ✅ Top hits list

Phase 6  — Profile Sub-pages (Screens 13, 15, 18–21)
  ✅ PlayHistoryScreen
  ✅ FavoritesScreen
  ✅ DownloadsScreen + Hive offline
  ✅ SettingsScreen
  ✅ EqualizerScreen
  ✅ NotificationsScreen
  ✅ HelpScreen

Phase 7  — Polish & QA
  ✅ Animations & transitions (matched Figma prototype)
  ✅ Dark mode consistency
  ✅ Unit & widget tests
  ✅ Performance audit (jank-free scrolling)
```
