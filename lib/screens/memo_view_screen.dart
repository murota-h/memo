import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/memo_entry.dart';
import '../providers/memo_provider.dart';
import '../theme/app_theme.dart';
import 'memo_edit_screen.dart';

const _moodColors = [
  AppColors.moodHappy,
  AppColors.moodNormal,
  AppColors.moodSad,
  AppColors.moodIdea,
  AppColors.moodAlert,
];
const _moodEmojis = ['😊', '😐', '😢', '💡', '⚠️'];
const _moodLabels = ['うれしい', '普通', '辛い', 'ひらめき', '要注意'];

class MemoViewScreen extends ConsumerWidget {
  final MemoEntry memo;

  const MemoViewScreen({super.key, required this.memo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = memo.moodIndex.clamp(0, _moodColors.length - 1);
    final moodColor = _moodColors[idx];

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: '共有',
            onPressed: () {
              final text = memo.title.isNotEmpty
                  ? '${memo.title}\n\n${memo.body}'
                  : memo.body;
              Share.share(text);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '編集',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MemoEditScreen(
                  initialDate: memo.date,
                  existingMemo: memo,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.moodAlert),
            tooltip: '削除',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date + mood chip
            Row(
              children: [
                Text(
                  '${memo.date.year}年${memo.date.month}月${memo.date.day}日',
                  style: GoogleFonts.notoSerifJp(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: moodColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: moodColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_moodEmojis[idx],
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 4),
                      Text(
                        _moodLabels[idx],
                        style: TextStyle(
                          color: moodColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Title
            if (memo.title.isNotEmpty) ...[
              Text(
                memo.title,
                style: GoogleFonts.notoSerifJp(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.goldLight, thickness: 1),
              const SizedBox(height: 16),
            ],

            // Image
            if (memo.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _MemoImage(dataUrl: memo.imagePath!),
              ),
              const SizedBox(height: 20),
            ],

            // Body
            Text(
              memo.body,
              style: GoogleFonts.notoSansJp(
                fontSize: 16,
                color: AppColors.text,
                height: 1.9,
              ),
            ),

            const SizedBox(height: 40),

            // Timestamps
            Text(
              '作成: ${_fmt(memo.createdAt)}',
              style: const TextStyle(
                  color: AppColors.divider, fontSize: 11),
            ),
            if (memo.updatedAt.difference(memo.createdAt).inSeconds > 1)
              Text(
                '更新: ${_fmt(memo.updatedAt)}',
                style: const TextStyle(
                    color: AppColors.divider, fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          '削除しますか？',
          style: GoogleFonts.notoSerifJp(color: AppColors.primary),
        ),
        content: const Text(
          'このメモを削除します。元に戻せません。',
          style: TextStyle(color: AppColors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(memoProvider.notifier)
                  .deleteMemo(memo.id);
              if (context.mounted) {
                Navigator.of(context)
                  ..pop()
                  ..pop();
              }
            },
            child: const Text('削除',
                style: TextStyle(color: AppColors.moodAlert)),
          ),
        ],
      ),
    );
  }
}

class _MemoImage extends StatelessWidget {
  final String dataUrl;
  const _MemoImage({required this.dataUrl});

  @override
  Widget build(BuildContext context) {
    if (!dataUrl.startsWith('data:')) return const SizedBox.shrink();
    final bytes = base64Decode(dataUrl.split(',').last);
    return Image.memory(bytes, width: double.infinity, fit: BoxFit.cover);
  }
}
