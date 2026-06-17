import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../widgets/shared_widgets.dart';
import 'job_detail_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = mockJobs
        .where((j) =>
    _query.isEmpty ||
        j.title.toLowerCase().contains(_query.toLowerCase()) ||
        j.company.toLowerCase().contains(_query.toLowerCase()) ||
        j.skills.any((s) => s.toLowerCase().contains(_query.toLowerCase())))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Tìm việc làm'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Tên việc, kỹ năng, công ty...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Không tìm thấy kết quả',
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Thử từ khoá khác hoặc xoá bộ lọc',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => JobCard(
          job: filtered[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobDetailScreen(job: filtered[i]),
            ),
          ),
        ),
      ),
    );
  }
}