import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../jobs/providers/jobs_provider.dart';
import '../../jobs/models/job_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../jobs/screens/job_detail_screen.dart';
import '../../jobs/screens/jobs_screen.dart';
import '../../chat/screens/ai_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeChip = 0;
  final List<String> _chips = [
    'Tất cả',
    'Marketing',
    'IT',
    'Kế toán',
    'Thiết kế',
    'Data'
  ];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final jobs = context.read<JobsProvider>();

      jobs.fetchJobs(refresh: true);

      // Only fetch recommended for students
      if (auth.user?.role == 'student') {
        jobs.fetchRecommended();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmployer = context.read<AuthProvider>().user?.role == 'employer';

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: isEmployer
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIChatScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await context.read<JobsProvider>().fetchJobs(refresh: true);
          if (!isEmployer) {
            await context.read<JobsProvider>().fetchRecommended();
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildChipRow()),
            if (!isEmployer) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Đề xuất AI ✨',
                  action: 'Xem thêm →',
                  onAction: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const JobsScreen())),
                ),
              ),
              SliverToBoxAdapter(child: _buildAiSection()),
            ],
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Việc làm phổ biến',
                action: 'Tất cả →',
                onAction: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const JobsScreen())),
              ),
            ),
            Consumer<JobsProvider>(
              builder: (ctx, jobs, _) {
                if (jobs.isLoading && jobs.jobs.isEmpty) {
                  return const SliverToBoxAdapter(child: _JobListSkeleton());
                }
                if (jobs.error != null && jobs.jobs.isEmpty) {
                  return SliverToBoxAdapter(
                      child: _ErrorRetry(
                          message: jobs.error!,
                          onRetry: () => jobs.fetchJobs(refresh: true)));
                }
                final filtered = _filtered(jobs.jobs);
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        if (i == filtered.length - 2 && jobs.hasMore) {
                          jobs.fetchJobs();
                        }
                        return JobCard(
                            job: filtered[i],
                            onTap: () => _openDetail(filtered[i]));
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<JobModel> _filtered(List<JobModel> all) {
    if (_activeChip == 0) return all;
    final kw = _chips[_activeChip].toLowerCase();

    return all.where((j) {
      final categoryMatch =
          j.category != null && j.category!.toLowerCase() == kw;
      final skillMatch = j.skills.any((s) => s.toLowerCase().contains(kw));
      final titleMatch = j.title.toLowerCase().contains(kw);

      return categoryMatch || skillMatch || titleMatch;
    }).toList();
  }

  void _openDetail(JobModel job) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => JobDetailScreen(jobId: job.id, jobPreview: job)));
  }

  void _chatWithAI(JobModel job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AIChatScreen(
          initialContext: {
            'jobTitle': job.title,
            'companyName': job.companyName ?? job.employerName,
            'matchedSkills': job.matchedSkills,
            'missingSkills': job.missingSkills,
            'recommendationReason': job.recommendationReason,
            'job': {
              'title': job.title,
              'company': job.companyName ?? 'N/A',
              'salary': job.salary ?? 'N/A',
              'location': job.location ?? 'N/A',
              'description': job.description,
              'skills': job.skills,
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(builder: (ctx, auth, _) {
      final user = auth.user;
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        padding: EdgeInsets.fromLTRB(
            20, MediaQuery.of(context).padding.top + 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Xin chào, ${user?.name.split(' ').last ?? 'bạn'} 👋',
                          style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(
                          user?.location != null
                              ? '${user!.location} · Việc làm mới hôm nay'
                              : 'Tìm việc thông minh cùng AI',
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7))),
                    ],
                  ),
                ),
                Stack(children: [
                  AvatarCircle(
                      initials: user?.initials ?? '?',
                      size: 40,
                      bg: const Color(0xFFFFD6C8),
                      fg: const Color(0xFFFF5C2C),
                      fontSize: 15),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: AppColors.online,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primaryLight, width: 2),
                        ),
                      )),
                ]),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const JobsScreen())),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.search,
                      color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 8),
                  Text('Tìm kiếm việc làm...',
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: AppColors.textMuted)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.bgPurpleLight,
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(children: [
                      const Icon(Icons.tune_rounded,
                          size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Lọc',
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ]),
                  ),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChipRow() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        itemCount: _chips.length,
        itemBuilder: (ctx, i) {
          final active = _activeChip == i;
          return GestureDetector(
            onTap: () => setState(() => _activeChip = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                    width: 1.5),
              ),
              child: Text(_chips[i],
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: active ? Colors.white : AppColors.textSecondary)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAiSection() {
    return Consumer<JobsProvider>(builder: (ctx, jobs, _) {
      if (jobs.recommendedJobs.isEmpty) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFF7B4F), Color(0xFFFF4F8B)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2)),
        );
      }
      final recommended = jobs.recommendedJobs.take(5).toList();
      return SizedBox(
        height: 238,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: recommended.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final job = recommended[index];
            return _AiJobSuggestionCard(
              job: job,
              onTap: () => _openDetail(job),
              onChat: () => _chatWithAI(job),
            );
          },
        ),
      );
      final top = jobs.recommendedJobs.first;
      return GestureDetector(
        onLongPress: () => _chatWithAI(top),
        onTap: () => _openDetail(top),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFF7B4F), Color(0xFFFF4F8B)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text('Phù hợp nhất với bạn (Nhấn giữ để chat với AI ✨)',
                    style: GoogleFonts.dmSans(
                        fontSize: 11, color: Colors.white.withOpacity(0.85))),
              ]),
              const SizedBox(height: 6),
              Text('${top.matchScore}%',
                  style: GoogleFonts.sora(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1)),
              Text('Độ phù hợp hồ sơ',
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                    value: top.matchScore / 100,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 5),
              ),
              const SizedBox(height: 10),
              Text('${top.title} · ${top.displayCompany}',
                  style: GoogleFonts.sora(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 8),
              Wrap(
                  spacing: 6,
                  children: top.skills
                      .take(3)
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(s,
                                style: GoogleFonts.dmSans(
                                    fontSize: 11, color: Colors.white)),
                          ))
                      .toList()),
            ],
          ),
        ),
      );
    });
  }
}

class _AiJobSuggestionCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;
  final VoidCallback onChat;

  const _AiJobSuggestionCard({
    required this.job,
    required this.onTap,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final matched =
        job.matchedSkills.isNotEmpty ? job.matchedSkills : job.skills;
    final reason = job.recommendationReason ??
        'AI de xuat dua tren ky nang va ho so cua ban.';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 292,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFFF7B4F), Color(0xFFFF4F8B)]),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  job.companyFit ?? 'AI de xuat cho ban',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.88),
                      fontWeight: FontWeight.w600),
                ),
              ),
              Text('${job.matchScore}%',
                  style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: job.matchScore.clamp(0, 100) / 100,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              job.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.22),
            ),
            const SizedBox(height: 4),
            Text(
              job.displayCompany,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: Colors.white.withOpacity(0.82)),
            ),
            const SizedBox(height: 8),
            Text(
              reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                  fontSize: 11,
                  height: 1.25,
                  color: Colors.white.withOpacity(0.9)),
            ),
            const Spacer(),
            if (matched.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: matched
                    .take(3)
                    .map((skill) => _AiTag(label: skill))
                    .toList(),
              ),
            if (job.missingSkills.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Nen bo sung: ${job.missingSkills.take(2).join(', ')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                    fontSize: 10, color: Colors.white.withOpacity(0.78)),
              ),
            ],
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: _AiActionButton(
                      label: 'Xem viec',
                      icon: Icons.work_outline_rounded,
                      onTap: onTap)),
              const SizedBox(width: 8),
              Expanded(
                  child: _AiActionButton(
                      label: 'Hoi AI',
                      icon: Icons.chat_bubble_outline_rounded,
                      onTap: onChat)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _AiTag extends StatelessWidget {
  final String label;

  const _AiTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white)),
    );
  }
}

class _AiActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _AiActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 5),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _JobListSkeleton extends StatelessWidget {
  const _JobListSkeleton();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
          children: List.generate(
              4,
              (_) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 100,
                    decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16)),
                  ))),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(children: [
        const Icon(Icons.wifi_off_rounded,
            size: 48, color: AppColors.textMuted),
        const SizedBox(height: 12),
        Text(message,
            style: GoogleFonts.dmSans(
                fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        TextButton(
            onPressed: onRetry,
            child: Text('Thử lại',
                style: GoogleFonts.dmSans(
                    color: AppColors.primary, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}
