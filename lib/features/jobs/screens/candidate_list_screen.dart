import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../../../models/chat_model.dart';
import 'student_detail_screen.dart';
import '../../auth/models/user_model.dart';

class CandidateListScreen extends StatefulWidget {
  const CandidateListScreen({super.key});

  @override
  State<CandidateListScreen> createState() => _CandidateListScreenState();
}

class _CandidateListScreenState extends State<CandidateListScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchCandidates();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<AuthProvider>().fetchCandidates(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Tìm kiếm ứng viên', 
          style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        backgroundColor: AppColors.bgCard,
        elevation: 0.5,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, kỹ năng, trường...',
                hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.bgPage,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isFetchingCandidates && auth.candidates.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (auth.candidates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('Không tìm thấy ứng viên phù hợp', 
                    style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
                  if (_searchCtrl.text.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _searchCtrl.clear();
                        auth.fetchCandidates();
                      },
                      child: const Text('Xóa tìm kiếm'),
                    )
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => auth.fetchCandidates(query: _searchCtrl.text),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: auth.candidates.length,
              itemBuilder: (context, index) {
                final student = auth.candidates[index];
                return _CandidateCard(student: student);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final UserModel student;
  const _CandidateCard({required this.student});

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
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarCircle(
                initials: student.initials,
                size: 50,
                bg: AppColors.bgPurpleLight,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      student.major ?? 'Chưa cập nhật chuyên ngành',
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => StudentDetailScreen(student: student)),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (student.skills.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: student.skills.take(3).map<Widget>((s) => SkillChip(label: s)).toList(),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.school_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  student.university ?? 'Chưa cập nhật trường học',
                  style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                student.location ?? 'Chưa cập nhật địa chỉ',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          otherUser: ChatUser(
                            id: student.id,
                            name: student.name,
                            avatar: student.avatarUrl,
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: Text('Nhắn tin trao đổi', 
                    style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border, color: AppColors.textSecondary, size: 20),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class SkillChip extends StatelessWidget {
  final String label;
  const SkillChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgPurpleLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
