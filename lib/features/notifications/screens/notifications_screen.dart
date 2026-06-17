import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notifications_provider.dart';
import '../models/notification_model.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Thông báo', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        backgroundColor: AppColors.bgCard, elevation: 0, automaticallyImplyLeading: false,
        actions: [
          Consumer<NotificationsProvider>(builder: (ctx, notif, _) {
            if (notif.unreadCount == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: notif.markAllRead,
              child: Text('Đọc tất cả', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)));
          }),
        ],
      ),
      body: Consumer<NotificationsProvider>(builder: (ctx, notif, _) {
        if (notif.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        if (notif.notifications.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.notifications_none_outlined, size: 60, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('Chưa có thông báo nào', style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary)),
          ]));
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: notif.fetchNotifications,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
            itemCount: notif.notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
            itemBuilder: (ctx, i) {
              final n = notif.notifications[i];
              return _NotifTile(
                notif: n,
                onTap: () { if (!n.isRead) notif.markRead(n.id); },
              );
            },
          ),
        );
      }),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;
  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cfg = _iconConfig(notif.type);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: notif.isRead ? AppColors.bgCard : AppColors.bgPurpleLight.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: cfg['bg'] as Color, shape: BoxShape.circle),
            child: Icon(cfg['icon'] as IconData, color: cfg['fg'] as Color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(notif.title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: notif.isRead ? FontWeight.w400 : FontWeight.w700, color: AppColors.textPrimary)),
            if (notif.body != null) ...[
              const SizedBox(height: 2),
              Text(notif.body!, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 4),
            Text(_relTime(notif.createdAt), style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
          ])),
          if (!notif.isRead) Container(
            width: 8, height: 8, margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
        ]),
      ),
    );
  }

  Map<String, dynamic> _iconConfig(String type) {
    switch (type) {
      case 'new_application':
        return {'icon': Icons.person_add_outlined, 'bg': const Color(0xFFE8F4FF), 'fg': const Color(0xFF2563EB)};
      case 'application_update':
        return {'icon': Icons.work_outline_rounded, 'bg': AppColors.bgGreenLight, 'fg': AppColors.green};
      case 'message':
        return {'icon': Icons.chat_bubble_outline_rounded, 'bg': AppColors.bgPurpleLight, 'fg': AppColors.primary};
      default:
        return {'icon': Icons.notifications_outlined, 'bg': AppColors.bgAmberLight, 'fg': AppColors.amber};
    }
  }

  String _relTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    return '${diff.inMinutes} phút trước';
  }
}
