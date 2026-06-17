import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ── Avatar circle ────────────────────────────────────────────────────────────
class AvatarCircle extends StatelessWidget {
  final String initials;
  final double size;
  final Color bg;
  final Color fg;
  final double fontSize;

  const AvatarCircle({
    super.key,
    required this.initials,
    this.size = 40,
    this.bg = AppColors.bgPurpleLight,
    this.fg = AppColors.primary,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.sora(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

// ── Logo square ───────────────────────────────────────────────────────────────
class LogoSquare extends StatelessWidget {
  final String letters;
  final double size;

  const LogoSquare({super.key, required this.letters, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.bgPurpleLight,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        letters,
        style: GoogleFonts.sora(
          fontSize: size * 0.33,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Tag chip ──────────────────────────────────────────────────────────────────
class TagChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const TagChip({
    super.key,
    required this.label,
    this.bg = const Color(0xFFF5F4FB),
    this.fg = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}

// ── Match pill ────────────────────────────────────────────────────────────────
class MatchPill extends StatelessWidget {
  final int score;

  const MatchPill({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgGreenLight,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$score% phù hợp',
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.green,
        ),
      ),
    );
  }
}

// ── Job card ──────────────────────────────────────────────────────────────────
class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LogoSquare(letters: job.logo),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.company,
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            job.location,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                MatchPill(score: job.matchScore),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              job.title,
              style: GoogleFonts.sora(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                TagChip(
                  label: job.type,
                  bg: AppColors.bgGreenLight,
                  fg: AppColors.green,
                ),
                TagChip(
                  label: job.shift,
                  bg: AppColors.bgBlueLight,
                  fg: AppColors.blue,
                ),
                ...job.skills
                    .take(2)
                    .map((s) => TagChip(label: s))
                    .toList(),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              job.salary,
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Gradient button ───────────────────────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final List<Color> colors;
  final double? height;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.colors = const [AppColors.primary, AppColors.primaryLight],
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Skill chip (profile) ──────────────────────────────────────────────────────
class SkillChip extends StatelessWidget {
  final String label;

  const SkillChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgPurpleLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}