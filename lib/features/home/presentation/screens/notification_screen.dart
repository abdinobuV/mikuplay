import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notifications = await NotificationService.instance.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
    // Tandai semua sebagai dibaca setelah layar notifikasi dibuka
    await NotificationService.instance.markAllAsRead();
  }

  Future<void> _clearAll() async {
    await NotificationService.instance.clearAll();
    if (mounted) {
      setState(() {
        _notifications = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 150,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.arrow_back, color: AppColors.sky, size: 18),
              const SizedBox(width: 8),
              Text(
                'Back to Home',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.skyOp(0.9),
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.teal,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
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
            bottom: 50,
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
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
                : _notifications.isEmpty
                    ? Center(
                        child: Text(
                          'No new notifications',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.whiteOp(0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notif = _notifications[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildNotificationItem(notif),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notif) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notif.isRead ? AppColors.deepCyanOp(0.12) : AppColors.tealOp(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  notif.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
              if (!notif.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          if (notif.body.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              notif.body,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.whiteOp(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
