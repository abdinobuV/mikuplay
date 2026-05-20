// ============================================================
// FILE INI DISIMPAN DI:
// lib/features/profile/presentation/screens/profile_screen.dart
//
// BUAT FOLDER JIKA BELUM ADA:
// lib/features/profile/
// lib/features/profile/presentation/
// lib/features/profile/presentation/screens/
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';

// ── Data menu item profil (Figma: 5 menu item)
class _MenuData {
  final String    label;
  final IconData? icon;        // icon Material
  final String?   iconEmoji;   // emoji fallback jika tidak ada icon
  final String    route;       // route tujuan
  const _MenuData({
    required this.label,
    this.icon,
    this.iconEmoji,
    required this.route,
  });
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _menuItems = [
    _MenuData(
      label: 'Play History',
      icon: Icons.history_rounded,
      route: '/profile/history',
    ),
    _MenuData(
      label: 'Favorite Songs',
      iconEmoji: '♥',
      route: '/profile/favorites',
    ),
    _MenuData(
      label: 'Offline Downloads',
      iconEmoji: '↓',
      route: '/profile/downloads',
    ),
    _MenuData(
      label: 'Settings',
      icon: Icons.settings_rounded,
      route: '/profile/settings',
    ),
    _MenuData(
      label: 'Help & Support',
      iconEmoji: '?',
      route: '/profile/help',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // ── Dekorasi kiri (Figma: left=-60, top=61, size=262) ──
          Positioned(
            left: -60, top: 61,
            child: Container(
              width: 262, height: 262,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.06),
              ),
            ),
          ),
          // ── Dekorasi kanan bawah (Figma: left=262, top=404, size=202)
          Positioned(
            left: 262, top: 404,
            child: Container(
              width: 202, height: 202,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.04),
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 17),

                // ── Profile Header (avatar, name, handle, stats)
                _ProfileHeader(),

                // ── Menu items + logout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      // Menu items
                      ...List.generate(_menuItems.length, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _MenuItem(
                          data: _menuItems[i],
                          onTap: () {
                            // TODO: context.push(_menuItems[i].route);
                          },
                        ),
                      )),

                      const SizedBox(height: 24),

                      // ── Log Out button (Figma: border=red, transparent bg)
                      _LogOutButton(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => _LogOutDialog(
                              onConfirm: () async {
                                await AuthService.instance.signOut();
                                await FirestoreService.instance.clearLocalCache();
                                if (context.mounted) {
                                  context.go(Routes.login);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Space untuk bottom nav
                const SizedBox(height: 90),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Header (avatar, name, handle, stats) ───────────────
class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.deepCyanOp(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 56),

          // ── Avatar placeholder (Figma: size=89 ring, 71 photo) ──
          // TODO: ganti Container dalam ClipOval dengan
          //       Image.asset('assets/images/avatar.png') atau
          //       Image.network(userPhotoUrl)
          //       setelah kamu punya foto profil
          Stack(
            alignment: Alignment.center,
            children: [
              // Ring teal luar (Figma: size=89)
              Container(
                width: 89, height: 89,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tealOp(0.15),
                  border: Border.all(
                    color: AppColors.tealOp(0.5),
                    width: 1.5,
                  ),
                ),
              ),
          // Avatar (Figma: size=71, foto user)
          ClipOval(
            child: Container(
              width: 71, height: 71,
              color: AppColors.card,
              child: Image.asset(
                'assets/images/avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person_rounded,
                  size: 40,
                  color: AppColors.sky,
                ),
              ),
            ),
          ),
        ],
      ),
          const SizedBox(height: 14),

          // ── Nama (Figma: 18.2px semi bold)
          const Text(
            'Abdi Raihan',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),

          // ── Handle (Figma: 12.1px, teal)
          const Text(
            '@abdiMikuFan',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 16),

          // ── Stats row (Figma: Songs | Playlist | Favorites dengan divider)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(value: '247',  label: 'Songs'),
              _StatDivider(),
              _StatItem(value: '18',   label: 'Playlist'),
              _StatDivider(),
              _StatItem(value: '1.2K', label: 'Favorites'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, height: 30,
      color: AppColors.whiteOp(0.1),
    );
  }
}

// ── Stat item (angka + label) ───────────────────────────────────
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Value (Figma: 16.2px bold, white)
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 2),
        // Label (Figma: 10.1px, sky 60%)
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: AppColors.skyOp(0.6),
          ),
        ),
      ],
    );
  }
}

// ── Menu item row (Figma: h=57, rounded=12, bg=card) ─────────────
class _MenuItem extends StatelessWidget {
  final _MenuData    data;
  final VoidCallback onTap;
  const _MenuItem({required this.data, required this.onTap});

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
          border: Border.all(
            color: AppColors.deepCyanOp(0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 11),

            // ── Icon circle (Figma: size=34, rounded=99, bg=teal 12%)
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.12),
                border: Border.all(
                  color: AppColors.tealOp(0.25),
                  width: 1,
                ),
              ),
              child: Center(
                child: data.icon != null
                    ? Icon(data.icon, size: 18, color: AppColors.teal)
                    : Text(
                  data.iconEmoji!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Label ──────────────────────────────────────────────
            Expanded(
              child: Text(
                data.label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ),

            // ── Chevron › (Figma: 18.2px, sky 30%) ─────────────────
            Text(
              '›',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.skyOp(0.3),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

// ── Log Out Button (Figma: border=red, transparent, w=209, h=42, rounded=17)
class _LogOutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 209, height: 42,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: AppColors.red,
              width: 1,
            ),
          ),
          child: const Center(
            child: Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Konfirmasi logout dialog ────────────────────────────────────
class _LogOutDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const _LogOutDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
          color: AppColors.white,
        ),
      ),
      content: Text(
        'Are you sure you want to sign out of MikuPlay?',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.skyOp(0.8),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.skyOp(0.7)),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text(
            'Sign Out',
            style: TextStyle(
              color: AppColors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}