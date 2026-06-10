import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            left: -60, top: 61,
            child: Container(
              width: 262, height: 262,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.teal.withOpacity(0.06)),
            ),
          ),
          Positioned(
            left: 262, top: 404,
            child: Container(
              width: 202, height: 202,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.teal.withOpacity(0.04)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      _buildSectionHeader('Audio'),
                      _buildSettingsItem('Streaming Quality', onTap: () {}),
                      _buildSettingsItem('Equalizer', onTap: () => context.push(Routes.equalizer)),
                      _buildSettingsItem('Song Crossfade', onTap: () {}),
                      _buildSettingsItem('Volume Normalization', onTap: () {}),
                      const SizedBox(height: 24),
                      
                      _buildSectionHeader('Display'),
                      _buildSettingsItem('Theme', onTap: () {}),
                      _buildSettingsItem('Lyrics Size', onTap: () {}),
                      _buildSettingsItem('Animations', onTap: () {}),
                      const SizedBox(height: 24),

                      _buildSectionHeader('Account'),
                      _buildSettingsItem('Edit Profile', onTap: () {}),
                      _buildSettingsItem('Notifications', onTap: () {}),
                      _buildSettingsItem('Privacy', onTap: () {}),
                      _buildSettingsItem('Delete', onTap: () {}),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.deepCyan.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.sky, size: 20),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.teal,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 57,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.deepCyan.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.sky.withOpacity(0.7)),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
