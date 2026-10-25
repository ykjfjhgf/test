/// 日历页（features/calendar/presentation）——头部 + 月历⇄周历 + 折叠手柄 + 时间线
///
/// R-CAL-01 头部（年月+第N周+⋯更多）；R-CAL-04 折叠（AnimatedSize 320ms）；
/// R-CAL-05 底部时间线；Dock 由 HomeShell 统一提供（今/＋，R-DOCK-04）。
/// v0.1.1：翻月箭头移除（改 PageView 滑动，R-CAL-01 改）；⋯更多菜单（R-CAL-08 改）；
/// 时间轴开关（R-CAL-11）；多选编辑删除（R-CAL-12）。
library;

import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/core/constants/animations.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/core/utils/date_utils.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';
import 'package:flutter_application_2/data/providers.dart';
import 'package:flutter_application_2/features/calendar/domain/calendar_state.dart';
import 'package:flutter_application_2/features/calendar/presentation/calendar_more_menu.dart';
import 'package:flutter_application_2/features/calendar/presentation/calendar_provider.dart';
import 'package:flutter_application_2/features/calendar/presentation/day_timeline.dart';
import 'package:flutter_application_2/features/calendar/presentation/fold_handle.dart';
import 'package:flutter_application_2/features/calendar/presentation/month_view.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final state = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);
    final settings = ref.watch(settingsProvider).value ?? AppSettings.defaults;
    final firstWeekday = settings.firstWeekday;

    return Column(
      children: [
        // 头部：年月 + 第N周 + ⋯更多（v0.1.1：无翻月箭头）
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 6),
          child: Row(
            children: [
              Text(
                DateUtils.monthLabel(state.viewDate),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              Text(
                '第${DateUtils.weekNumber(state.isFolded ? state.selectedDate : state.viewDate, first: firstWeekday)}周',
                style: TextStyle(fontSize: 13, color: colors.secondaryText),
              ),
              const Spacer(),
              _roundIcon(context, Icons.more_horiz, () => _openMore(context, ref, state, firstWeekday), key: const ValueKey('cal-more-btn')),
            ],
          ),
        ),
        // 月历 / 周历（折叠动画 + PageView 翻页）
        AnimatedSize(
          duration: AppAnimations.foldDuration,
          curve: AppAnimations.easeInOut,
          alignment: Alignment.topCenter,
          child: MonthView(
            viewDate: state.viewDate,
            selectedDate: state.selectedDate,
            isFolded: state.isFolded,
            firstWeekday: firstWeekday,
            editMode: state.editMode,
            selectedDates: state.selectedDates,
            onSelect: state.editMode ? notifier.toggleSelectDate : notifier.selectDate,
            onViewDateChanged: notifier.setViewDate,
          ),
        ),
        const SizedBox(height: 2),
        // 折叠手柄（热区加大，v0.1.1：月历与列表之间均可拖拽，列表滚动优先）
        FoldHandle(
          isFolded: state.isFolded,
          onFold: notifier.fold,
          onUnfold: notifier.unfold,
        ),
        // 编辑模式操作条（R-CAL-12）
        if (state.editMode) _editBar(context, ref, state),
        // 时间线面板（v0.1.1：可关时间轴）
        Expanded(
          child: DayTimeline(date: state.selectedDate, timelineVisible: state.timelineVisible),
        ),
      ],
    );
  }

  Widget _editBar(BuildContext context, WidgetRef ref, CalendarState state) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    final count = state.selectedDates.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: Row(
        children: [
          Text('已选 $count 天',
              style: TextStyle(fontSize: 13, color: colors.secondaryText)),
          const Spacer(),
          TextButton(
            onPressed: () =>
                ref.read(calendarProvider.notifier).exitEditMode(),
            child: const Text('取消'),
          ),
          const SizedBox(width: 4),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: count == 0 ? colors.grayCircle : primary,
              foregroundColor: Colors.white,
            ),
            onPressed: count == 0
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('删除所选日记？'),
                        content: Text('将删除选中的 $count 天里全部日记，不可恢复。'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('取消')),
                          FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('删除')),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      final n = await ref
                          .read(calendarProvider.notifier)
                          .deleteSelected();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('已删除 $n 篇日记')));
                      }
                    }
                  },
            child: Text(count == 0 ? '删除' : '删除($count)'),
          ),
        ],
      ),
    );
  }

  Future<void> _openMore(BuildContext context, WidgetRef ref, CalendarState state, WeekStart firstWeekday) async {
    final action = await CalendarMoreMenu.show(
        context, firstWeekday, state.timelineVisible);
    if (!context.mounted || action == null) return;
    final settings = ref.read(settingsProvider).value ?? AppSettings.defaults;
    final notifier = ref.read(calendarProvider.notifier);
    switch (action) {
      case CalendarMenuAction.setFirstMonday:
        await ref.read(settingsRepositoryProvider)
            .save(settings.copyWith(firstWeekday: WeekStart.monday));
      case CalendarMenuAction.setFirstSunday:
        await ref.read(settingsRepositoryProvider)
            .save(settings.copyWith(firstWeekday: WeekStart.sunday));
      case CalendarMenuAction.toggleTimeline:
        notifier.toggleTimeline();
      case CalendarMenuAction.enterEditMode:
        notifier.toggleEditMode();
    }
  }

  Widget _roundIcon(BuildContext context, IconData icon, VoidCallback onTap,
      {Key? key}) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      key: key,
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.card,
          border: Border.all(color: colors.border),
        ),
        child: Icon(icon, size: 20, color: colors.secondaryText),
      ),
    );
  }
}
