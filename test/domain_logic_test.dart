/// 领域逻辑测试：日期工具 / 折叠判定 / 搜索分组 / 安全与备份服务
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/core/utils/date_utils.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';
import 'package:flutter_application_2/data/models/diary_entry.dart';
import 'package:flutter_application_2/data/models/notebook.dart';
import 'package:flutter_application_2/features/calendar/domain/calendar_state.dart';
import 'package:flutter_application_2/services/backup_service.dart';
import 'package:flutter_application_2/services/search_service.dart';
import 'package:flutter_application_2/services/security_service.dart';

DiaryEntry entry(String id, DateTime date, {String content = ''}) => DiaryEntry(
      id: id,
      notebookId: 'nb1',
      title: '标题$id',
      content: content,
      entryDate: date,
      createdAt: DateTime(2026, 10, 1, 10),
      updatedAt: DateTime(2026, 10, 1, 10),
    );

void main() {
  group('DateUtils', () {
    test('相对时间：分钟/小时/昨天/天数', () {
      final now = DateTime(2026, 10, 24, 15, 10);
      expect(DateUtils.relative(now, DateTime(2026, 10, 24, 15, 9, 30)), '刚刚');
      expect(DateUtils.relative(now, DateTime(2026, 10, 24, 14, 50)), '20分钟前');
      expect(DateUtils.relative(now, DateTime(2026, 10, 24, 12, 10)), '3小时前');
      expect(DateUtils.relative(now, DateTime(2026, 10, 23, 15, 10)), '昨天');
      expect(DateUtils.relative(now, DateTime(2026, 10, 20, 15, 10)), '4天前');
      expect(DateUtils.relative(now, DateTime(2026, 9, 5, 15, 10)), '9月5日');
    });

    test('月份网格：周一起始 + 7 的倍数', () {
      final dates = DateUtils.gridDates(2026, 10); // 10-01 是周四
      expect(dates.length % 7, 0);
      expect(dates.first.weekday, DateTime.monday);
      expect(dates.first.day, 28); // 9-28 周一（补位）
    });

    test('周历：选中日所在周一', () {
      final dates = DateUtils.weekDates(DateTime(2026, 10, 24));
      expect(dates.length, 7);
      expect(dates.first.weekday, DateTime.monday);
      expect(dates.first.day, 19);
    });

    test('周数与文案', () {
      expect(DateUtils.weekNumber(DateTime(2026, 10, 24)), greaterThan(40));
      expect(DateUtils.monthLabel(DateTime(2026, 10, 1)), '2026年10月');
      expect(DateUtils.monthKey(DateTime(2026, 10, 1)), '2026-10');
    });
  });

  group('折叠判定（R-CAL-04）', () {
    test('上拉折叠 / 下拉复位 / 阈值内不动作', () {
      expect(foldAction(-30), FoldAction.fold);
      expect(foldAction(30), FoldAction.unfold);
      expect(foldAction(10), FoldAction.none);
      expect(foldAction(-10), FoldAction.none);
    });
  });

  group('SearchService 分组（R-DIA-06）', () {
    test('按月分组且月份最新在前', () {
      final groups = SearchService.groupByMonth([
        entry('a', DateTime(2026, 9, 1)),
        entry('b', DateTime(2026, 10, 2)),
        entry('c', DateTime(2026, 10, 3)),
      ]);
      expect(groups.length, 2);
      expect(groups.first.monthKey, '2026-10');
      expect(groups.first.entries.length, 2);
      expect(SearchService.monthLabel('2026-10'), '2026年10月');
    });
  });

  group('SecurityService（R-SET-04）', () {
    test('哈希稳定且可校验', () {
      final h = SecurityService.hashPassword('abc123');
      expect(h, isNot('abc123'));
      expect(SecurityService.verify('abc123', h), isTrue);
      expect(SecurityService.verify('wrong', h), isFalse);
    });

    test('锁定时长映射与锁定判定', () {
      expect(SecurityService.lockTimeoutDuration(LockTimeout.off), isNull);
      expect(SecurityService.lockTimeoutDuration(LockTimeout.oneMinute),
          const Duration(minutes: 1));
      expect(SecurityService.isLocked(null, LockTimeout.immediately), isTrue);
      expect(SecurityService.isLocked(DateTime.now(), LockTimeout.off), isFalse);
    });
  });

  group('BackupService（R-SET-06）', () {
    test('导出 JSON 可往返解析', () {
      final json = BackupService.buildJson(
        entries: [entry('e1', DateTime(2026, 10, 24))],
        notebooks: [
          Notebook(id: 'nb1', name: '工作', createdAt: DateTime(2026, 1, 1)),
        ],
        settings: const AppSettings(themeMode: AppThemeMode.dark),
      );
      final parsed = BackupService.parseBackup(json)!;
      expect(parsed.entries.single.id, 'e1');
      expect(parsed.notebooks.single.name, '工作');
      expect(parsed.settings!.themeMode, AppThemeMode.dark);
    });

    test('非法 JSON 返回 null', () {
      expect(BackupService.parseBackup('not json'), isNull);
    });
  });
}
