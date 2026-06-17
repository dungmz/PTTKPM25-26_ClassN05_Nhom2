import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  Color _bgColor(String key) {
    switch (key) {
      case 'red': return const Color(0xFFFECED0);
      case 'blue': return const Color(0xFFE8F4FF);
      case 'orange': return const Color(0xFFFFF0E8);
      case 'purple': return const Color(0xFFF0EDFF);
      default: return AppColors.bgPurpleLight;
    }
  }

  Color _fgColor(String key) {
    switch (key) {
      case 'red': return const Color(0xFFFF4C5B);
      case 'blue': return AppColors.blue;
      case 'orange': return const Color(0xFFFF5C2C);
      case 'purple': return AppColors.primary;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.primary,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textMuted, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Tìm kiếm cuộc trò chuyện...',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: mockChats.length,
              separatorBuilder: (_, __) => const Divider(height: 0, indent: 74),
              itemBuilder: (ctx, i) {
                final c = mockChats[i];
                return _ChatTile(
                  chat: c,
                  bg: _bgColor(c.bgColor),
                  fg: _fgColor(c.textColor),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final Color bg;
  final Color fg;

  const _ChatTile({required this.chat, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                chat.initials,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chat.lastMessage,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
                if (chat.unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}