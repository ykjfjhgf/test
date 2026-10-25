/// 设置仓储的 drift 实现（数据层，对应 SettingsRepository 接口）
///
/// 以键值对存储 AppSettings（settings 表，key-value）。
/// 对应需求：R-SET-*（主题模式/主题色/锁定时长/编辑器偏好持久化）。
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_application_2/data/datasources/db.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';
import 'package:flutter_application_2/data/repositories/settings_repository.dart';

class DriftSettingsRepository implements SettingsRepository {
  final AppDatabase _db;

  /// 单行设置以固定 key 存 JSON，简单可靠
  static const _settingsKey = 'app_settings';

  DriftSettingsRepository(this._db);

  Future<SettingsRow?> _readRow() async {
    final query = _db.select(_db.settingsTable)
      ..where((t) => t.key.equals(_settingsKey));
    final rows = await query.get();
    return rows.isEmpty ? null : rows.first;
  }

  @override
  Future<AppSettings> load() async {
    final row = await _readRow();
    if (row == null) return AppSettings.defaults;
    try {
      return AppSettings.fromJson(
          jsonDecode(row.value) as Map<String, dynamic>);
    } catch (_) {
      // 数据损坏时回退默认，不阻塞启动
      return AppSettings.defaults;
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _db.into(_db.settingsTable).insert(
          SettingsTableCompanion.insert(
            key: _settingsKey,
            value: jsonEncode(settings.toJson()),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Stream<AppSettings> watch() {
    final query = _db.select(_db.settingsTable)
      ..where((t) => t.key.equals(_settingsKey));
    return query.watch().map((rows) {
      if (rows.isEmpty) return AppSettings.defaults;
      try {
        return AppSettings.fromJson(
            jsonDecode(rows.first.value) as Map<String, dynamic>);
      } catch (_) {
        return AppSettings.defaults;
      }
    });
  }
}
