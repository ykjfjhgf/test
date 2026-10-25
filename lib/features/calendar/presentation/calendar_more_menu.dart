/// 日历页更多菜单（features/calendar/presentation）——v0.1.1 R-CAL-08 改
///
/// 由头部「⋯」圆钮触发（翻月箭头已移除，翻月改由 PageView 左右滑动）：
/// 1. 每周第一天：周一 / 周日（R-CAL-10）
/// 2. 显示时间轴开关（R-CAL-11，关闭后列表伸长）
/// 3. 编辑（R-CAL-12：多选日期统一删除）
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';

enum CalendarMenuAction {
  setFirstMonday,
  setFirstSunday,
  toggleTimeline,
  enterEditMode,
}

class CalendarMoreMenu {
  CalendarMoreMenu._();

  static Future<CalendarMenuAction?> show(
      BuildContext context, WeekStart firstWeekday, bool timelineVisible) async {
    final colors = Theme.of(context).extension<AppColors>()!;

    return showModalBottomSheet<CalendarMenuAction>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(ctx, '日历设置'),
            _item(ctx, Icons.view_week_outlined, '每周第一天：周一',
                checked: firstWeekday == WeekStart.monday,
                action: CalendarMenuAction.setFirstMonday),
            _item(ctx, Icons.view_week_outlined, '每周第一天：周日',
                checked: firstWeekday == WeekStart.sunday,
                action: CalendarMenuAction.setFirstSunday),
            const Divider(height: 1),
            _item(ctx, Icons.timeline, '显示时间轴',
                checked: timelineVisible,
                action: CalendarMenuAction.toggleTimeline),
            const Divider(height: 1),
            _item(ctx, Icons.edit_calendar_outlined, '编辑',
                action: CalendarMenuAction.enterEditMode),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Widget _header(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }

  static Widget _item(BuildContext context, IconData icon, String label,
      {bool checked = false, required CalendarMenuAction action}) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final color = checked ? theme.colorScheme.primary : colors.secondaryText;
    return InkWell(
      onTap: () => Navigator.pop(context, action),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      color: checked ? theme.colorScheme.primary : null)),
            ),
            if (checked)
              Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
