import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../widgets/shared_widgets.dart';
import 'job_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeChip = 0;
  final List<String> _chips = ['Tất cả', 'Marketing', 'IT', 'Kế toán', 'Thiết kế', 'Data'];

  List<JobModel> get _filteredJobs {
    if (_activeChip == 0) return mockJobs;
    final keyword = _chips[_activeChip].toLowerCase();
    return mockJobs
        .where((j) =>
    j.skills.any((s) => s.toLowerCase().contains(keyword)) ||
        j.title.toLowerCase().contains(keyword))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildChipRow()),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Đề xuất AI ✨',
              action: 'Xem thêm →',
              onAction: () {},
            ),
          ),
          SliverToBoxAdapter(child: _buildAiCard()),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Việc làm phổ biến',
              action: 'Tất cả →',
              onAction: () {},
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (ctx, i) => JobCard(
                  job: _filteredJobs[i],
                  onTap: () => _openDetail(_filteredJobs[i]),
                ),
                childCount: _filteredJobs.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(JobModel job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
    );
  }

  Widget _buildHeader() {
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
        MediaQuery.of(context).padding.top + 16,
        20,
        24,
      ),
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
                      'Xin chào, Minh Tú 👋',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hà Nội · 12 việc mới hôm nay',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  const AvatarCircle(
                    initials: 'MT',
                    size: 40,
                    bg: Color(0xFFFFD6C8),
                    fg: Color(0xFFFF5C2C),
                    fontSize: 15,
                  ),
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
                          color: AppColors.primaryLight,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Tìm kiếm việc làm...',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                  width: 1.5,
                ),
              ),
              child: Text(
                _chips[i],
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAiCard() {
    final topJob = mockJobs.first;
    return GestureDetector(
      onTap: () => _openDetail(topJob),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7B4F), Color(0xFFFF4F8B)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Phù hợp nhất với bạn',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${topJob.matchScore}%',
              style: GoogleFonts.sora(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1,
              ),
            ),
            Text(
              'Độ phù hợp hồ sơ',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${topJob.title} · ${topJob.company}',
              style: GoogleFonts.sora(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: topJob.skills
                  .map(
                    (s) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}