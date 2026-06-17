import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/jobs_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import 'job_detail_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});
  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _searchCtrl  = TextEditingController();
  final _scrollCtrl  = ScrollController();

  String? _filterType;
  String? _filterLocation;

  final _types = ['Full-time', 'Part-time', 'Internship', 'Remote'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsProvider>().fetchJobs(refresh: true);
    });
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<JobsProvider>().fetchJobs();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Việc làm', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Container(
            color: AppColors.bgCard,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(children: [
              // Search bar
              TextField(
                controller: _searchCtrl,
                style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Tìm tên việc, kỹ năng, công ty...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                          onPressed: () { _searchCtrl.clear(); _applySearch(''); })
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onChanged: _applySearch,
              ),
              const SizedBox(height: 8),
              // Type filters
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip('Tất cả', null),
                    ..._types.map((t) => _filterChip(t, t)),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
      body: Consumer<JobsProvider>(builder: (ctx, jobs, _) {
        if (jobs.isLoading && jobs.jobs.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (jobs.error != null && jobs.jobs.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(jobs.error!, style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextButton(onPressed: () => jobs.fetchJobs(refresh: true),
              child: Text('Thử lại', style: GoogleFonts.dmSans(color: AppColors.primary, fontWeight: FontWeight.w600))),
          ]));
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(children: [
                Text('${jobs.total} kết quả', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
                const Spacer(),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Row(children: [
                    const Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Bộ lọc', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ]),
                ),
              ]),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => jobs.fetchJobs(refresh: true),
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: jobs.jobs.length + (jobs.isLoadingMore ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i == jobs.jobs.length) {
                      return const Padding(padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)));
                    }
                    final job = jobs.jobs[i];
                    return JobCard(job: job, onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: job.id, jobPreview: job))));
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _applySearch(String q) {
    context.read<JobsProvider>().setSearch(q);
  }

  void _showFilterSheet() {
    String? tmpType     = _filterType;
    String? tmpLocation = _filterLocation;
    final locationCtrl  = TextEditingController(text: _filterLocation);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModal) {
        return Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 20),
              Text('Bộ lọc', style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              Text('Loại hình', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _sheetChip('Tất cả', null, tmpType, (v) => setModal(() => tmpType = v)),
                ..._types.map((t) => _sheetChip(t, t, tmpType, (v) => setModal(() => tmpType = v))),
              ]),
              const SizedBox(height: 16),
              Text('Địa điểm', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: locationCtrl,
                style: GoogleFonts.dmSans(fontSize: 14),
                decoration: const InputDecoration(hintText: 'Hà Nội, TP.HCM...'),
                onChanged: (v) => tmpLocation = v.isEmpty ? null : v,
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() { _filterType = null; _filterLocation = null; });
                    context.read<JobsProvider>().clearFilters();
                  },
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13)),
                  child: Text('Xoá lọc', style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                )),
                const SizedBox(width: 12),
                Expanded(child: GradientButton(label: 'Áp dụng', onTap: () {
                  Navigator.pop(ctx);
                  setState(() { _filterType = tmpType; _filterLocation = tmpLocation; });
                  context.read<JobsProvider>().setFilters(type: tmpType, location: tmpLocation);
                })),
              ]),
            ],
          ),
        );
      }),
    );
  }

  Widget _filterChip(String label, String? value) {
    final active = _filterType == value;
    return GestureDetector(
      onTap: () { setState(() => _filterType = value); context.read<JobsProvider>().setFilters(type: value, location: _filterLocation); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.bgCard,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5),
        ),
        child: Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500,
          color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }

  Widget _sheetChip(String label, String? value, String? current, void Function(String?) onTap) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.bgPurpleLight : AppColors.bgPage,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5),
        ),
        child: Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500,
          color: active ? AppColors.primary : AppColors.textSecondary)),
      ),
    );
  }
}
