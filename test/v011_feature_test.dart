/// v0.1.1 新增功能测试：
/// - 农历只显示"日"（R-CAL-01 改）
/// - 周首参数（周一/周日）驱动月历网格与周历（R-CAL-10）
/// - AppSettings.firstWeekday 序列化（R-SET-09 配套）
/// - 日历时间轴开关（R-CAL-11）
/// - 日历多选编辑删除状态机（R-CAL-12）
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/core/utils/date_utils.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';
import 'package:flutter_application_2/features/calendar/presentation/calendar_provider.dart';

void main() {
  group('v0.1.1 DateUtils 周首与农历', () {
    test('农历只显示日：九月初一→初一；十月廿一→廿一', () {
      expect(DateUtils.lunarDayOnly('九月初一'), '初一');
      expect(DateUtils.lunarDayOnly('十月廿一'), '廿一');
      expect(DateUtils.lunarDayOnly('正月'), '正月'); // 无日段保持原样
    });

    test('gridDates 默认周一开头（2026-10），首格为 2026-09-28', () {
      final dates = DateUtils.gridDates(2026, 10);
      expect(dates.first, DateTime(2026, 9, 28));
      // 网格长 35 或 42
      expect(dates.length == 35 || dates.length == 42, isTrue);
    });

    test('gridDates 周首=周日：首格为周日 2026-09-27', () {
      final dates =
          DateUtils.gridDates(2026, 10, first: WeekStart.sunday);
      expect(dates.first.weekday, DateTime.sunday);
      expect(dates.first, DateTime(2026, 9, 27));
    });

    test('weekDates 周首=周日：选中周三所在周日周', () {
      final wed = DateTime(2026, 10, 14); // 周三
      final dates = DateUtils.weekDates(wed, first: WeekStart.sunday);
      expect(dates.first.weekday, DateTime.sunday);
      expect(dates.first, DateTime(2026, 10, 11));
      expect(dates.last, DateTime(2026, 10, 17));
    });
  });

  group('v0.1.1 AppSettings.firstWeekday', () {
    test('默认 monday；copyWith 周日可往返序列化', () {
      expect(AppSettings.defaults.firstWeekday, WeekStart.monday);
      final s =
          AppSettings.defaults.copyWith(firstWeekday: WeekStart.sunday);
      expect(AppSettings.fromJson(s.toJson()).firstWeekday, WeekStart.sunday);
    });

    test('旧存档缺字段回退 monday', () {
      final json = AppSettings.defaults.toJson()..remove('firstWeekday');
      expect(AppSettings.fromJson(json).firstWeekday, WeekStart.monday);
    });
  });

  group('v0.1.1 日历状态机（Provider）', () {
    test('时间轴开关：toggleTimeline 翻转 timelineVisible', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(calendarProvider.notifier);
      final before = c.read(calendarProvider).timelineVisible;
      n.toggleTimeline();
      expect(c.read(calendarProvider).timelineVisible, !before);
      n.toggleTimeline();
      expect(c.read(calendarProvider).timelineVisible, before);
    });

    test('多选编辑：进入→勾选两日→退出清空', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(calendarProvider.notifier);
      expect(c.read(calendarProvider).editMode, isFalse);

      n.toggleEditMode();
      expect(c.read(calendarProvider).editMode, isTrue);
      expect(c.read(calendarProvider).selectedDates, isEmpty);

      final d1 = DateTime(2026, 10, 3);
      final d2 = DateTime(2026, 10, 8);
      n.toggleSelectDate(d1);
      n.toggleSelectDate(d2);
      expect(c.read(calendarProvider).selectedDates.length, 2);

      // 再点同一天取消
      n.toggleSelectDate(d1);
      expect(c.read(calendarProvider).selectedDates.length, 1);
      expect(c.read(calendarProvider).selectedDates
          .contains(c.read(calendarProvider).dayKey(d2)), isTrue);

      n.exitEditMode();
      expect(c.read(calendarProvider).editMode, isFalse);
      expect(c.read(calendarProvider).selectedDates, isEmpty);
    });
  });
}
