import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _universityCtrl;
  late final TextEditingController _majorCtrl;
  late final TextEditingController _expCtrl;
  late final TextEditingController _companyNameCtrl;
  late final TextEditingController _companyFieldCtrl;
  late final TextEditingController _companyWebCtrl;
  late final TextEditingController _companyAddressCtrl;
  late final TextEditingController _companyDescCtrl;

  late List<String> _skills;
  final _skillInputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user!;
    _nameCtrl         = TextEditingController(text: user.name);
    _bioCtrl          = TextEditingController(text: user.bio);
    _phoneCtrl        = TextEditingController(text: user.phone);
    _locationCtrl     = TextEditingController(text: user.location);
    _universityCtrl   = TextEditingController(text: user.university);
    _majorCtrl        = TextEditingController(text: user.major);
    _expCtrl          = TextEditingController(text: user.experience);
    _companyNameCtrl  = TextEditingController(text: user.companyName);
    _companyFieldCtrl = TextEditingController(text: user.companyField);
    _companyWebCtrl   = TextEditingController(text: user.companyWebsite);
    _companyAddressCtrl = TextEditingController(text: user.companyAddress);
    _companyDescCtrl  = TextEditingController(text: user.companyDesc);
    _skills = List.from(user.skills);
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _bioCtrl, _phoneCtrl, _locationCtrl,
      _universityCtrl, _majorCtrl, _expCtrl, _skillInputCtrl,
      _companyNameCtrl, _companyFieldCtrl, _companyWebCtrl,
      _companyAddressCtrl, _companyDescCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final isStudent = auth.user!.isStudent;
    final ok = await auth.updateProfile({
      'name':     _nameCtrl.text.trim(),
      'bio':      _bioCtrl.text.trim(),
      'phone':    _phoneCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      if (isStudent) ...{
        'university': _universityCtrl.text.trim(),
        'major':      _majorCtrl.text.trim(),
        'experience': _expCtrl.text.trim(),
        'skills':     _skills,
      } else ...{
        'company_name':    _companyNameCtrl.text.trim(),
        'company_field':   _companyFieldCtrl.text.trim(),
        'company_website': _companyWebCtrl.text.trim(),
        'company_address': _companyAddressCtrl.text.trim(),
        'company_desc':    _companyDescCtrl.text.trim(),
      },
    });
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lưu thành công!', style: GoogleFonts.dmSans(color: Colors.white)),
        backgroundColor: AppColors.green, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16)));
      Navigator.pop(context);
    } else if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.errorMessage ?? 'Lưu thất bại'),
        backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isStudent = auth.user!.isStudent;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text('Chỉnh sửa hồ sơ', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        backgroundColor: AppColors.bgCard, elevation: 0,
        actions: [
          TextButton(
            onPressed: auth.isLoading ? null : _save,
            child: Text(auth.isLoading ? 'Đang lưu...' : 'Lưu',
              style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _section('Thông tin chung', [
            _field('Họ và tên', _nameCtrl, 'Nguyễn Minh Tú'),
            _field('Giới thiệu', _bioCtrl, 'Viết vài dòng về bản thân...', maxLines: 3),
            _field('Số điện thoại', _phoneCtrl, '0901 234 567', type: TextInputType.phone),
            _field('Địa chỉ', _locationCtrl, 'Hà Nội, Việt Nam'),
          ]),
          const SizedBox(height: 16),
          if (isStudent) ...[
            _section('Học vấn', [
              _field('Trường đại học', _universityCtrl, 'Đại học Bách Khoa HN'),
              _field('Ngành học', _majorCtrl, 'Công nghệ thông tin'),
              _field('Kinh nghiệm', _expCtrl, 'Mô tả kinh nghiệm...', maxLines: 3),
            ]),
            const SizedBox(height: 16),
            _skillsSection(),
          ] else
            _section('Công ty', [
              _field('Tên công ty', _companyNameCtrl, 'Tech Corp VN'),
              _field('Lĩnh vực', _companyFieldCtrl, 'Công nghệ phần mềm'),
              _field('Website', _companyWebCtrl, 'https://company.vn', type: TextInputType.url),
              _field('Địa chỉ', _companyAddressCtrl, '123 Nguyễn Huệ, Q1'),
              _field('Mô tả', _companyDescCtrl, 'Giới thiệu công ty...', maxLines: 4),
            ]),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _section(String title, List<Widget> fields) {
    return Container(
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...fields,
      ]),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(controller: ctrl, keyboardType: type, maxLines: maxLines,
          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: hint)),
      ]),
    );
  }

  Widget _skillsSection() {
    return Container(
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Kỹ năng', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        TextField(
          controller: _skillInputCtrl,
          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Flutter, Python, Figma...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              onPressed: _addSkill,
            ),
          ),
          onSubmitted: (_) => _addSkill(),
        ),
        if (_skills.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6,
            children: _skills.map((s) => Chip(
              label: Text(s, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.primary)),
              deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
              onDeleted: () => setState(() => _skills.remove(s)),
              backgroundColor: AppColors.bgPurpleLight,
              side: const BorderSide(color: AppColors.primary, width: 0.5),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            )).toList()),
        ],
      ]),
    );
  }

  void _addSkill() {
    final s = _skillInputCtrl.text.trim();
    if (s.isNotEmpty && !_skills.contains(s)) {
      setState(() { _skills.add(s); _skillInputCtrl.clear(); });
    }
  }
}
