/// 月历/周历网格（features/calendar/presentation）——PageView 预渲染翻页
///
/// R-CAL-01/03：无边框、背景与页面同色、gap 3px、格高 50px。
/// R-CAL-04：折叠时只显示选中日所在周的单行（周历）。
/// v0.1.1（R-CAL-01 改 / R-CAL-10）：
/// - 月历 PageView 预渲染前后两月，左右滑动切换月（缓入=PageView 自带动画）；
/// - 周历预渲染前后两周，左右滑动切换周；
/// - 周首可切（周一/周日）。
library;

import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_application_2/core/constants/dimens.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/core/utils/date_utils.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';
import 'package:flutter_application_2/features/calendar/presentation/date_cell.dart';

class MonthView extends StatefulWidget {
  final DateTime viewDate;
  final DateTime selectedDate;
  final bool isFolded;
  final WeekStart firstWeekday;
  final bool editMode;
  final Set<String> selectedDates;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<DateTime> onViewDateChanged;

  const MonthView({
    super.key,
    required this.viewDate,
    required this.selectedDate,
    required this.isFolded,
    required this.firstWeekday,
    required this.editMode,
    required this.selectedDates,
    required this.onSelect,
    required this.onViewDateChanged,
  });

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  late final PageController _controller = PageController(initialPage: 1);
  late DateTime _viewDate = widget.viewDate;
  late DateTime _weekAnchor = DateUtils.weekStart(widget.selectedDate,
      first: widget.firstWeekday);

  @override
  void didUpdateWidget(MonthView old) {
    super.didUpdateWidget(old);
    // 外部 viewDate 变化（今/更多菜单）→ 重置基准回中间页
    if (!DateUtils.isSameDay(
        DateUtils.weekStart(_viewDate), DateUtils.weekStart(widget.viewDate))) {
      _viewDate = widget.viewDate;
      _controller.jumpToPage(1);
    }
    final anchor = DateUtils.weekStart(widget.selectedDate,
        first: widget.firstWeekday);
    if (!DateUtils.isSameDay(_weekAnchor, anchor)) {
      _weekAnchor = anchor;
      _controller.jumpToPage(1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMonthPage(int index) {
    if (index == 1) return;
    final delta = index - 1;
    _viewDate = DateTime(_viewDate.year, _viewDate.month + delta, 1);
    _controller.jumpToPage(1); // 跳回中间页，内容=新月份，视觉无跳变
    widget.onViewDateChanged(_viewDate);
  }

  void _onWeekPage(int index) {
    if (index == 1) return;
    final delta = index - 1;
    final newAnchor =
        DateTime(_weekAnchor.year, _weekAnchor.month, _weekAnchor.day + 7 * delta);
    _weekAnchor = newAnchor;
    _controller.jumpToPage(1);
    // 选中日跟随新周（保持原星期几），viewDate 同步
    final weekdayOffset = widget.selectedDate.weekday - newAnchor.weekday;
    final newSelected =
        DateTime(newAnchor.year, newAnchor.month, newAnchor.day + weekdayOffset);
    widget.onSelect(newSelected);
    widget.onViewDateChanged(newSelected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final names = widget.firstWeekday == WeekStart.monday
        ? const ['一', '二', '三', '四', '五', '六', '日']
        : const ['日', '一', '二', '三', '四', '五', '六'];

    return Column(
      children: [
        _weekdayRow(colors, names),
        const SizedBox(height: 4),
        SizedBox(
          height: widget.isFolded ? 50 : _monthHeight(),
          child: PageView.builder(
            controller: _controller,
            physics: const PageScrollPhysics(),
            onPageChanged: widget.isFolded ? _onWeekPage : _onMonthPage,
            itemCount: 3,
            itemBuilder: (context, index) {
              if (widget.isFolded) {
                final anchor = DateTime(
                    _weekAnchor.year, _weekAnchor.month, _weekAnchor.day + 7 * (index - 1));
                final dates = DateUtils.weekDates(anchor,
                    first: widget.firstWeekday);
                return _row(context, dates, inMonth: true);
              }
              final month =
                  DateTime(_viewDate.year, _viewDate.month + (index - 1), 1);
              final dates = DateUtils.gridDates(month.year, month.month,
                  first: widget.firstWeekday);
              return _grid(context, dates);
            },
          ),
        ),
      ],
    );
  }

  double _monthHeight() {
    final dates = DateUtils.gridDates(_viewDate.year, _viewDate.month,
        first: widget.firstWeekday);
    final rows = dates.length ~/ 7;
    return rows * 50 + (rows - 1) * AppDimens.calendarGridGap;
  }

  Widget _weekdayRow(AppColors colors, List<String> names) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: AppDimens.calendarGridGap),
          Expanded(
            child: Text(
              names[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: i >= 5 ? primary : colors.secondaryText,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _grid(BuildContext context, List<DateTime> dates) {
    final rows = dates.length ~/ 7;
    return Column(
      children: [
        for (var r = 0; r < rows; r++) ...[
          if (r > 0) const SizedBox(height: AppDimens.calendarGridGap),
          _row(context, dates.sublist(r * 7, r * 7 + 7), inMonth: false),
        ],
      ],
    );
  }

  Widget _row(BuildContext context, List<DateTime> dates, {required bool inMonth}) {
    return Row(
      children: [
        for (var c = 0; c < 7; c++) ...[
          if (c > 0) const SizedBox(width: AppDimens.calendarGridGap),
          Expanded(
            child: DateCell(
              date: dates[c],
              selectedDate: widget.selectedDate,
              inMonth: inMonth ||
                  (dates[c].year == _viewDate.year &&
                      dates[c].month == _viewDate.month),
              editMode: widget.editMode,
              selectedForEdit: widget.editMode &&
                  widget.selectedDates.contains(
                      '${dates[c].year}-${dates[c].month.toString().padLeft(2, '0')}-${dates[c].day.toString().padLeft(2, '0')}'),
              onTap: () => widget.onSelect(dates[c]),
            ),
          ),
        ],
      ],
    );
  }
}
