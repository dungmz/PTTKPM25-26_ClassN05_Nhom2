import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final skills = ['React', 'JavaScript', 'Figma', 'SQL', 'Content Writing', 'Excel'];
    final menuItems = [
      _MenuItem(Icons.description_outlined, AppColors.bgPurpleLight, AppColors.primary,
          'Quản lý CV', '2 CV đã tải lên'),
      _MenuItem(Icons.work_outline_rounded, AppColors.bgGreenLight, AppColors.green,
          'Việc đã ứng tuyển', '5 đơn đang chờ phản hồi'),
      _MenuItem(Icons.bookmark_outline_rounded, AppColors.bgRedLight, AppColors.red,
          'Việc đã lưu', '8 việc làm'),
      _MenuItem(Icons.bar_chart_rounded, AppColors.bgAmberLight, AppColors.amber,
          'Thống kê hồ sơ', '126 lượt xem tháng này'),
      _MenuItem(Icons.settings_outlined, AppColors.bgPage, AppColors.textSecondary,
          'Cài đặt', 'Bảo mật, ngôn ngữ, giao diện'),
      _MenuItem(Icons.logout_rounded, AppColors.bgRedLight, AppColors.red,
          'Đăng xuất', null),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildStats()),
          SliverToBoxAdapter(child: _buildSkillsSection(skills)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _MenuTile(item: menuItems[i]),
              childCount: menuItems.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        24,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD6C8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                alignment: Alignment.center,
                child: Text(
                  'MT',
                  style: GoogleFonts.sora(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF5C2C),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryLight, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 12, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Nguyễn Minh Tú',
            style: GoogleFonts.sora(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sinh viên CNTT · Đại học Bách Khoa HN',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Hồ sơ 78% hoàn thiện',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = [
      ['5', 'Ứng tuyển'],
      ['8', 'Đã lưu'],
      ['94%', 'Match cao'],
      ['126', 'Lượt xem'],
    ];
    return Container(
      color: Colors.white,
      child: Row(
        children: stats.map((s) {
          final isLast = s == stats.last;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  right: isLast
                      ? BorderSide.none
                      : const BorderSide(color: AppColors.border),
                  bottom: const BorderSide(color: AppColors.border),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    s[0],
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s[1],
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSkillsSection(List<String> skills) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kỹ năng',
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            children: [
              ...skills.map((s) => SkillChip(label: s)),
              Container(
                margin: const EdgeInsets.only(right: 6, bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgPage,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Thêm',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String? sub;

  _MenuItem(this.icon, this.iconBg, this.iconColor, this.label, this.sub);
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;

  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.sub != null)
                    Text(
                      item.sub!,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}