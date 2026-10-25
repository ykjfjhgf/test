/// 月历单格（features/calendar/presentation）——日期标记渲染
///
/// R-CAL-01/02/08（v0.1.1 更新）：
/// - 今天=主题色圆圈+白字；选中非今天=灰圈；单选
/// - 调休=数字下方 2px 灰实线；周末数字=主题色（不再固定红，R-CAL-01 改）
/// - 农历只显示"日"（如"初一"）；休/班/节日/节气角标颜色跟随主题色
/// - 编辑模式（R-CAL-12）：点击勾选，选中日=主题色圆+对勾
library;

import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_application_2/core/constants/dimens.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/core/utils/date_utils.dart';
import 'package:flutter_application_2/features/calendar/domain/calendar_data.dart';

class DateCell extends StatelessWidget {
  final DateTime date;
  final DateTime selectedDate;
  final bool inMonth;
  final bool editMode;
  final bool selectedForEdit;
  final VoidCallback onTap;

  const DateCell({
    super.key,
    required this.date,
    required this.selectedDate,
    required this.inMonth,
    this.editMode = false,
    this.selectedForEdit = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final primary = theme.colorScheme.primary;
    final today = DateTime.now();
    final isToday = DateUtils.isSameDay(date, today);
    final isSelected = DateUtils.isSameDay(date, selectedDate);
    final mark = CalendarData.markFor(date);
    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    // 数字颜色：今天/选中/编辑勾选=白；周末=主题色（v0.1.1）；本月=主文字；跨月=弱化
    final Color numColor;
    if (isToday || isSelected || selectedForEdit) {
      numColor = Colors.white;
    } else if (isWeekend) {
      numColor = primary;
    } else {
      numColor = inMonth
          ? theme.colorScheme.onSurface
          : colors.secondaryText.withValues(alpha: .45);
    }

    // 圆圈：今天/编辑勾选=主题色；选中非今天=灰圈
    final circleColor = (isToday || selectedForEdit)
        ? primary
        : (isSelected ? colors.grayCircle : Colors.transparent);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: AppDimens.calendarCellHeight,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 日期圆（含调休下划线 / 编辑勾选）
            SizedBox(
              height: AppDimens.dateCircle,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: AppDimens.dateCircle,
                    height: AppDimens.dateCircle,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: circleColor,
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 14,
                      color: numColor,
                      fontWeight:
                          isToday || isSelected || selectedForEdit ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (selectedForEdit)
                    const Positioned(
                      right: 2,
                      bottom: 1,
                      child: Icon(Icons.check_circle,
                          size: 9, color: Colors.white),
                    ),
                  // 调休标记：数字下方 2px 灰实线（R-CAL-02）
                  if (mark?.holidayWork ?? false)
                    Positioned(
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 2,
                        decoration: BoxDecoration(
                          color: colors.secondaryText,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 农历 8px（v0.1.1：只显示"日"，如"初一"）
            SizedBox(
              height: 11,
              child: Text(
                mark == null || mark.lunar == null
                    ? ''
                    : DateUtils.lunarDayOnly(mark.lunar!),
                style: TextStyle(fontSize: 8, color: colors.secondaryText),
              ),
            ),
            // 角标（休/班/节日/节气；颜色跟随主题色，v0.1.1）
            SizedBox(
              height: 10,
              child: mark?.label == null
                  ? null
                  : Text(
                      mark!.label!,
                      style: TextStyle(
                        fontSize: 8,
                        height: 1,
                        color: CalendarData.kindColor(context, mark.kind!),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
