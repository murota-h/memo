import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/memo_entry.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MemoEntryAdapter());
  await Hive.openBox<MemoEntry>('memos');
  runApp(const ProviderScope(child: KaleidoscopeMemoApp()));
}
