import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import '../../../../core/services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<Song> _songs = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  Future<void> _fetchSongs() async {
    final songs = await SupabaseService().getAllSongs();
    if (mounted) {
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
      AudioPlayerService().setPlaylist(_songs);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      drawer: const _ProfileDrawer(),
      body: Stack(
        children: [
          // Dekorasi kanan atas (khusus tab Home)
          Positioned(
            left: 262,
            top: -61,
            child: Container(
              width: 222,
              height: 222,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SearchBar(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child:
                              CircularProgressIndicator(color: AppColors.teal),
                        ),
                      )
                    else if (_songs.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Text(
                            'No songs found. Check your connection!',
                            style: TextStyle(
                                color: AppColors.sky, fontFamily: 'Inter'),
                          ),
                        ),
                      )
                    else if (_searchQuery.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Builder(
                        builder: (context) {
                          final query = _searchQuery.toLowerCase();
                          final filtered = _songs
                              .where((s) =>
                                  s.title.toLowerCase().contains(query) ||
                                  s.artist.toLowerCase().contains(query))
                              .toList();

                          if (filtered.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 60),
                                child: Text('No results found',
                                    style: TextStyle(
                                        color: AppColors.sky,
                                        fontFamily: 'Inter')),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: filtered
                                  .map((song) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: _TrackRow(
                                          song: song,
                                          onTap: () => context.push(
                                              Routes.songDetail,
                                              extra: song),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      const SizedBox(height: 20),
                      _buildSectionHeader('Trending Vocaloid'),
                      const SizedBox(height: 10),
                      if (_songs.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _FeaturedCard(
                            song: _songs.first,
                            onTap: () {
                              context.push(Routes.songDetail,
                                  extra: _songs.first);
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      _buildSectionHeader('Recently Played', showSeeAll: false),
                      const SizedBox(height: 10),
                      if (_songs.length > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: _songs
                                .skip(1)
                                .map((song) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: _TrackRow(
                                        song: song,
                                        onTap: () => context.push(
                                            Routes.songDetail,
                                            extra: song),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                    // Beri space agar konten tidak tertutup Mini Player di bawah
                    const SizedBox(height: 100),
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
                  const Icon(Icons.notifications_outlined,
                      size: 24, color: AppColors.white),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.red),
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
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.tealOp(0.25), width: 1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
            fontFamily: 'Inter', fontSize: 13, color: AppColors.white),
        decoration: InputDecoration(
          hintText: 'Search songs, artists, playlists...',
          hintStyle: TextStyle(
              fontFamily: 'Inter', fontSize: 13, color: AppColors.skyOp(0.6)),
          prefixIcon: const Icon(Icons.search, color: AppColors.teal, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  const _FeaturedCard({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 140.h,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  Text(
                    '${song.title} — ${song.artist}',
                    style: const TextStyle(
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
                    '${song.artist} · ${song.year.isEmpty ? "2024" : song.year}\n808K plays',
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
              right: -40,
              top: -10,
              bottom: -10,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha((0.4 * 255).toInt()),
                          blurRadius: 15,
                          spreadRadius: 2),
                    ],
                  ),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        song.imageUrl.isNotEmpty
                            ? (song.imageUrl.startsWith('http')
                                ? CachedNetworkImage(
                                    imageUrl: song.imageUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        Container(color: AppColors.tealOp(0.2)),
                                  )
                                : Image.asset(
                                    song.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(color: AppColors.tealOp(0.2)),
                                  ))
                            : Container(
                                color: AppColors.tealOp(0.2),
                                child: const Icon(Icons.music_note,
                                    color: AppColors.teal, size: 40),
                              ),
                        Container(
                            color: Colors.black.withAlpha((0.1 * 255).toInt())),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 25,
              bottom: 15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.5 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${song.duration.inMinutes}:${(song.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
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
  final Song song;
  final VoidCallback onTap;
  const _TrackRow({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 57.h,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.deepCyanOp(0.15), width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 9),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.15),
                border: Border.all(color: AppColors.tealOp(0.3), width: 1),
              ),
              child: ClipOval(
                child: song.imageUrl.isNotEmpty
                    ? (song.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: song.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _buildMusicIcon(),
                          )
                        : Image.asset(
                            song.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildMusicIcon(),
                          ))
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
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.skyOp(0.7)),
                  ),
                ],
              ),
            ),
            Text(
              '${song.duration.inMinutes}:${(song.duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.skyOp(0.5)),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicIcon() {
    return Center(
        child: Icon(Icons.music_note_rounded,
            size: 18, color: AppColors.tealOp(0.6)));
  }
}

class _AnimatedAvatar extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedAvatar({required this.onTap});

  @override
  State<_AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<_AnimatedAvatar>
    with SingleTickerProviderStateMixin {
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
          width: 39,
          height: 39,
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
          errorWidget: (context, url, error) =>
              const Icon(Icons.person, color: AppColors.teal),
        );
      } else {
        return Image.file(
          File(photoUrl),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.person, color: AppColors.teal),
        );
      }
    }

    return Image.asset(
      'assets/images/avatar.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.person, color: AppColors.teal),
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
                border:
                    Border(bottom: BorderSide(color: AppColors.tealOp(0.2))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.tealOp(0.8), width: 2),
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
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AuthService.instance.currentUser?.email ?? '',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppColors.sky),
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
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 8),
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
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                color: AppColors.white),
                          ),
                          content: Text(
                            'Are you sure you want to sign out of MikuPlay?',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.skyOp(0.8)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: Text('Cancel',
                                  style:
                                      TextStyle(color: AppColors.skyOp(0.7))),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                await AuthService.instance.signOut();
                                await FirestoreService.instance
                                    .clearLocalCache();
                                if (context.mounted) context.go(Routes.login);
                              },
                              child: const Text('Sign Out',
                                  style: TextStyle(
                                      color: AppColors.red,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80), // Extra space to clear MiniPlayer
                ],
              ),
            ),
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
          errorWidget: (context, url, error) =>
              const Icon(Icons.person, color: AppColors.teal, size: 30),
        );
      } else {
        return Image.file(
          File(photoUrl),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.person, color: AppColors.teal, size: 30),
        );
      }
    }

    return Image.asset(
      'assets/images/avatar.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.person, color: AppColors.teal, size: 30),
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
      leading: Icon(icon,
          color: color == AppColors.white ? AppColors.tealOp(0.8) : color,
          size: 24),
      title: Text(
        title,
        style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: color),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
