/// 备份与导出服务（services/backup_service.dart）——R-SET-06
///
/// 将全部日记 + 日记本 + 设置导出为单一 JSON 文件（桌面端写当前目录，
/// 移动端后续接入 path_provider）。恢复 = 读回 JSON 覆盖（本期提供解析）。
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_2/data/models/app_settings.dart';
import 'package:flutter_application_2/data/models/diary_entry.dart';
import 'package:flutter_application_2/data/models/notebook.dart';

class BackupService {
  BackupService._();

  /// 组装全量备份 JSON
  static String buildJson({
    required List<DiaryEntry> entries,
    required List<Notebook> notebooks,
    required AppSettings settings,
  }) {
    return const JsonEncoder.withIndent('  ').convert({
      'version': '0.1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings.toJson(),
      'notebooks': notebooks.map((n) => n.toJson()).toList(),
      'entries': entries.map((e) => e.toJson()).toList(),
    });
  }

  /// 导出到文件；返回写入路径
  static Future<String> exportToFile(
      String json, String directory) async {
    final file = File('$directory/diary_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(json, flush: true);
    return file.path;
  }

  /// 解析备份 JSON（恢复前置步骤）；返回 null 表示格式不合法
  static ({List<DiaryEntry> entries, List<Notebook> notebooks, AppSettings? settings})?
      parseBackup(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final entries = (map['entries'] as List<dynamic>? ?? const [])
          .map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      final notebooks = (map['notebooks'] as List<dynamic>? ?? const [])
          .map((n) => Notebook.fromJson(n as Map<String, dynamic>))
          .toList();
      final settings =
          map['settings'] == null ? null : AppSettings.fromJson(map['settings'] as Map<String, dynamic>);
      return (entries: entries, notebooks: notebooks, settings: settings);
    } catch (_) {
      return null;
    }
  }
}
