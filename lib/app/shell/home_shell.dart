/// 主框架（app/shell）——Dock 胶囊栏 + 三页切换 + 圆钮过渡
///
/// Dock 规格见 docs/02-设计规格/设计总览.md：
/// - 胶囊栏全圆角 999px，三项 日记/日历/设置，选中=主题色（图标+文字），无底块
/// - 右侧圆钮 44×44 主题渐变+白内容；各页差异（R-DOCK-04）
/// - 进入设置页时圆钮向左平移并淡出 ≈300ms（R-SET-08）
/// v0.1.1：删除系统手势条（R-DOCK-06）；Dock 长度固定（R-DOCK-05）；
/// 圆钮渐变/选中态由主题色动态驱动（R-SET-02）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/core/constants/animations.dart';
import 'package:flutter_application_2/core/constants/dimens.dart';
import 'package:flutter_application_2/core/providers/app_tab_provider.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/core/widgets/round_button.dart';
import 'package:flutter_application_2/features/calendar/presentation/calendar_page.dart';
import 'package:flutter_application_2/features/calendar/presentation/calendar_provider.dart';
import 'package:flutter_application_2/features/diary/presentation/diary_page.dart';
import 'package:flutter_application_2/features/settings/presentation/settings_page.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final tab = ref.watch(appTabProvider);
    final circleHidden = tab == AppTab.settings;

    return Scaffold(
      backgroundColor: colors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: tab.index,
                children: const [
                  DiaryPage(),
                  CalendarPage(),
                  SettingsPage(),
                ],
              ),
            ),
            _DockPanel(
              tab: tab,
              circleHidden: circleHidden,
              onSwitch: (t) => ref.read(appTabProvider.notifier).set(t),
              onToday: () => ref.read(calendarProvider.notifier).jumpToToday(),
              onAdd: () => _openEditor(context, ref, tab),
            ),
          ],
        ),
      ),
    );
  }

  /// 「+」圆钮：日历页=保存到选中日期；日记页=今天（R-CAL-07 / R-EDI-08）
  void _openEditor(BuildContext context, WidgetRef ref, AppTab tab) {
    final date = tab == AppTab.calendar
        ? ref.read(calendarProvider).selectedDate
        : DateTime.now();
    Navigator.pushNamed(
      context,
      '/editor',
      arguments: {'date': date.toIso8601String()},
    );
  }
}

/// Dock 面板：胶囊栏（固定宽度）+ 右侧圆钮（含过渡动画）
class _DockPanel extends StatelessWidget {
  final AppTab tab;
  final bool circleHidden;
  final ValueChanged<AppTab> onSwitch;
  final VoidCallback onToday;
  final VoidCallback onAdd;

  const _DockPanel({
    required this.tab,
    required this.circleHidden,
    required this.onSwitch,
    required this.onToday,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    // v0.1.1（R-DOCK-05）：Dock 总宽度固定（胶囊栏固定宽+间距+圆钮宽），三页一致
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 胶囊栏（全圆角，固定宽度）
          Container(
            width: AppDimens.dockCapsuleWidth,
            decoration: BoxDecoration(
              color: colors.cardBright,
              borderRadius: BorderRadius.circular(AppDimens.dockRadius),
              border: Border.all(color: colors.border),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: Row(
              children: [
                _dockItem(context, AppTab.diary, '日记', Icons.book_outlined, onSwitch),
                _dockItem(context, AppTab.calendar, '日历', Icons.calendar_month_outlined, onSwitch),
                _dockItem(context, AppTab.settings, '设置', Icons.settings_outlined, onSwitch),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.dockCircleGap),
          // 右侧圆钮组（左移淡出过渡，R-SET-08；隐藏时仍占位，Dock 总宽不变）
          AnimatedSlide(
            offset: circleHidden ? const Offset(-3, 0) : Offset.zero,
            duration: AppAnimations.dockTransition,
            curve: AppAnimations.easeInOut,
            child: AnimatedOpacity(
              opacity: circleHidden ? 0 : 1,
              duration: AppAnimations.dockTransition,
              child: AnimatedSwitcher(
                duration: AppAnimations.dockTransition,
                child: _circlesFor(tab, onToday, onAdd),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dockItem(BuildContext context, AppTab target, String label, IconData icon,
      ValueChanged<AppTab> onSwitch) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final selected = tab == target;
    final color = selected ? theme.colorScheme.primary : colors.secondaryText;

    return Expanded(
      child: InkWell(
        key: ValueKey('dock-$label'),
        onTap: () => onSwitch(target),
        borderRadius: BorderRadius.circular(AppDimens.dockRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppDimens.dockIcon, color: color),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppDimens.dockLabel,
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circlesFor(AppTab tab, VoidCallback onToday, VoidCallback onAdd) {
    return switch (tab) {
      AppTab.calendar => Column(
          key: const ValueKey('circles-calendar'),
          mainAxisSize: MainAxisSize.min,
          children: [
            RoundButton(
              key: const ValueKey('btn-today'),
              onTap: onToday,
              child: const Text('今',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            const SizedBox(height: AppDimens.roundButtonGap),
            RoundButton(
              key: const ValueKey('btn-add'),
              onTap: onAdd,
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ],
        ),
      AppTab.diary => Column(
          key: const ValueKey('circles-diary'),
          mainAxisSize: MainAxisSize.min,
          children: [
            RoundButton(
              key: const ValueKey('btn-add'),
              onTap: onAdd,
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ],
        ),
      AppTab.settings => const SizedBox(key: ValueKey('circles-settings')),
    };
  }
}
