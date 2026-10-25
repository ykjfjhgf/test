/// 日历页状态（features/calendar/domain）——选中日 / 显示年月 / 折叠态 / 视图开关
///
/// 纯数据对象，presentation 的 Notifier 持有并变更；可单测。
/// v0.1.1 新增：时间轴显示开关（R-CAL-11）、多选编辑模式（R-CAL-12）。
library;

import 'package:flutter_application_2/core/utils/date_utils.dart';

class CalendarState {
  /// 选中日期（R-CAL-02 单选；「+」新建默认落点，R-CAL-07）
  final DateTime selectedDate;

  /// 当前显示的年月（翻页基准，R-CAL-01）
  final DateTime viewDate;

  /// 是否折叠为选中周周历（R-CAL-04）
  final bool isFolded;

  /// 是否显示时间线轴（R-CAL-11，v0.1.1）：关闭后列表伸长（无竖线圆点）
  final bool timelineVisible;

  /// 多选编辑模式（R-CAL-12，v0.1.1）：点击日期=勾选，可统一删除
  final bool editMode;

  /// 编辑模式已勾选日期（ISO yyyy-MM-dd 集合，v0.1.1）
  final Set<String> selectedDates;

  const CalendarState({
    required this.selectedDate,
    required this.viewDate,
    required this.isFolded,
    this.timelineVisible = true,
    this.editMode = false,
    this.selectedDates = const {},
  });

  factory CalendarState.initial(DateTime now) => CalendarState(
        selectedDate: now,
        viewDate: now,
        isFolded: false,
      );

  bool get isSelectedToday => DateUtils.isSameDay(selectedDate, DateTime.now());

  String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  CalendarState copyWith({
    DateTime? selectedDate,
    DateTime? viewDate,
    bool? isFolded,
    bool? timelineVisible,
    bool? editMode,
    Set<String>? selectedDates,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      viewDate: viewDate ?? this.viewDate,
      isFolded: isFolded ?? this.isFolded,
      timelineVisible: timelineVisible ?? this.timelineVisible,
      editMode: editMode ?? this.editMode,
      selectedDates: selectedDates ?? this.selectedDates,
    );
  }
}

/// 折叠手势判定（R-CAL-04）：上拉位移 >24px → 折叠；下拉 >24px → 复位
enum FoldAction { fold, unfold, none }

FoldAction foldAction(double dragDeltaY) {
  const threshold = 24;
  if (dragDeltaY > threshold) return FoldAction.unfold; // 下拉=拉长复位
  if (dragDeltaY < -threshold) return FoldAction.fold; // 上拉=收起
  return FoldAction.none;
}
