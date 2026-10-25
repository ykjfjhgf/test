/// 日历静态数据（features/calendar/domain）——农历/休班/节气/调休
///
/// ⚠️ 全部为**示意数据**（docs/01-需求规格/日历页需求.md 数据依赖：本地静态资源表，
/// 后续可联网更新）。正式农历/国务院节假日表接入前，展示值不代表真实历法。
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';

enum DayMarkKind { rest, work, festival, solarTerm }

/// 单日标记：农历文本 + 角标（休/班/节日/节气）+ 调休线
class DayMark {
  final String? lunar;
  final String? label;
  final DayMarkKind? kind;
  final bool holidayWork;

  const DayMark({this.lunar, this.label, this.kind, this.holidayWork = false});
}

class CalendarData {
  CalendarData._();

  static const Map<String, DayMark> _marks = {
    // 农历（2026-10 示意）：九月初一 ~ 十月初六
    '2026-10-01': DayMark(lunar: '九月初一', label: '国庆', kind: DayMarkKind.festival),
    '2026-10-02': DayMark(lunar: '九月初二'),
    '2026-10-03': DayMark(lunar: '九月初三'),
    '2026-10-04': DayMark(lunar: '九月初四'),
    '2026-10-05': DayMark(lunar: '九月初五'),
    '2026-10-06': DayMark(lunar: '九月初六'),
    '2026-10-07': DayMark(lunar: '九月初七'),
    '2026-10-08': DayMark(lunar: '九月初八'),
    '2026-10-09': DayMark(lunar: '九月初九', label: '重阳', kind: DayMarkKind.festival),
    '2026-10-10': DayMark(lunar: '九月初十', holidayWork: true), // 调休（示意）
    '2026-10-11': DayMark(lunar: '九月十一'),
    '2026-10-12': DayMark(lunar: '九月十二'),
    '2026-10-13': DayMark(lunar: '九月十三'),
    '2026-10-14': DayMark(lunar: '九月十四'),
    '2026-10-15': DayMark(lunar: '九月十五'),
    '2026-10-16': DayMark(lunar: '九月十六'),
    '2026-10-17': DayMark(lunar: '九月十七'),
    '2026-10-18': DayMark(lunar: '九月十八'),
    '2026-10-19': DayMark(lunar: '九月十九'),
    '2026-10-20': DayMark(lunar: '九月二十'),
    '2026-10-21': DayMark(lunar: '九月廿一'),
    '2026-10-22': DayMark(lunar: '九月廿二'),
    '2026-10-23': DayMark(lunar: '九月廿三', label: '霜降', kind: DayMarkKind.solarTerm),
    '2026-10-24': DayMark(lunar: '九月廿四'),
    '2026-10-25': DayMark(lunar: '九月廿五'),
    '2026-10-26': DayMark(lunar: '九月廿六'),
    '2026-10-27': DayMark(lunar: '九月廿七'),
    '2026-10-28': DayMark(lunar: '九月廿八'),
    '2026-10-29': DayMark(lunar: '九月廿九'),
    '2026-10-30': DayMark(lunar: '十月初一'),
    '2026-10-31': DayMark(lunar: '十月初二'),
  };

  /// 查询单日标记；无记录返回 null（普通日）
  static DayMark? markFor(DateTime d) =>
      _marks['${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'];

  /// 角标颜色映射（R-CAL-01，v0.1.1：休/节日=主题色统一管理；班=蓝；节气=绿）
  static Color kindColor(BuildContext context, DayMarkKind kind) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return switch (kind) {
      DayMarkKind.rest => theme.colorScheme.primary,
      DayMarkKind.work => colors.workBlue,
      DayMarkKind.festival => theme.colorScheme.primary,
      DayMarkKind.solarTerm => colors.festivalGreen,
    };
  }
}
