import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jobconnect_vn/features/jobs/models/job_model.dart';
import 'package:jobconnect_vn/features/jobs/providers/jobs_provider.dart';
import 'package:jobconnect_vn/features/apply/providers/apply_provider.dart';
import 'package:jobconnect_vn/features/auth/providers/auth_provider.dart';
import 'package:jobconnect_vn/features/chat/screens/chat_list_screen.dart';
import 'package:jobconnect_vn/features/apply/screens/my_applications_screen.dart';
import 'package:jobconnect_vn/models/models.dart' hide JobModel;
import 'package:jobconnect_vn/core/theme/app_theme.dart';
import 'package:jobconnect_vn/core/widgets/shared_widgets.dart';

class JobDetailScreen extends StatefulWidget {
  final int jobId;
  final JobModel? jobPreview;
  const JobDetailScreen({super.key, required this.jobId, this.jobPreview});
  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  JobModel? _job;
  bool _loading = true;
  bool _saved = false;
  final _coverCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _job = widget.jobPreview;
    _loading = widget.jobPreview == null;
    _loadDetail();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user?.role == 'student') {
        context.read<ApplyProvider>().fetchSentApplications();
      }
    });
  }

  Future<void> _loadDetail() async {
    final job = await context.read<JobsProvider>().getJobDetail(widget.jobId);
    if (mounted)
      setState(() {
        _job = job ?? _job;
        _loading = false;
      });
  }

  @override
  void dispose() {
    _coverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _job == null) {
      return const Scaffold(
          backgroundColor: AppColors.bgPage,
          body: Center(
              child: CircularProgressIndicator(color: AppColors.primary)));
    }
    final job = _job!;
    final auth = context.watch<AuthProvider>();
    final apply = context.watch<ApplyProvider>();
    final isStudent = auth.user?.role == 'student';
    final isOwner = auth.user?.id == job.userId;
    final hasApplied = apply.hasApplied(job.id);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Stack(children: [
        CustomScrollView(slivers: [
          _buildSliverHeader(job),
          SliverToBoxAdapter(child: _buildInfoGrid(job)),
          if (isStudent) SliverToBoxAdapter(child: _buildAiAnalysis(job)),
          SliverToBoxAdapter(
              child: _buildSection('Mô tả công việc', job.description)),
          if (job.requirements.isNotEmpty)
            SliverToBoxAdapter(
                child: _buildBulletSection('Yêu cầu', job.requirements)),
          if (job.benefits.isNotEmpty)
            SliverToBoxAdapter(
                child: _buildBulletSection('Quyền lợi', job.benefits)),
          if (job.skills.isNotEmpty)
            SliverToBoxAdapter(child: _buildSkillsSection(job)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(
                job, isStudent, isOwner, hasApplied, apply.isApplying)),
      ]),
    );
  }

  Widget _buildSliverHeader(JobModel job) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.white),
          onPressed: () => _showShareOptions(job),
        ),
        IconButton(
          icon: Icon(
              _saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: Colors.white),
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _saved = !_saved);
            context.read<JobsProvider>().toggleSave(job.id);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryLight])),
          padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14)),
                    alignment: Alignment.center,
                    child: job.companyLogo != null &&
                            job.companyLogo!.startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(job.companyLogo!,
                                fit: BoxFit.cover,
                                width: 52,
                                height: 52,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.business,
                                    color: AppColors.primary)))
                        : const Icon(Icons.business, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(job.title,
                            style: GoogleFonts.sora(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.2)),
                        const SizedBox(height: 4),
                        Text(job.displayCompany,
                            style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8))),
                      ])),
                ]),
              ]),
        ),
      ),
    );
  }

  Widget _buildInfoGrid(JobModel job) {
    final items = [
      [job.salary ?? 'Thỏa thuận', 'Mức lương'],
      [job.location ?? '—', 'Địa điểm'],
      [job.type, 'Loại hình'],
      [job.shift ?? '—', 'Ca làm việc'],
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4),
        itemCount: items.length,
        itemBuilder: (ctx, i) => Container(
          decoration: BoxDecoration(
              color: const Color(0xFFF8F7FF),
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(items[i][0],
                style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(items[i][1],
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.textMuted)),
          ]),
        ),
      ),
    );
  }

  Widget _buildAiAnalysis(JobModel job) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFF7B4F), Color(0xFFFF4F8B)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text('Phân tích AI',
              style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ]),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${job.matchScore}%',
              style: GoogleFonts.sora(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1)),
          const SizedBox(width: 8),
          Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('phù hợp với bạn',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: Colors.white.withOpacity(0.85)))),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
                value: job.matchScore / 100,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6)),
      ]),
    );
  }

  Widget _buildSection(String title, String content) => _sectionCard(
      title,
      Text(content,
          style: GoogleFonts.dmSans(
              fontSize: 13, color: const Color(0xFF4A4768), height: 1.7)));

  Widget _buildBulletSection(String title, List<String> items) => _sectionCard(
      title,
      Column(
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: CircleAvatar(
                                  radius: 3,
                                  backgroundColor: AppColors.primary)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(item,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: const Color(0xFF4A4768),
                                      height: 1.5))),
                        ]),
                  ))
              .toList()));

  Widget _buildSkillsSection(JobModel job) => _sectionCard(
      'Kỹ năng yêu cầu',
      Wrap(
          spacing: 8,
          runSpacing: 8,
          children: job.skills.map((s) => SkillChip(label: s)).toList()));

  Widget _sectionCard(String title, Widget content) => Container(
        margin: const EdgeInsets.only(top: 8),
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          content,
        ]),
      );

  Widget _buildBottomBar(JobModel job, bool isStudent, bool isOwner,
      bool hasApplied, bool isApplying) {
    if (!isStudent && !isOwner) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(children: [
        if (isStudent) ...[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    otherUser: ChatUser(
                      id: job.userId,
                      name: job.displayCompany,
                      avatar: job.companyLogo,
                    ),
                  ),
                ),
              );
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: AppColors.bgPurpleLight,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.chat_bubble_outline,
                  color: AppColors.primary, size: 22),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: isStudent
              ? GradientButton(
                  label: hasApplied
                      ? '✓ Đã ứng tuyển'
                      : (isApplying ? 'Đang gửi...' : 'Ứng tuyển ngay'),
                  onTap: hasApplied || isApplying
                      ? () {}
                      : () => _showApplySheet(job),
                )
              : ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyApplicationsScreen(jobId: job.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text('Quản lý ứng viên',
                      style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
        ),
      ]),
    );
  }

  void _showApplySheet(JobModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            0, 0, 0, MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Ứng tuyển: ${job.title}',
                style: GoogleFonts.sora(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _coverCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Thư giới thiệu (tuỳ chọn)...'),
            ),
            const SizedBox(height: 24),
            GradientButton(
                label: 'Xác nhận',
                onTap: () async {
                  Navigator.pop(context);
                  final applyProvider = context.read<ApplyProvider>();
                  final ok = await applyProvider.applyJob(
                      jobId: job.id, coverLetter: _coverCtrl.text);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok
                        ? 'Ứng tuyển thành công. Theo dõi trạng thái trong hồ sơ.'
                        : (applyProvider.error ?? 'Không thể ứng tuyển')),
                    backgroundColor: ok ? AppColors.green : AppColors.red,
                  ));
                  if (ok) _coverCtrl.clear();
                }),
          ]),
        ),
      ),
    );
  }

  void _showShareOptions(JobModel job) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Gửi cho bạn bè'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatListScreen(shareJob: job)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Sao chép liên kết'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
