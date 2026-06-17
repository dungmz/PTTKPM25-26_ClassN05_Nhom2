import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../models/job_model.dart';
import '../providers/jobs_provider.dart';

class CreateJobScreen extends StatefulWidget {
  final JobModel? job;
  const CreateJobScreen({super.key, this.job});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _shiftCtrl = TextEditingController();

  final _skillCtrl = TextEditingController();
  final _requirementCtrl = TextEditingController();
  final _benefitCtrl = TextEditingController();

  String _type = 'Part-time';
  String _category = 'Marketing';
  bool _isActive = true;
  bool _isSubmitting = false;

  final List<String> _skills = [];
  final List<String> _requirements = [];
  final List<String> _benefits = [];

  bool get _isEditing => widget.job != null;

  static const _types = ['Full-time', 'Part-time', 'Internship', 'Remote'];
  static const _categories = [
    'Marketing',
    'IT',
    'Kế toán',
    'Thiết kế',
    'Data',
    'Bán hàng',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    final job = widget.job;
    if (job == null) return;

    _titleCtrl.text = job.title;
    _descCtrl.text = job.description;
    _salaryCtrl.text = job.salary ?? '';
    _locationCtrl.text = job.location ?? '';
    _shiftCtrl.text = job.shift ?? '';
    _type = _types.contains(job.type) ? job.type : 'Part-time';
    final category = job.category;
    _category =
        category != null && _categories.contains(category) ? category : 'Khác';
    _isActive = job.isActive;
    _skills.addAll(job.skills);
    _requirements.addAll(job.requirements);
    _benefits.addAll(job.benefits);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _salaryCtrl.dispose();
    _locationCtrl.dispose();
    _shiftCtrl.dispose();
    _skillCtrl.dispose();
    _requirementCtrl.dispose();
    _benefitCtrl.dispose();
    super.dispose();
  }

  void _addItem(TextEditingController controller, List<String> target) {
    final value = controller.text.trim();
    if (value.isEmpty || target.contains(value)) return;
    setState(() {
      target.add(value);
      controller.clear();
    });
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final jobsProvider = context.read<JobsProvider>();
    final data = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'salary': _salaryCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'type': _type,
      'category': _category,
      'shift': _shiftCtrl.text.trim(),
      'skills': _skills,
      'requirements': _requirements,
      'benefits': _benefits,
      'is_active': _isActive,
    };

    final editingJob = widget.job;
    final ok = editingJob != null
        ? await jobsProvider.updateJob(editingJob.id, data)
        : await jobsProvider.createJob(data);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? (_isEditing ? 'Cập nhật tin thành công' : 'Đăng tin thành công')
            : (jobsProvider.error ?? 'Đã xảy ra lỗi')),
        backgroundColor: ok ? AppColors.green : AppColors.red,
      ),
    );

    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Sửa tin tuyển dụng' : 'Đăng tin tuyển dụng',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.bgCard,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField('Tiêu đề công việc', _titleCtrl,
                  'VD: Nhân viên phục vụ quán cafe'),
              const SizedBox(height: 16),
              _buildField(
                  'Mô tả công việc', _descCtrl, 'Mô tả chi tiết công việc...',
                  maxLines: 5),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildField('Lương', _salaryCtrl, 'VD: 25k/h',
                        required: false),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTypeDropdown()),
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildField('Địa điểm', _locationCtrl, 'VD: Quận 1, TP.HCM',
                  required: false),
              const SizedBox(height: 16),
              _buildField('Ca làm việc', _shiftCtrl, 'VD: 8:00 - 12:00',
                  required: false),
              const SizedBox(height: 16),
              _buildChipEditor(
                title: 'Kỹ năng yêu cầu',
                hint: 'VD: Giao tiếp tốt',
                controller: _skillCtrl,
                items: _skills,
              ),
              const SizedBox(height: 16),
              _buildChipEditor(
                title: 'Yêu cầu ứng viên',
                hint: 'VD: Có thể làm tối thiểu 3 buổi/tuần',
                controller: _requirementCtrl,
                items: _requirements,
              ),
              const SizedBox(height: 16),
              _buildChipEditor(
                title: 'Quyền lợi',
                hint: 'VD: Đào tạo trước khi làm',
                controller: _benefitCtrl,
                items: _benefits,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Tin đang tuyển',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _isActive
                      ? 'Ứng viên có thể xem và ứng tuyển'
                      : 'Ẩn tin khỏi danh sách công khai',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 28),
              GradientButton(
                label: _isSubmitting
                    ? 'Đang lưu...'
                    : (_isEditing ? 'Lưu thay đổi' : 'Đăng tin ngay'),
                onTap: _submit,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (value) {
            if (!required) return null;
            return value == null || value.trim().isEmpty
                ? 'Vui lòng điền thông tin'
                : null;
          },
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Loại hình'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _type,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _type = value);
          },
          decoration: _inputDecoration('Loại hình'),
          items: _types
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type, style: GoogleFonts.dmSans(fontSize: 14)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Lĩnh vực'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _category,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _category = value);
          },
          decoration: _inputDecoration('Lĩnh vực'),
          items: _categories
              .map((category) => DropdownMenuItem(
                    value: category,
                    child:
                        Text(category, style: GoogleFonts.dmSans(fontSize: 14)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildChipEditor({
    required String title,
    required String hint,
    required TextEditingController controller,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(title),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: _inputDecoration(hint),
                onSubmitted: (_) => _addItem(controller, items),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => _addItem(controller, items),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Chip(
                    label: Text(item, style: GoogleFonts.dmSans(fontSize: 12)),
                    onDeleted: () => setState(() => items.remove(item)),
                    backgroundColor: AppColors.bgPurpleLight,
                    deleteIconColor: AppColors.primary,
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.bgCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
    );
  }
}
