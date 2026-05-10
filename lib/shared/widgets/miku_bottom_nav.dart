import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// Index tab
class NavTab {
  static const int home    = 0;
  static const int search  = 1;
  static const int library = 2;
  static const int profile = 3;
}

class MikuBottomNav extends StatelessWidget {
  final int    selectedIndex;
  final ValueChanged<int> onTap;

  const MikuBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const _items = [
    _BNItem(icon: Icons.home_filled,          label: 'Home'),
    _BNItem(icon: Icons.search_rounded,       label: 'Search'),
    _BNItem(icon: Icons.library_music_rounded,label: 'Library'),
    _BNItem(icon: Icons.person_rounded,       label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 77,
      // Figma: bg=#050933, border-top: deepCyan 20%
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.deepCyanOp(0.2), width: 1),
        ),
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final isActive = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _items[i].icon,
                    size: 24,
                    // Figma: teal jika aktif, white jika tidak
                    color: isActive ? AppColors.teal : AppColors.white,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _items[i].label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: isActive ? AppColors.teal : AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BNItem {
  final IconData icon;
  final String   label;
  const _BNItem({required this.icon, required this.label});
}