import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/memo_entry.dart';
import '../providers/memo_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/mood_selector.dart';

class MemoEditScreen extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final MemoEntry? existingMemo;

  const MemoEditScreen({
    super.key,
    required this.initialDate,
    this.existingMemo,
  });

  @override
  ConsumerState<MemoEditScreen> createState() => _MemoEditScreenState();
}

class _MemoEditScreenState extends ConsumerState<MemoEditScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  int _moodIndex = 1;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final m = widget.existingMemo;
    _titleCtrl = TextEditingController(text: m?.title ?? '');
    _bodyCtrl = TextEditingController(text: m?.body ?? '');
    _moodIndex = m?.moodIndex ?? 1;
    _imagePath = m?.imagePath;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imagePath = 'data:image/jpeg;base64,${base64Encode(bytes)}');
    }
  }

  Widget _buildImage(String dataUrl) {
    final bytes = base64Decode(dataUrl.split(',').last);
    return Image.memory(bytes, width: double.infinity, fit: BoxFit.cover);
  }

  Future<void> _save() async {
    final body = _bodyCtrl.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メモ本文を入力してください')),
      );
      return;
    }
    final notifier = ref.read(memoProvider.notifier);
    if (widget.existingMemo != null) {
      final m = widget.existingMemo!;
      m.title = _titleCtrl.text.trim();
      m.body = body;
      m.moodIndex = _moodIndex;
      m.imagePath = _imagePath;
      await notifier.updateMemo(m);
    } else {
      await notifier.addMemo(
        date: widget.initialDate,
        title: _titleCtrl.text.trim(),
        body: body,
        moodIndex: _moodIndex,
        imagePath: _imagePath,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingMemo != null;
    final d = widget.initialDate;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '編集' : '新しいメモ'),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              '保存',
              style: GoogleFonts.notoSansJp(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date chip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.goldLight.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${d.year}年${d.month}月${d.day}日',
                style: GoogleFonts.notoSerifJp(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Mood selector
            MoodSelector(
              selectedIndex: _moodIndex,
              onSelected: (i) => setState(() => _moodIndex = i),
            ),

            const SizedBox(height: 20),

            // Title
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.notoSerifJp(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              decoration: InputDecoration(
                hintText: 'タイトル（任意）',
                hintStyle: GoogleFonts.notoSerifJp(
                    color: AppColors.divider, fontSize: 18),
                border: InputBorder.none,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.gold, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Body + character counter
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _bodyCtrl,
              builder: (context, value, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _bodyCtrl,
                    maxLines: null,
                    minLines: 8,
                    style: GoogleFonts.notoSansJp(
                      fontSize: 15,
                      color: AppColors.text,
                      height: 1.85,
                    ),
                    decoration: InputDecoration(
                      hintText: '今日のできごと、気持ち...',
                      hintStyle: GoogleFonts.notoSansJp(
                          color: AppColors.divider),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.gold, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${value.text.length} 文字',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 100),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.surface,
                ),
                child: _imagePath != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildImage(_imagePath!),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _imagePath = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: AppColors.textMuted, size: 32),
                            SizedBox(height: 6),
                            Text(
                              '写真を追加',
                              style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
