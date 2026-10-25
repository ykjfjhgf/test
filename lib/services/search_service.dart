/// 全库搜索服务（services/search_service.dart）——跨所有日记本
///
/// R-DIA-06：包装 EntryRepository.search，按月份分组；结果携带所属日记本名
///（由调用方提供笔记本映射，避免服务层直连数据源）。
library;

import 'package:flutter_application_2/data/models/diary_entry.dart';
import 'package:flutter_application_2/core/utils/date_utils.dart';

/// 单个月份分组
class SearchGroup {
  final String monthKey;
  final List<DiaryEntry> entries;

  const SearchGroup({required this.monthKey, required this.entries});
}

class SearchService {
  /// 按月份分组（最新在前）
  static List<SearchGroup> groupByMonth(List<DiaryEntry> entries) {
    final groups = <String, List<DiaryEntry>>{};
    for (final e in entries) {
      final key = DateUtils.monthKey(e.entryDate);
      (groups[key] ??= []).add(e);
    }
    final sorted = groups.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return [
      for (final g in sorted) SearchGroup(monthKey: g.key, entries: g.value),
    ];
  }

  /// 月份文案：'2026-10' → '2026年10月'
  static String monthLabel(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;
    return '${parts[0]}年${int.parse(parts[1])}月';
  }
}
