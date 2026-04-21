import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/memo_entry.dart';
import '../providers/memo_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/memo_card.dart';
import '../widgets/search_delegate.dart';
import 'memo_edit_screen.dart';
import 'memo_view_screen.dart';

const _moodColors = [
  AppColors.moodHappy,
  AppColors.moodNormal,
  AppColors.moodSad,
  AppColors.moodIdea,
  AppColors.moodAlert,
];

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final allMemos = ref.watch(memoProvider);

    final selectedMemos = allMemos
        .where((e) =>
            e.date.year == _selectedDay.year &&
            e.date.month == _selectedDay.month &&
            e.date.day == _selectedDay.day)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kaleidoscope',
          style: GoogleFonts.notoSerifJp(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '検索',
            onPressed: () => showSearch(
              context: context,
              delegate: MemoSearchDelegate(allMemos),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(allMemos),
          const Divider(height: 1, color: AppColors.divider),
          _buildDateHeader(),
          Expanded(
            child: selectedMemos.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: selectedMemos.length,
                    itemBuilder: (_, i) => MemoCard(
                      memo: selectedMemos[i],
                      onTap: () => _openMemo(selectedMemos[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMemo,
        tooltip: '新しいメモ',
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }

  Widget _buildCalendar(List<MemoEntry> allMemos) {
    return TableCalendar<MemoEntry>(
      firstDay: DateTime(2020),
      lastDay: DateTime(2035),
      focusedDay: _focusedDay,
      selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
      eventLoader: (day) => allMemos
          .where((e) =>
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day)
          .toList(),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
      },
      onPageChanged: (focused) => setState(() => _focusedDay = focused),
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: GoogleFonts.notoSerifJp(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        leftChevronIcon:
            const Icon(Icons.chevron_left, color: AppColors.primary),
        rightChevronIcon:
            const Icon(Icons.chevron_right, color: AppColors.primary),
        headerPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          border: Border.all(color: AppColors.gold, width: 1.5),
          shape: BoxShape.circle,
        ),
        todayTextStyle: GoogleFonts.notoSansJp(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: GoogleFonts.notoSansJp(color: Colors.white),
        defaultTextStyle: GoogleFonts.notoSansJp(color: AppColors.text),
        weekendTextStyle:
            GoogleFonts.notoSansJp(color: AppColors.textMuted),
        outsideTextStyle:
            GoogleFonts.notoSansJp(color: AppColors.divider),
        markersMaxCount: 0, // custom markers via calendarBuilders
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;
          return Positioned(
            bottom: 5,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: events.take(3).map((e) {
                final idx =
                    e.moodIndex.clamp(0, _moodColors.length - 1);
                return Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: _moodColors[idx],
                    shape: BoxShape.circle,
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateHeader() {
    final d = _selectedDay;
    final weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final wd = weekdays[d.weekday - 1];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text(
            '${d.year}年${d.month}月${d.day}日（$wd）',
            style: GoogleFonts.notoSerifJp(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note_rounded,
              size: 52, color: AppColors.goldLight),
          const SizedBox(height: 12),
          Text(
            'まだメモがありません',
            style: GoogleFonts.notoSansJp(
                color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '右下のボタンから記録しましょう',
            style: GoogleFonts.notoSansJp(
                color: AppColors.divider, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _openMemo(MemoEntry memo) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MemoViewScreen(memo: memo)),
    );
  }

  void _createMemo() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MemoEditScreen(initialDate: _selectedDay),
      ),
    );
  }
}
