import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../auth/providers/auth_provider.dart';

class CvManagementScreen extends StatelessWidget {
  const CvManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final cvUrl = user?.cvUrl;
    final hasCv = cvUrl != null && cvUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(title: const Text('Quan ly CV')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _StatusPanel(cvUrl: cvUrl),
            const SizedBox(height: 16),
            GradientButton(
              label: hasCv ? 'Thay the CV' : 'Tai CV len',
              onTap: auth.isCvUpdating ? () {} : () => _pickAndUpload(context),
            ),
            const SizedBox(height: 12),
            if (hasCv)
              OutlinedButton.icon(
                onPressed:
                    auth.isCvUpdating ? null : () => _openCv(context, cvUrl),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Mo CV hien tai'),
              ),
            if (hasCv) const SizedBox(height: 12),
            if (hasCv)
              OutlinedButton.icon(
                onPressed:
                    auth.isCvUpdating ? null : () => _confirmDelete(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Xoa CV'),
              ),
            if (auth.isCvUpdating) ...[
              const SizedBox(height: 18),
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ],
            const SizedBox(height: 24),
            _GuidePanel(),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      withData: kIsWeb,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final ok = await context.read<AuthProvider>().uploadCV(
          filePath: file.path,
          fileBytes: file.bytes,
          fileName: file.name,
        );

    if (!context.mounted) return;
    _showMessage(
      context,
      ok
          ? 'Da cap nhat CV'
          : context.read<AuthProvider>().errorMessage ?? 'Upload CV that bai',
      ok,
    );
  }

  Future<void> _openCv(BuildContext context, String cvUrl) async {
    final uri = Uri.parse(ApiClient.resolveFileUrl(cvUrl));
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted || ok) return;
    _showMessage(context, 'Khong mo duoc CV', false);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Xoa CV',
            style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
        content: Text('CV hien tai se bi go khoi ho so cua ban.',
            style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Huy',
                style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final ok = await context.read<AuthProvider>().deleteCV();
              if (!context.mounted) return;
              _showMessage(
                context,
                ok
                    ? 'Da xoa CV'
                    : context.read<AuthProvider>().errorMessage ??
                        'Xoa CV that bai',
                ok,
              );
            },
            child: Text('Xoa',
                style: GoogleFonts.dmSans(
                    color: AppColors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.green : AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final String? cvUrl;

  const _StatusPanel({this.cvUrl});

  @override
  Widget build(BuildContext context) {
    final hasCv = cvUrl != null && cvUrl!.isNotEmpty;
    final fileName = hasCv ? Uri.parse(cvUrl!).pathSegments.last : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasCv ? AppColors.bgGreenLight : AppColors.bgAmberLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasCv ? Icons.description_rounded : Icons.upload_file_rounded,
              color: hasCv ? AppColors.green : AppColors.amber,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCv ? 'CV da san sang' : 'Chua co CV',
                  style: GoogleFonts.sora(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasCv
                      ? fileName!
                      : 'Tai len file PDF, DOC hoac DOCX de ung tuyen nhanh hon.',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Luu y',
            style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          _GuideRow(text: 'Dinh dang ho tro: PDF, DOC, DOCX.'),
          _GuideRow(text: 'Dung luong toi da: 10MB.'),
          _GuideRow(text: 'CV nay se duoc dung mac dinh khi ban ung tuyen.'),
        ],
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  final String text;

  const _GuideRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 16, color: AppColors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
