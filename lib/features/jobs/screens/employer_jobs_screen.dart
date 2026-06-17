import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../apply/screens/my_applications_screen.dart';
import '../models/job_model.dart';
import '../providers/jobs_provider.dart';
import 'create_job_screen.dart';

class EmployerJobsScreen extends StatefulWidget {
  const EmployerJobsScreen({super.key});

  @override
  State<EmployerJobsScreen> createState() => _EmployerJobsScreenState();
}

class _EmployerJobsScreenState extends State<EmployerJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsProvider>().fetchMyJobs();
    });
  }

  Future<void> _openCreate() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateJobScreen()),
    );
    if (changed == true && mounted) {
      context.read<JobsProvider>().fetchMyJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text(
          'Công việc đã đăng',
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.bgCard,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: _openCreate,
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primary),
          ),
        ],
      ),
      body: Consumer<JobsProvider>(
        builder: (ctx, jobs, _) {
          if (jobs.isLoading && jobs.myJobs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final error = jobs.error;
          if (error != null && jobs.myJobs.isEmpty) {
            return _ErrorState(
              message: error,
              onRetry: () => jobs.fetchMyJobs(),
            );
          }

          if (jobs.myJobs.isEmpty) {
            return _EmptyState(onCreate: _openCreate);
          }

          return RefreshIndicator(
            onRefresh: () => jobs.fetchMyJobs(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: jobs.myJobs.length,
              itemBuilder: (ctx, i) => _EmployerJobCard(job: jobs.myJobs[i]),
            ),
          );
        },
      ),
    );
  }
}

class _EmployerJobCard extends StatelessWidget {
  final JobModel job;
  const _EmployerJobCard({required this.job});

  Future<void> _openEdit(BuildContext context) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreateJobScreen(job: job)),
    );
    if (changed == true && context.mounted) {
      context.read<JobsProvider>().fetchMyJobs();
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Xoá tin tuyển dụng',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Bạn chắc chắn muốn xoá "${job.title}"? Các đơn ứng tuyển liên quan cũng sẽ bị xoá.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Huỷ',
                style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xoá',
                style: GoogleFonts.dmSans(
                    color: AppColors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final provider = context.read<JobsProvider>();
    final ok = await provider.deleteJob(job.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Đã xoá tin tuyển dụng'
            : provider.error ?? 'Không thể xoá tin'),
        backgroundColor: ok ? AppColors.green : AppColors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                      job.title,
                      style: GoogleFonts.sora(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job.type} · ${job.location ?? "Remote"}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(isActive: job.isActive),
              PopupMenuButton<String>(
                onSelected: (value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    switch (value) {
                      case 'edit':
                        _openEdit(context);
                        break;
                      case 'delete':
                        _confirmDelete(context);
                        break;
                    }
                  });
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Sửa tin'),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          size: 18, color: AppColors.red),
                      SizedBox(width: 8),
                      Text('Xoá tin'),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          if (job.skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: job.skills
                  .take(4)
                  .map((skill) => SkillChip(label: skill))
                  .toList(),
            ),
          ],
          const Divider(height: 24),
          Row(
            children: [
              _Metric(label: 'Lượt xem', value: '${job.views}'),
              const SizedBox(width: 20),
              _Metric(
                label: 'Ứng viên',
                value: '${job.applicantCount}',
                valueColor: AppColors.primary,
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => _openEdit(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Sửa',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
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
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Ứng viên',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Metric({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted)),
        Text(value,
            style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.bgGreenLight : AppColors.bgRedLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Đang tuyển' : 'Đã đóng',
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isActive ? AppColors.green : AppColors.red,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.work_history_outlined,
              size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text('Bạn chưa đăng công việc nào',
              style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Đăng tin ngay',
                style: GoogleFonts.dmSans(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 64, color: AppColors.red),
            const SizedBox(height: 16),
            Text('Lỗi tải dữ liệu',
                style: GoogleFonts.sora(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
