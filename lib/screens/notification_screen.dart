import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  IconData _icon(String name) {
    switch (name) {
      case 'work': return Icons.work_outline_rounded;
      case 'check_circle': return Icons.check_circle_outline_rounded;
      case 'message': return Icons.message_outlined;
      case 'star': return Icons.star_outline_rounded;
      default: return Icons.notifications_outlined;
    }
  }

  Color _bg(String key) {
    switch (key) {
      case 'purple': return const Color(0xFFF0EDFF);
      case 'green': return const Color(0xFFEDFAF4);
      case 'blue': return const Color(0xFFE8F4FF);
      case 'amber': return const Color(0xFFFFF7E0);
      case 'red': return const Color(0xFFFEF0F0);
      default: return AppColors.bgPurpleLight;
    }
  }

  Color _fg(String key) {
    switch (key) {
      case 'purple': return AppColors.primary;
      case 'green': return AppColors.green;
      case 'blue': return AppColors.blue;
      case 'amber': return AppColors.amber;
      case 'red': return AppColors.red;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Đọc tất cả',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: 90),
        itemCount: mockNotifications.length,
        separatorBuilder: (_, __) => const Divider(height: 0, indent: 72),
        itemBuilder: (ctx, i) {
          final n = mockNotifications[i];
          return _NotifTile(
            notif: n,
            bg: _bg(n.bgColor),
            fg: _fg(n.iconColor),
            icon: _icon(n.iconName),
          );
        },
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;
  final Color bg;
  final Color fg;
  final IconData icon;

  const _NotifTile({
    required this.notif,
    required this.bg,
    required this.fg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        color: notif.isUnread ? const Color(0xFFF8F7FF) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: fg, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.body,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.time,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            if (notif.isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}