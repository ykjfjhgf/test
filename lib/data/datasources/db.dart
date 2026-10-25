/// drift 数据库：表定义 + 数据库入口（data/datasources）
///
/// 仓储接口（data/repositories）的落地实现均依赖本数据库。
/// 对应需求：R-DATA-*（本地优先存储，SQLite 支撑全库搜索 R-DIA-06）。
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'db.g.dart';

/// 日记表（映射实体见 lib/data/models/diary_entry.dart）
@DataClassName('DiaryEntryRow')
class DiaryEntries extends Table {
  TextColumn get id => text()();
  TextColumn get notebookId => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();

  /// 日记所属日期（日历页按此日期展示）
  DateTimeColumn get entryDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// 图片路径列表的 JSON 序列化（如 '["/img/a.png"]'）
  TextColumn get imagesJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isPrivate => boolean().withDefault(const Constant(false))();
  BoolColumn get isDraft => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 日记本表（映射实体见 lib/data/models/notebook.dart）
@DataClassName('NotebookRow')
class Notebooks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get coverColorHex =>
      text().withDefault(const Constant('#0AA69A'))();
  BoolColumn get isPrivate => boolean().withDefault(const Constant(false))();
  TextColumn get passwordHash => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 设置键值表（key-value，实体见 lib/data/models/app_settings.dart）
@DataClassName('SettingsRow')
class SettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [DiaryEntries, Notebooks, SettingsTable])
class AppDatabase extends _$AppDatabase {
  /// 正式运行：使用 drift_flutter 管理连接（含迁移/路径）
  AppDatabase() : super(driftDatabase(name: 'diary_app'));

  /// 测试/自定义连接入口（如 NativeDatabase.memory()）
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
