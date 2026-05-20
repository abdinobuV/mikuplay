# Player Feature Implementation

This plan outlines the steps to implement the Now Playing Screen, Song Detail Screen, and Mini Player features using `just_audio` and Firebase Storage.

## Storage Strategy: Firebase vs Local
For this project, I will use **Firebase Storage** for the following reasons:
1. **Scalability**: Your app can grow without increasing the APK size.
2. **Efficiency**: Only the current song is downloaded/streamed, saving user bandwidth.
3. **Caching**: We will use `just_audio`'s streaming capabilities and `cached_network_image` to ensure a smooth experience even with slow connections.

## Proposed Changes

### Core

#### [NEW] [song_model.dart](file:///D:/abdi/mikuplay/lib/core/models/song_model.dart)
- Define the `Song` model with fields for title, artist, image, audio URL, and metadata.

#### [NEW] [audio_player_service.dart](file:///D:/abdi/mikuplay/lib/core/services/audio_player_service.dart)
- Singleton service managing `just_audio.AudioPlayer`.
- Expose streams for state (playing, current song, position, duration).
- Methods for play, pause, seek, and skip.

---

### Shared Widgets

#### [NEW] [mini_player.dart](file:///D:/abdi/mikuplay/lib/shared/widgets/mini_player.dart)
- Floating mini player that appears when a song is loaded.
- Basic controls: play/pause, song info.
- Tapping it opens the Now Playing screen.

---

### Player Feature

#### [NEW] [now_playing_screen.dart](file:///D:/abdi/mikuplay/lib/features/player/presentation/screens/now_playing_screen.dart)
- Full-screen player matching the provided design.
- Features: Album art, song info, visualizer (placeholder/simple), progress bar, playback controls, and metadata stats.

---

### Router & Integration

#### [app_router.dart](file:///D:/abdi/mikuplay/lib/core/router/app_router.dart)
- Register `NowPlayingScreen` route.
- Update `_MainShell` to include `MiniPlayer` above the bottom navigation bar.

#### [home_screen.dart](file:///D:/abdi/mikuplay/lib/features/home/presentation/screens/home_screen.dart)
- Update track rows to trigger playback via `AudioPlayerService`.

## Verification Plan

### Manual Verification
- Verify audio plays correctly.
- Verify Mini Player appears and functions (play/pause).
- Verify navigation from Mini Player to Now Playing Screen.
- Verify Now Playing Screen UI matches the design.
- Verify progress bar and seeking work.
