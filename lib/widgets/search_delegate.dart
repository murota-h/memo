import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/memo_entry.dart';
import '../theme/app_theme.dart';
import '../screens/memo_view_screen.dart';

const _moodIcons = ['😊', '😐', '😢', '💡', '⚠️'];

class MemoSearchDelegate extends SearchDelegate<MemoEntry?> {
  final List<MemoEntry> allMemos;

  MemoSearchDelegate(this.allMemos);

  @override
  String get searchFieldLabel => 'メモを検索...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.textMuted),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final lower = query.toLowerCase();
    final results = query.isEmpty
        ? allMemos
        : allMemos
            .where((e) =>
                e.title.toLowerCase().contains(lower) ||
                e.body.toLowerCase().contains(lower))
            .toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          '見つかりませんでした',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return Container(
      color: AppColors.background,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        separatorBuilder: (_, __) =>
            const Divider(color: AppColors.divider, height: 1),
        itemBuilder: (context, i) {
          final memo = results[i];
          final idx = memo.moodIndex.clamp(0, _moodIcons.length - 1);
          return ListTile(
            onTap: () {
              close(context, memo);
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => MemoViewScreen(memo: memo)),
              );
            },
            leading: Text(_moodIcons[idx],
                style: const TextStyle(fontSize: 20)),
            title: Text(
              memo.title.isNotEmpty ? memo.title : memo.body,
              style: GoogleFonts.notoSerifJp(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${memo.date.year}/${memo.date.month.toString().padLeft(2, '0')}/${memo.date.day.toString().padLeft(2, '0')}',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}
