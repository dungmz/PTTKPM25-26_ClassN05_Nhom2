import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/api/api_client.dart';
import '../../chat/screens/chat_screen.dart';
import '../../auth/models/user_model.dart';
import '../models/job_model.dart';
import '../../apply/providers/apply_provider.dart';

class StudentDetailScreen extends StatefulWidget {
  final UserModel student;
  final ApplicationModel? application; // Thông tin đơn ứng tuyển nếu có

  const StudentDetailScreen(
      {super.key, required this.student, this.application});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  Map<String, dynamic>? _reputation;
  bool _isLoading = true;
  late String _currentStatus;
  DateTime? _interviewAt;
  String? _interviewLocation;
  String? _statusNote;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.application?.status ?? '';
    _interviewAt = widget.application?.interviewAt;
    _interviewLocation = widget.application?.interviewLocation;
    _statusNote = widget.application?.statusNote;
    _fetchReputation();

    // Nếu là Nhà tuyển dụng xem đơn đang ở trạng thái 'pending', tự động chuyển sang 'viewed'
    if (widget.application != null && widget.application!.status == 'pending') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<ApplyProvider>()
            .updateStatus(widget.application!.id, 'viewed');
        setState(() => _currentStatus = 'viewed');
      });
    }
  }

  Future<void> _fetchReputation() async {
    try {
      final res =
          await ApiClient().dio.get('/auth/reputation/${widget.student.id}');
      if (mounted) {
        setState(() {
          _reputation = res.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAppStatus(
    String status, {
    String? note,
    DateTime? interviewAt,
    String? interviewLocation,
  }) async {
    if (widget.application == null) return;
    final ok = await context.read<ApplyProvider>().updateStatus(
          widget.application!.id,
          status,
          note: note,
          interviewAt: interviewAt,
          interviewLocation: interviewLocation,
        );
    if (ok && mounted) {
      setState(() {
        _currentStatus = status;
        _statusNote =
            note?.trim().isNotEmpty == true ? note!.trim() : _statusNote;
        _interviewAt = interviewAt ?? _interviewAt;
        _interviewLocation = interviewLocation?.trim().isNotEmpty == true
            ? interviewLocation!.trim()
            : _interviewLocation;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật trạng thái: $status')));
    }
  }

  String get _currentStatusLabel {
    switch (_currentStatus) {
      case 'pending':
        return 'Đang chờ';
      case 'viewed':
        return 'Đã xem';
      case 'interview':
        return 'Phỏng vấn';
      case 'accepted':
        return 'Đã nhận';
      case 'rejected':
        return 'Từ chối';
      default:
        return _currentStatus;
    }
  }

  Future<void> _openCv(String cvUrl) async {
    final uri = Uri.parse(ApiClient.resolveFileUrl(cvUrl));
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _showInterviewSheet() async {
    final app = widget.application;
    if (app == null) return;

    DateTime? interviewAt = _interviewAt ?? app.interviewAt;
    final locationCtrl = TextEditingController(
        text: _interviewLocation ?? app.interviewLocation ?? '');
    final noteCtrl =
        TextEditingController(text: _statusNote ?? app.statusNote ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hẹn phỏng vấn',
                      style: GoogleFonts.sora(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: sheetContext,
                        initialDate: interviewAt ??
                            DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 120)),
                      );
                      if (date == null) return;
                      final time = await showTimePicker(
                        context: sheetContext,
                        initialTime: TimeOfDay.fromDateTime(interviewAt ??
                            DateTime.now().add(const Duration(hours: 1))),
                      );
                      if (time == null) return;
                      setSheetState(() {
                        interviewAt = DateTime(date.year, date.month, date.day,
                            time.hour, time.minute);
                      });
                    },
                    icon: const Icon(Icons.event_available),
                    label: Text(interviewAt == null
                        ? 'Chọn thời gian phỏng vấn'
                        : _formatDateTime(interviewAt!)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: locationCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Địa điểm hoặc link phỏng vấn'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(hintText: 'Ghi chú cho ứng viên'),
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    label: 'Gửi lịch phỏng vấn',
                    onTap: () async {
                      Navigator.pop(context);
                      await _updateAppStatus(
                        'interview',
                        note: noteCtrl.text,
                        interviewAt: interviewAt,
                        interviewLocation: locationCtrl.text,
                      );
                    },
                  ),
                ]),
          ),
        ),
      ),
    );

    locationCtrl.dispose();
    noteCtrl.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final minute = local.minute.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '${local.hour}:$minute $day/$month/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final app = widget.application;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết ứng viên',
            style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.bgPurpleLight.withOpacity(0.2),
              child: Row(
                children: [
                  AvatarCircle(
                    initials: s.initials,
                    size: 70,
                    bg: AppColors.bgPurpleLight,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name,
                          style: GoogleFonts.sora(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          s.major ?? 'Chưa cập nhật chuyên ngành',
                          style: GoogleFonts.dmSans(
                              fontSize: 14, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        if (!_isLoading)
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${_reputation?['avg_rating']?.toString() ?? "0.0"} (${_reputation?['review_count'] ?? 0} đánh giá)',
                                style: GoogleFonts.dmSans(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Phần thông tin đơn ứng tuyển (chỉ hiện nếu đi từ màn Quản lý ứng viên)
            if (app != null) _buildApplicationInfo(app),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Thông tin chung', [
                    _buildInfoRow(
                        Icons.school, 'Trường', s.university ?? 'N/A'),
                    _buildInfoRow(
                        Icons.location_on, 'Địa chỉ', s.location ?? 'N/A'),
                    _buildInfoRow(Icons.phone, 'Số điện thoại',
                        s.phone ?? 'Chưa cung cấp'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Kỹ năng', [
                    if (s.skills.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: s.skills
                            .map<Widget>((sk) => SkillChip(label: sk))
                            .toList(),
                      )
                    else
                      const Text('Chưa cập nhật kỹ năng'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Kinh nghiệm', [
                    Text(s.experience ?? 'Chưa cập nhật kinh nghiệm làm việc',
                        style: GoogleFonts.dmSans(fontSize: 14)),
                  ]),

                  const SizedBox(height: 32),

                  // Các nút thao tác
                  if (app != null)
                    _buildEmployerActions()
                  else
                    _buildGeneralActions(s),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationInfo(ApplicationModel app) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đơn ứng tuyển',
                  style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.bgPurpleLight,
                    borderRadius: BorderRadius.circular(8)),
                child: Text('${app.matchScore}% phù hợp',
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.flag_outlined, 'Trạng thái', _currentStatusLabel),
          if (_interviewAt != null)
            _buildInfoRow(Icons.event_available, 'Phỏng vấn',
                _formatDateTime(_interviewAt!)),
          if (_interviewLocation != null && _interviewLocation!.isNotEmpty)
            _buildInfoRow(Icons.location_on_outlined, 'Địa điểm/link',
                _interviewLocation!),
          if (app.cvUrl != null && app.cvUrl!.isNotEmpty)
            TextButton.icon(
              onPressed: () => _openCv(app.cvUrl!),
              icon: const Icon(Icons.description_outlined),
              label: const Text('Mở CV ứng viên'),
            ),
          Text('Thư giới thiệu:',
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            (app.coverLetter == null || app.coverLetter!.isEmpty)
                ? 'Không có thư giới thiệu'
                : app.coverLetter!,
            style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic),
          ),
          if (_statusNote != null && _statusNote!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Ghi chú:',
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(_statusNote!,
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: AppColors.textPrimary)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmployerActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GradientButton(
                label: 'Chat trao đổi',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChatScreen(
                            otherId: widget.student.id,
                            otherName: widget.student.name))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _showInterviewSheet,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Hẹn phỏng vấn',
                    style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateAppStatus('rejected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Từ chối',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateAppStatus('accepted'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Nhận ứng viên',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGeneralActions(UserModel s) {
    return Row(
      children: [
        Expanded(
          child: GradientButton(
            label: 'Chat ngay',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ChatScreen(otherId: s.id, otherName: s.name))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {}, // Tải CV
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Tải CV',
                style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(title,
              style:
                  GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text('$label: ',
              style:
                  GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted)),
          Expanded(
              child: Text(value,
                  style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
