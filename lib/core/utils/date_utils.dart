/// 日期工具（core/utils）——格式化 / 相对时间 / 周历计算
///
/// 对应 R-CAL-01（头部年月+周数）、R-CAL-05（底部面板日期文案）、
/// R-DIA-03（卡片首行日期+相对时间）、R-DIA-06（搜索按月分组）。
/// v0.1.1：网格/周历支持周首（周一/周日，R-CAL-10）。
library;

import 'package:flutter_application_2/data/models/app_settings.dart';

const List<String> _weekdayCn = ['一', '二', '三', '四', '五', '六', '日'];

class DateUtils {
  DateUtils._();

  /// '10月24日'
  static String shortDate(DateTime d) => '${d.month}月${d.day}日';

  /// '周六'
  static String weekday(DateTime d) => '周${_weekdayCn[d.weekday - 1]}';

  /// '10月24日·周六'
  static String shortDateWithWeekday(DateTime d) => '${shortDate(d)}·${weekday(d)}';

  /// '2026年10月'（数字月，对齐参考图头部）
  static String monthLabel(DateTime d) => '${d.year}年${d.month}月';

  /// '2026/10/24 15:10'
  static String full(DateTime d) =>
      '${d.year}/${_two(d.month)}/${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}';

  /// 'HH:mm'
  static String time(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

  /// 相对时间：刚刚 / N分钟前 / N小时前 / 昨天 / N天前 / M月d日
  static String relative(DateTime now, DateTime t) {
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24 && isSameDay(now, t)) return '${diff.inHours}小时前';
    if (diff.inHours < 48) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return shortDate(t);
  }

  /// 按月分组 key（搜索页分组，R-DIA-06）
  static String monthKey(DateTime d) => '${d.year}-${_two(d.month)}';

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// 周起点（R-CAL-10：周一或周日，默认周一）
  static DateTime weekStart(DateTime d, {WeekStart first = WeekStart.monday}) {
    final base = first == WeekStart.monday ? DateTime.monday : DateTime.sunday;
    var offset = d.weekday - base;
    if (offset < 0) offset += 7;
    return DateTime(d.year, d.month, d.day - offset);
  }

  /// ISO 周数（第N周，R-CAL-01；v0.1.1 支持周首）
  static int weekNumber(DateTime d, {WeekStart first = WeekStart.monday}) {
    final start = DateTime(d.year, 1, 1);
    final days = d.difference(start).inDays;
    final base = first == WeekStart.monday ? DateTime.monday : DateTime.sunday;
    final adjusted = days + (base - start.weekday);
    return (adjusted ~/ 7) + 1;
  }

  /// 月份网格日期（含跨月补位，R-CAL-01；v0.1.1 支持周首）
  static List<DateTime> gridDates(int year, int month,
      {WeekStart first = WeekStart.monday}) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final base = first == WeekStart.monday ? DateTime.monday : DateTime.sunday;
    var lead = firstDay.weekday - base;
    if (lead < 0) lead += 7;
    final cells = lead + daysInMonth;
    final rows = (cells / 7).ceil();
    final result = <DateTime>[];
    for (var i = 0; i < rows * 7; i++) {
      result.add(DateTime(year, month, 1 - lead + i));
    }
    return result;
  }

  /// 选中日所在周的一行日期（周历，R-CAL-04；v0.1.1 支持周首）
  static List<DateTime> weekDates(DateTime d,
      {WeekStart first = WeekStart.monday}) {
    final start = weekStart(d, first: first);
    return List.generate(7, (i) => DateTime(start.year, start.month, start.day + i));
  }

  /// 农历只显示"日"（v0.1.1，R-CAL-01 改）：'九月初一'→'初一'；'九月廿一'→'廿一'
  static String lunarDayOnly(String lunar) {
    final idx = lunar.indexOf('月');
    if (idx < 0 || idx == lunar.length - 1) return lunar;
    return lunar.substring(idx + 1);
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}
