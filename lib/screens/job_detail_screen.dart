import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverHeader(),
              SliverToBoxAdapter(child: _buildInfoGrid()),
              SliverToBoxAdapter(child: _buildAiAnalysis()),
              SliverToBoxAdapter(child: _buildSection('Mô tả công việc', widget.job.description)),
              SliverToBoxAdapter(child: _buildBulletSection('Yêu cầu', widget.job.requirements)),
              SliverToBoxAdapter(child: _buildBulletSection('Quyền lợi', widget.job.benefits)),
              SliverToBoxAdapter(child: _buildSkillsSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.job.logo,
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.job.title,
                          style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.job.company,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    final items = [
      [widget.job.salary, 'Mức lương'],
      [widget.job.location, 'Địa điểm'],
      [widget.job.type, 'Loại hình'],
      [widget.job.shift, 'Ca làm việc'],
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
          childAspectRatio: 2.4,
        ),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FF),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  items[i][0],
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  items[i][1],
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAiAnalysis() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7B4F), Color(0xFFFF4F8B)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Phân tích AI',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${widget.job.matchScore}%',
                style: GoogleFonts.sora(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'phù hợp với hồ sơ của bạn',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: widget.job.matchScore / 100,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Kỹ năng phù hợp: ${widget.job.skills.join(", ")}',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return _sectionCard(
      title,
      Text(
        content,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          color: const Color(0xFF4A4768),
          height: 1.7,
        ),
      ),
    );
  }

  Widget _buildBulletSection(String title, List<String> items) {
    return _sectionCard(
      title,
      Column(
        children: items
            .map(
              (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: CircleAvatar(
                    radius: 3,
                    backgroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: const Color(0xFF4A4768),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return _sectionCard(
      'Kỹ năng yêu cầu',
      Wrap(
        children: widget.job.skills
            .map((s) => SkillChip(label: s))
            .toList(),
      ),
    );
  }

  Widget _sectionCard(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.sora(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _saved = !_saved);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _saved ? AppColors.bgPurpleLight : AppColors.bgPurpleLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GradientButton(
              label: 'Ứng tuyển ngay',
              onTap: () {
                HapticFeedback.mediumImpact();
                _showApplySheet(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showApplySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ứng tuyển ngay',
              style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.job.title,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _applyOption(Icons.description_outlined, 'CV của bạn', 'MinhTu_CV_2024.pdf · Đã tải lên'),
            const SizedBox(height: 12),
            _applyOption(Icons.edit_outlined, 'Thư giới thiệu', 'Nhấn để soạn thư (tuỳ chọn)'),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Xác nhận ứng tuyển',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Ứng tuyển thành công! 🎉',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
                    ),
                    backgroundColor: AppColors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  Widget _applyOption(IconData icon, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                sub,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColors.textHint),
        ],
      ),
    );
  }
}