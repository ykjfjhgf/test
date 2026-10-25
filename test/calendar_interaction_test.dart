/// 日历页交互测试：折叠手柄 tap 切换、选中日、翻月、Dock「今」跳转
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/app/app.dart';
import 'package:flutter_application_2/data/providers.dart';
import 'package:flutter_application_2/features/calendar/presentation/calendar_provider.dart';
import 'package:flutter_application_2/features/calendar/presentation/date_cell.dart';
import 'package:flutter_application_2/features/calendar/presentation/fold_handle.dart';

Future<void> pumpApp(WidgetTester tester) async {
  // 模拟手机屏幕，避免 800x600 测试窗口下日历 Column 溢出
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const ProviderScope(child: DiaryApp()));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('折叠手柄：点击收起为周历，再点展开（R-CAL-04）', (tester) async {
    await pumpApp(tester);
    // 初始月历应为 6 行（35 格：31 农历格 + 4 补位）
    expect(tester.widgetList(find.byType(DateCell)).length, greaterThan(30));

    await tester.tap(find.byType(FoldHandle));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.widgetList(find.byType(DateCell)).length, 7);

    await tester.tap(find.byType(FoldHandle));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.widgetList(find.byType(DateCell)).length, greaterThan(30));
  });

  testWidgets('月历左右滑动翻月（R-CAL-01 改，v0.1.1）', (tester) async {
    await pumpApp(tester);
    final before =
        tester.widget<Text>(find.textContaining('年').first).data!;
    // 向左滑动（下一页=下一月）；跨过视口一半以上确保翻页
    await tester.drag(find.byType(PageView).first, const Offset(-600, 0));
    await tester.pump(const Duration(milliseconds: 900));
    final after = tester.widget<Text>(find.textContaining('年').first).data!;
    expect(after, isNot(before));
  });

  // 注：R-CAL-10「更多菜单切周日」未在此做 widget 断言——widget 测试环境
  // drift watch 流不 emit（settingsProvider 恒 null），已在 v011_feature_test
  // 覆盖 firstWeekday 序列化/旧档回退，并在模拟器实机验证（db 落盘 + 网格首列=日）。

  testWidgets('Dock「今」跳回今天（R-CAL-07）', (tester) async {
    await pumpApp(tester);
    final container = ProviderScope.containerOf(
        tester.element(find.byType(DiaryApp).first),
        listen: false);
    container.read(calendarProvider.notifier).selectDate(DateTime(2026, 5, 1));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const ValueKey('btn-today')));
    await tester.pump(const Duration(milliseconds: 300));
    final st = container.read(calendarProvider);
    expect(st.selectedDate.month, DateTime.now().month);
  });
}
