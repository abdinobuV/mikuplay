import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.teal),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            left: -60,
            top: 61,
            child: Container(
              width: 262,
              height: 262,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealOp(0.06),
              ),
            ),
          ),
          Positioned(
            right: -80,
            bottom: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.deepCyanOp(0.08),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      // Search Bar
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.navyOp(0.3),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.deepCyanOp(0.3),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Search help topics...',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.skyOp(0.5),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Help Topics
                      _buildTopicItem(
                        icon: Icons.music_note_rounded,
                        title: 'Music Playback',
                        subtitle: 'Audio issues, buffering, quality',
                      ),
                      const SizedBox(height: 12),
                      _buildTopicItem(
                        icon: Icons.favorite_rounded,
                        title: 'Account & Profile',
                        subtitle: 'Password, data, account privacy',
                      ),
                      const SizedBox(height: 12),
                      _buildTopicItem(
                        icon: Icons.arrow_downward_rounded,
                        title: 'Downloads',
                        subtitle: 'Offline music, storage',
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Contact Us Section
                      const Text(
                        'Contact Us',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildContactItem(
                        icon: Icons.email_rounded,
                        title: 'Email Support',
                        subtitle: 'support@mikuplay.id',
                        subtitleColor: AppColors.teal,
                      ),
                      const SizedBox(height: 12),
                      _buildContactItem(
                        icon: Icons.support_agent_rounded, // or Icons.adjust_rounded / Icons.radio_button_checked
                        title: 'Live Chat',
                        subtitle: 'Response within 2 minutes',
                        subtitleColor: AppColors.teal,
                      ),
                    ],
                  ),
                ),
                
                // Footer
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'MikuPlay v2.4.1 · © 2025 MikuPlay Inc.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.skyOp(0.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.tealOp(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.tealOp(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.teal,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.skyOp(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.skyOp(0.4),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(
            icon,
            color: AppColors.skyOp(0.7),
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
