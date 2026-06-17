import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../apply/providers/apply_provider.dart';
import '../../auth/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import 'edit_profile_screen.dart';
import 'cv_management_screen.dart';
import '../../apply/screens/my_applications_screen.dart';
import '../../jobs/screens/employer_jobs_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        if (user.isEmployer) {
          context.read<ApplyProvider>().fetchReceivedApplications();
        } else {
          context.read<ApplyProvider>().fetchSentApplications();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final apply = context.watch<ApplyProvider>();
    final menuItems = _buildMenuItems(user, apply);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, user)),
          SliverToBoxAdapter(child: _buildStats(user, apply)),
          if (user.isStudent && user.skills.isNotEmpty)
            SliverToBoxAdapter(child: _buildSkillsSection(user.skills)),
          if (user.isStudent && (user.university != null || user.major != null))
            SliverToBoxAdapter(child: _buildEducationSection(user)),
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

  List<_MenuItem> _buildMenuItems(UserModel user, ApplyProvider apply) {
    return [
      _MenuItem(Icons.edit_outlined, AppColors.bgPurpleLight, AppColors.primary,
          'Chỉnh sửa hồ sơ', 'Cập nhật thông tin cá nhân',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
      if (user.isStudent) ...[
        _MenuItem(
            Icons.description_outlined,
            AppColors.bgGreenLight,
            AppColors.green,
            'Quản lý CV',
            user.cvUrl != null ? 'CV đã tải lên' : 'Chưa có CV',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CvManagementScreen()))),
        _MenuItem(
            Icons.work_outline_rounded,
            AppColors.bgBlueLight,
            AppColors.blue,
            'Việc đã ứng tuyển',
            '${apply.sentApplications.length} đơn',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MyApplicationsScreen()))),
      ] else ...[
        _MenuItem(
            Icons.assignment_outlined,
            AppColors.bgGreenLight,
            AppColors.green,
            'Quản lý tin đăng',
            'Theo dõi các công việc đã đăng',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EmployerJobsScreen()))),
        _MenuItem(
            Icons.people_outline,
            AppColors.bgBlueLight,
            AppColors.blue,
            'Ứng viên đã ứng tuyển',
            '${apply.receivedApplications.length} ứng viên',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MyApplicationsScreen()))),
      ],
      _MenuItem(Icons.bookmark_outline_rounded, AppColors.bgAmberLight,
          AppColors.amber, 'Việc đã lưu', 'Danh sách bookmark',
          onTap: () {}),
      _MenuItem(Icons.lock_outline_rounded, AppColors.bgPage,
          AppColors.textSecondary, 'Đổi mật khẩu', 'Bảo mật tài khoản',
          onTap: () => _showChangePasswordSheet()),
      _MenuItem(Icons.logout_rounded, AppColors.bgRedLight, AppColors.red,
          'Đăng xuất', null,
          onTap: () => _confirmLogout()),
    ];
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    final completionScore = _calcCompletion(user);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight]),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 24),
      child: Column(children: [
        Stack(children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD6C8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: user.avatarUrl != null
                ? ClipOval(
                    child: Image.network(user.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarFallback(user)))
                : _avatarFallback(user),
          ),
          Positioned(
              bottom: 2,
              right: 2,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.primaryLight, width: 2)),
                  child: const Icon(Icons.edit,
                      size: 12, color: AppColors.primary),
                ),
              )),
        ]),
        const SizedBox(height: 10),
        Text(user.name,
            style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        const SizedBox(height: 4),
        Text(
            user.isStudent
                ? '${user.major ?? "Sinh viên"} · ${user.university ?? ""}'
                : user.companyName ?? 'Nhà tuyển dụng',
            style: GoogleFonts.dmSans(
                fontSize: 12, color: Colors.white.withOpacity(0.7))),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
            const SizedBox(width: 6),
            Text('Hồ sơ $completionScore% hoàn thiện',
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      ]),
    );
  }

  Widget _avatarFallback(UserModel user) => Center(
      child: Text(user.initials,
          style: GoogleFonts.sora(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFF5C2C))));

  Widget _buildStats(UserModel user, ApplyProvider apply) {
    final stats = user.isStudent
        ? [
            ['${apply.sentApplications.length}', 'Ứng tuyển'],
            [
              '${apply.sentApplications.where((a) => a.status == 'accepted').length}',
              'Được nhận'
            ],
            ['${user.skills.length}', 'Kỹ năng'],
            [user.location != null ? '📍' : '—', 'Địa điểm'],
          ]
        : [
            ['${apply.receivedApplications.length}', 'Ứng viên'],
            [user.companyField ?? '—', 'Lĩnh vực'],
          ];
    return Container(
      color: AppColors.bgCard,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: stats
            .map((s) => Expanded(
                    child: Column(children: [
                  Text(s[0],
                      style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(s[1],
                      style: GoogleFonts.dmSans(
                          fontSize: 11, color: AppColors.textMuted)),
                ])))
            .toList(),
      ),
    );
  }

  Widget _buildSkillsSection(List<String> skills) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.bgCard,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Kỹ năng',
            style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) => SkillChip(label: s)).toList()),
      ]),
    );
  }

  Widget _buildEducationSection(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: AppColors.bgCard,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Học vấn',
            style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.bgPurpleLight,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.school_outlined,
                  color: AppColors.primary, size: 20)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(user.university ?? '—',
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                if (user.major != null)
                  Text(user.major!,
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: AppColors.textSecondary)),
              ])),
        ]),
      ]),
    );
  }

  int _calcCompletion(UserModel user) {
    int score = 0;
    if (user.name.isNotEmpty) score += 15;
    if (user.bio != null) score += 10;
    if (user.phone != null) score += 5;
    if (user.location != null) score += 10;
    if (user.avatarUrl != null) score += 10;
    if (user.skills.isNotEmpty) score += 20;
    if (user.cvUrl != null) score += 20;
    if (user.university != null) score += 5;
    if (user.experience != null) score += 5;
    return score;
  }

  void _showChangePasswordSheet() {
    final currCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            0, 0, 0, MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Đổi mật khẩu',
                    style: GoogleFonts.sora(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                TextField(
                    controller: currCtrl,
                    obscureText: true,
                    style: GoogleFonts.dmSans(
                        fontSize: 14, color: AppColors.textPrimary),
                    decoration:
                        const InputDecoration(hintText: 'Mật khẩu hiện tại')),
                const SizedBox(height: 12),
                TextField(
                    controller: newCtrl,
                    obscureText: true,
                    style: GoogleFonts.dmSans(
                        fontSize: 14, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                        hintText: 'Mật khẩu mới (tối thiểu 6 ký tự)')),
                const SizedBox(height: 20),
                GradientButton(
                    label: 'Đổi mật khẩu',
                    onTap: () async {
                      Navigator.pop(context);
                      final ok = await context
                          .read<AuthProvider>()
                          .changePassword(
                              current: currCtrl.text, newPass: newCtrl.text);
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok
                              ? 'Đổi mật khẩu thành công'
                              : (context.read<AuthProvider>().errorMessage ??
                                  'Lỗi')),
                          backgroundColor: ok ? AppColors.green : AppColors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ));
                    }),
              ]),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Đăng xuất',
                  style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
              content: Text('Bạn chắc chắn muốn đăng xuất?',
                  style: GoogleFonts.dmSans()),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Huỷ',
                        style: GoogleFonts.dmSans(
                            color: AppColors.textSecondary))),
                TextButton(
                    onPressed: () async {
                      final auth = context.read<AuthProvider>();
                      Navigator.pop(context);
                      await auth.logout();
                    },
                    child: Text('Đăng xuất',
                        style: GoogleFonts.dmSans(
                            color: AppColors.red,
                            fontWeight: FontWeight.w600))),
              ],
            ));
  }
}

class _MenuItem {
  final IconData icon;
  final Color bg, color;
  final String title;
  final String? sub;
  final VoidCallback? onTap;
  _MenuItem(this.icon, this.bg, this.color, this.title, this.sub, {this.onTap});
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
        color: AppColors.bgCard,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: item.bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(item.icon, color: item.color, size: 19)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(item.title,
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                if (item.sub != null)
                  Text(item.sub!,
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: AppColors.textMuted)),
              ])),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint, size: 20),
        ]),
      ),
    );
  }
}
