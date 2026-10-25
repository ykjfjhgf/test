/// 全局依赖注入与跨页共享状态（Riverpod Provider）
///
/// 数据库与仓储由这里统一提供；设置/日记列表/日记本列表以 Stream 形式共享
/// （主题切换即时生效、各页数据联动刷新）。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/data/datasources/db.dart';
import 'package:flutter_application_2/data/datasources/drift_entry_repository.dart';
import 'package:flutter_application_2/data/datasources/drift_notebook_repository.dart';
import 'package:flutter_application_2/data/datasources/drift_settings_repository.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';
import 'package:flutter_application_2/data/models/diary_entry.dart';
import 'package:flutter_application_2/data/models/notebook.dart';
import 'package:flutter_application_2/data/repositories/entry_repository.dart';
import 'package:flutter_application_2/data/repositories/notebook_repository.dart';
import 'package:flutter_application_2/data/repositories/settings_repository.dart';

/// 数据库实例（测试可覆盖为内存库）
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final entryRepositoryProvider = Provider<EntryRepository>(
    (ref) => DriftEntryRepository(ref.watch(databaseProvider)));

final notebookRepositoryProvider = Provider<NotebookRepository>(
    (ref) => DriftNotebookRepository(ref.watch(databaseProvider)));

final settingsRepositoryProvider = Provider<SettingsRepository>(
    (ref) => DriftSettingsRepository(ref.watch(databaseProvider)));

/// 设置流（主题切换即时生效，R-SET-01/02）
final settingsProvider =
    StreamProvider<AppSettings>((ref) => ref.watch(settingsRepositoryProvider).watch());

/// 全部日记流（日历时间线 / 日记页 / 编辑器联动刷新）
final entryListProvider = StreamProvider<List<DiaryEntry>>(
    (ref) => ref.watch(entryRepositoryProvider).watchAll());

/// 全部日记本流（日记页选择条 / 设置页管理 / 编辑器归属）
final notebookListProvider = StreamProvider<List<Notebook>>(
    (ref) => ref.watch(notebookRepositoryProvider).watchAll());
