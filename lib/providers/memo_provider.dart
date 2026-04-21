import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/memo_entry.dart';

final memoProvider =
    StateNotifierProvider<MemoNotifier, List<MemoEntry>>((ref) {
  return MemoNotifier();
});

class MemoNotifier extends StateNotifier<List<MemoEntry>> {
  MemoNotifier() : super([]) {
    _loadMemos();
  }

  Box<MemoEntry> get _box => Hive.box<MemoEntry>('memos');
  final _uuid = const Uuid();

  void _loadMemos() {
    state = _box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> addMemo({
    required DateTime date,
    required String title,
    required String body,
    required int moodIndex,
    String? imagePath,
  }) async {
    final now = DateTime.now();
    final entry = MemoEntry()
      ..id = _uuid.v4()
      ..date = DateTime(date.year, date.month, date.day)
      ..title = title
      ..body = body
      ..moodIndex = moodIndex
      ..imagePath = imagePath
      ..createdAt = now
      ..updatedAt = now;
    await _box.put(entry.id, entry);
    _loadMemos();
  }

  Future<void> updateMemo(MemoEntry entry) async {
    entry.updatedAt = DateTime.now();
    await entry.save();
    _loadMemos();
  }

  Future<void> deleteMemo(String id) async {
    await _box.delete(id);
    _loadMemos();
  }

  List<MemoEntry> getMemosForDate(DateTime date) {
    return state
        .where((e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day)
        .toList();
  }

  List<MemoEntry> searchMemos(String query) {
    if (query.isEmpty) return state;
    final lower = query.toLowerCase();
    return state
        .where((e) =>
            e.title.toLowerCase().contains(lower) ||
            e.body.toLowerCase().contains(lower))
        .toList();
  }
}
