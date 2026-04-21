import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/memo_entry.dart';
import '../theme/app_theme.dart';

const _moodColors = [
  AppColors.moodHappy,
  AppColors.moodNormal,
  AppColors.moodSad,
  AppColors.moodIdea,
  AppColors.moodAlert,
];
const _moodIcons = ['😊', '😐', '😢', '💡', '⚠️'];

class MemoCard extends StatelessWidget {
  final MemoEntry memo;
  final VoidCallback onTap;

  const MemoCard({super.key, required this.memo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final idx = memo.moodIndex.clamp(0, _moodColors.length - 1);
    final moodColor = _moodColors[idx];
    final moodIcon = _moodIcons[idx];
    final hasImage = memo.imagePath != null;
    final hasTitle = memo.title.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mood accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: moodColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(moodIcon,
                              style: const TextStyle(fontSize: 15)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              hasTitle ? memo.title : memo.body,
                              style: GoogleFonts.notoSerifJp(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (hasTitle) ...[
                        const SizedBox(height: 4),
                        Text(
                          memo.body,
                          style: GoogleFonts.notoSansJp(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Image thumbnail
              if (hasImage)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Image.file(
                    File(memo.imagePath!),
                    width: 72,
                    fit: BoxFit.cover,
                  ),
                )
              else
                const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
