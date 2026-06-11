import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../core/models/song_model.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class _TrackData {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final String? imagePath;
  final String audioUrl;
  final String album;
  final String year;
  final String? lyrics;

  const _TrackData({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    this.imagePath,
    required this.audioUrl,
    this.album = 'Vocaloid Classic',
    this.year = '2024',
    this.lyrics,
  });

  Song toSong() {
    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      imageUrl: imagePath != null ? 'assets/images/$imagePath' : '',
      audioUrl: audioUrl,
      duration: _parseDuration(duration),
      year: year,
      lyrics: lyrics,
    );
  }

  Duration _parseDuration(String d) {
    final parts = d.split(':');
    if (parts.length == 2) {
      return Duration(minutes: int.parse(parts[0]), seconds: int.parse(parts[1]));
    }
    return Duration.zero;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ── Data lagu recently played (dari Figma) ──────────────────
  static const _recentTracks = [
    _TrackData(
      id: '1',
      title: 'World is Mine',
      artist: 'ryo',
      duration: '4:09',
      imagePath: 'world_is_mine.png',
      audioUrl: 'assets/audio/world_is_mine.mp3', 
    ),
    _TrackData(
      id: '2',
      title: 'Decorator',
      artist: 'Livetune',
      duration: '5:02',
      imagePath: 'decorator_art.png',
      audioUrl: 'assets/audio/decorator.mp3',
    ),
    _TrackData(
      id: '3',
      title: 'Hibikase',
      artist: 'GigaP',
      duration: '3:58',
      imagePath: 'hibikase_art.png',
      audioUrl: 'assets/audio/hibikase.mp3',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService();
    // Inisialisasi playlist agar fitur Next berfungsi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final songs = _recentTracks.map((t) => t.toSong()).toList();
      // Tambahkan Melt ke playlist juga
      songs.insert(0, const _TrackData(
        id: 'trending_1',
        title: 'Melt',
        artist: 'ryo',
        duration: '4:33',
        imagePath: 'melt_cover_art.png',
        audioUrl: 'assets/audio/melt.mp3',
        year: '2007',
        lyrics: '''[00:00.00] Melt - Hatsune Miku (ryo)
[00:15.50] Asa me ga samete
[00:18.20] Makkuni omoi ukabu kimi no koto
[00:23.10] Kaminoke o kitte
[00:25.80] Kimi ga doushite tte kitte kurenai ka na
[00:31.00] Melt toketeshimaisou
[00:36.50] Suki da nante zettai ni ienai...
[00:43.00] Dakedo Melt me mo awaserarenai
[00:49.50] Koi ni koi nante shinai wa watashi
[00:54.00] Datte kimi no koto ga...
[00:58.50] Suki na no''',
      ).toSong());
      audioService.setPlaylist(songs);
    });

    return Scaffold(
      backgroundColor: AppColors.navy,
      drawer: const _ProfileDrawer(),
      body: Stack(
        children: [
          // Dekorasi kanan atas (khusus tab Home)
          Positioned(
            left: 262, top: -61,
            child: Container(
              width: 222, height: 222,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.05),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 44),
              _Navbar(onNotificationTap: () {
                context.push(Routes.notifications);
              }),
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _SearchBar(),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Trending Vocaloid'),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _FeaturedCard(onTap: () {
                        final song = const _TrackData(
                          id: 'trending_1',
                          title: 'Melt',
                          artist: 'ryo',
                          duration: '4:33',
                          imagePath: 'melt_cover_art.png',
                          audioUrl: 'assets/audio/melt.mp3',
                          year: '2007',
                        ).toSong();
                        context.push(Routes.songDetail, extra: song);
                      }),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Recently Played', showSeeAll: false),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: _recentTracks.map((track) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TrackRow(
                            data: track,
                            onTap: () => context.push(Routes.songDetail, extra: track.toSong()),
                          ),
                        )).toList(),
                      ),
                    ),
                    // Beri space agar konten tidak tertutup Mini Player di bawah
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showSeeAll = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          if (showSeeAll)
            GestureDetector(
              onTap: () {},
              child: const Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.teal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// WIDGETS
// ══════════════════════════════════════════════════════════════

class _Navbar extends StatelessWidget {
  final VoidCallback onNotificationTap;
  const _Navbar({required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.navy, Color(0xFF0609C4)],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.deepCyanOp(0.2), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _AnimatedAvatar(
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
            const SizedBox(width: 12),
            Text(
              'Hey, ${AuthService.instance.currentUser?.displayName?.split(' ').first ?? 'User'} ',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onNotificationTap,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined, size: 24, color: AppColors.white),
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.tealOp(0.25), width: 1),
      ),
      child: const Center(
        child: Text(
          'Search songs, artists, playlists...',
          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.white),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final VoidCallback onTap;
  const _FeaturedCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 140,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.tealOp(0.2), width: 1.5),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 140, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.tealOp(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.tealOp(0.3)),
                    ),
                    child: const Text(
                      'TRENDING',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Melt — ryo',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hatsune Miku · 2007\n808K plays',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.skyOp(0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -40, top: -10, bottom: -10,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha((0.4 * 255).toInt()), blurRadius: 15, spreadRadius: 2),
                    ],
                  ),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/melt_cover_art.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.tealOp(0.2),
                            child: const Icon(Icons.music_note, color: AppColors.teal, size: 40),
                          ),
                        ),
                        Container(color: Colors.black.withAlpha((0.1 * 255).toInt())),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 25, bottom: 15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.5 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '4:33',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  final _TrackData   data;
  final VoidCallback onTap;
  const _TrackRow({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 57,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.deepCyanOp(0.15), width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 9),
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.15),
                border: Border.all(color: AppColors.tealOp(0.3), width: 1),
              ),
              child: ClipOval(
                child: data.imagePath != null
                    ? Image.asset(
                        'assets/images/${data.imagePath}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildMusicIcon(),
                      )
                    : _buildMusicIcon(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.artist,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.skyOp(0.7)),
                  ),
                ],
              ),
            ),
            Text(
              data.duration,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.skyOp(0.5)),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicIcon() {
    return Center(child: Icon(Icons.music_note_rounded, size: 18, color: AppColors.tealOp(0.6)));
  }
}

class _AnimatedAvatar extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedAvatar({required this.onTap});

  @override
  State<_AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<_AnimatedAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 39, height: 39,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Fallback to withOpacity if tealOp is not static, but it seems to be defined.
            // Using withOpacity to be safe if AppColors.tealOp is not available here. Wait, it was used above!
            // But let's just copy what was there:
            color: AppColors.tealOp(0.3),
            border: Border.all(color: AppColors.tealOp(0.5), width: 1),
          ),
          child: ClipOval(
            child: _buildAvatarImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    final photoUrl = AuthService.instance.currentUser?.photoURL;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: photoUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Icon(Icons.person, color: AppColors.teal),
        );
      } else {
        return Image.file(
          File(photoUrl),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.teal),
        );
      }
    }
    
    return Image.asset(
      'assets/images/avatar.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.teal),
    );
  }
}

class _ProfileDrawer extends StatelessWidget {
  const _ProfileDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.navy,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.tealOp(0.2))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.tealOp(0.8), width: 2),
                    ),
                    child: ClipOval(
                      child: _buildDrawerAvatarImage(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hey, ${AuthService.instance.currentUser?.displayName?.split(' ').first ?? 'User'}',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AuthService.instance.currentUser?.email ?? '',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.sky),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _DrawerItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () {
                      Scaffold.of(context).closeDrawer();
                      context.go(Routes.profile);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.history,
                    title: 'History',
                    onTap: () {
                      Scaffold.of(context).closeDrawer();
                      context.push(Routes.history);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Scaffold.of(context).closeDrawer();
                      context.push(Routes.settings);
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            _DrawerItem(
              icon: Icons.logout,
              title: 'Log out',
              color: AppColors.red,
              onTap: () {
                Scaffold.of(context).closeDrawer();
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.deepCyanOp(0.2)),
                    ),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: AppColors.white),
                    ),
                    content: Text(
                      'Are you sure you want to sign out of MikuPlay?',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.skyOp(0.8)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text('Cancel', style: TextStyle(color: AppColors.skyOp(0.7))),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await AuthService.instance.signOut();
                          await FirestoreService.instance.clearLocalCache();
                          if (context.mounted) context.go(Routes.login);
                        },
                        child: const Text('Sign Out', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerAvatarImage() {
    final photoUrl = AuthService.instance.currentUser?.photoURL;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: photoUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Icon(Icons.person, color: AppColors.teal, size: 30),
        );
      } else {
        return Image.file(
          File(photoUrl),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.teal, size: 30),
        );
      }
    }
    
    return Image.asset(
      'assets/images/avatar.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.teal, size: 30),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.color = AppColors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: color == AppColors.white ? AppColors.tealOp(0.8) : color, size: 24),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w500, color: color),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

