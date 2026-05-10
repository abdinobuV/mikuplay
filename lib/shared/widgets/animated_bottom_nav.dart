// ============================================================
// FILE INI DISIMPAN DI:
// lib/shared/widgets/animated_bottom_nav.dart
//
// BUAT FOLDER JIKA BELUM ADA: lib/shared/widgets/
// ============================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Bottom navigation dengan dua animasi:
/// 1. Sliding indicator — garis teal yang bergerak mulus antar tab
/// 2. Icon scale + color — icon tab aktif sedikit membesar saat dipilih
///
/// Tidak ada bounce, tidak ada efek yang berlebihan.
/// Clean, subtle, dan terasa premium.
class AnimatedBottomNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const AnimatedBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<AnimatedBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _indicatorCtrl;
  late Animation<double> _indicatorAnim;

  // Track previous index untuk arah animasi indicator
  int _prevIndex = 0;

  static const _items = [
    _NavItem(icon: Icons.home_filled,           activeIcon: Icons.home_filled,        label: 'Home'),
    _NavItem(icon: Icons.search_outlined,        activeIcon: Icons.search_rounded,     label: 'Search'),
    _NavItem(icon: Icons.library_music_outlined, activeIcon: Icons.library_music_rounded, label: 'Library'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,     label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.selectedIndex;
    _indicatorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _indicatorAnim = Tween<double>(
      begin: widget.selectedIndex.toDouble(),
      end:   widget.selectedIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _indicatorCtrl,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  void didUpdateWidget(AnimatedBottomNav old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      // Animasikan dari tab lama ke tab baru
      _indicatorAnim = Tween<double>(
        begin: _prevIndex.toDouble(),
        end:   widget.selectedIndex.toDouble(),
      ).animate(CurvedAnimation(
        parent: _indicatorCtrl,
        curve: Curves.fastOutSlowIn,
      ));
      _indicatorCtrl.forward(from: 0);
      _prevIndex = widget.selectedIndex;
    }
  }

  @override
  void dispose() {
    _indicatorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Figma: h=77, bg=#050933, border-top deepCyan 20%
      height: 77,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.deepCyanOp(0.2), width: 1),
        ),
      ),
      child: Stack(
        children: [
          // ── Sliding indicator bar di bagian atas nav ────────
          AnimatedBuilder(
            animation: _indicatorAnim,
            builder: (_, __) {
              final tabWidth = MediaQuery.of(context).size.width / _items.length;
              final indicatorX = _indicatorAnim.value * tabWidth;
              const indicatorW = 28.0;
              return Positioned(
                top: 0,
                left: indicatorX + (tabWidth - indicatorW) / 2,
                child: Container(
                  width: indicatorW,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(99),
                    // Glow effect halus pada indicator
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.tealOp(0.5),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Tab items ────────────────────────────────────────
          Row(
            children: List.generate(_items.length, (i) {
              final isActive = i == widget.selectedIndex;
              return Expanded(
                child: _NavTab(
                  item: _items[i],
                  isActive: isActive,
                  onTap: () => widget.onTap(i),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Satu tab item dengan animasi icon scale + color ────────────
class _NavTab extends StatefulWidget {
  final _NavItem item;
  final bool     isActive;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scaleAnim;
  late Animation<double>   _colorAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _colorAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );

    if (widget.isActive) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_NavTab old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl.forward();
    } else if (!widget.isActive && old.isActive) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          // Interpolasi warna antara white (tidak aktif) dan teal (aktif)
          final color = Color.lerp(
            AppColors.white,
            AppColors.teal,
            _colorAnim.value,
          )!;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 6),
              // Icon dengan scale animation
              Transform.scale(
                scale: _scaleAnim.value,
                child: Icon(
                  widget.isActive
                      ? widget.item.activeIcon
                      : widget.item.icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                widget.item.label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  fontWeight: widget.isActive
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}