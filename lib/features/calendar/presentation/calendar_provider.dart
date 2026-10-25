/// 日历页状态管理与 Provider（features/calendar/presentation）
///
/// 页面组件经本 Provider 订阅/操作：选中日、翻月、折叠、跳今天（R-CAL-01/02/04/07）。
/// v0.1.1：时间轴开关（R-CAL-11）、多选编辑删除（R-CAL-12）、翻页由 PageView 驱动。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/data/providers.dart';
import 'package:flutter_application_2/features/calendar/domain/calendar_state.dart';

/// 日历页状态（含折叠态）；跨页共享入口（Dock「今」圆钮经此跳转今天）
final calendarProvider =
    NotifierProvider<CalendarNotifier, CalendarState>(CalendarNotifier.new);

class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() => CalendarState.initial(DateTime.now());

  /// 点击格子选中（R-CAL-02：同一时刻仅一天）
  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// 编辑模式勾选/取消（R-CAL-12）：不进选中态
  void toggleSelectDate(DateTime date) {
    final key = state.dayKey(date);
    final next = Set<String>.from(state.selectedDates);
    if (!next.add(key)) next.remove(key);
    state = state.copyWith(selectedDates: next);
  }

  /// 「今」圆钮：回到今天（R-CAL-09 候选联动视图，本期只切选中日）
  void jumpToToday() {
    final now = DateTime.now();
    state = state.copyWith(selectedDate: now, viewDate: now);
  }

  /// 设置显示年月（PageView 翻页回调，v0.1.1）
  void setViewDate(DateTime d) => state = state.copyWith(viewDate: d);

  void fold() => state = state.copyWith(isFolded: true);

  void unfold() => state = state.copyWith(isFolded: false);

  void toggleFold() => state = state.copyWith(isFolded: !state.isFolded);

  /// 时间轴开关（R-CAL-11）
  void toggleTimeline() =>
      state = state.copyWith(timelineVisible: !state.timelineVisible);

  /// 进入/退出多选编辑模式（R-CAL-12）
  void toggleEditMode() {
    final next = !state.editMode;
    state = state.copyWith(
      editMode: next,
      selectedDates: next ? state.selectedDates : const {},
    );
  }

  /// 退出编辑模式并清空选择
  void exitEditMode() =>
      state = state.copyWith(editMode: false, selectedDates: const {});

  /// 批量删除选中日期的全部日记（R-CAL-12）
  Future<int> deleteSelected() async {
    final keys = state.selectedDates.toList();
    final repo = ref.read(entryRepositoryProvider);
    var deleted = 0;
    for (final key in keys) {
      final parts = key.split('-').map(int.parse).toList();
      final date = DateTime(parts[0], parts[1], parts[2]);
      final entries = await repo.listByDate(date);
      for (final e in entries) {
        await repo.delete(e.id);
        deleted++;
      }
    }
    exitEditMode();
    return deleted;
  }
}
