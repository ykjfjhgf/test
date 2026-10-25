/// Dock 壳 Widget 测试：三页切换 / 圆钮按页差异（R-DOCK-04）/ 设置页左移淡出（R-SET-08）
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_2/app/app.dart';
import 'package:flutter_application_2/data/datasources/db.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';
import 'package:flutter_application_2/data/providers.dart';

Future<AppDatabase> _memoryDb() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  return db;
}

Widget _app(AppDatabase db) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: const DiaryApp(),
  );
}

void main() {
  testWidgets('默认日历页：Dock 三项 + 今/＋双圆钮（R-DOCK-04）', (tester) async {
    final db = await _memoryDb();
    await tester.pumpWidget(_app(db));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dock-日记')), findsOneWidget);
    expect(find.byKey(const ValueKey('dock-日历')), findsOneWidget);
    expect(find.byKey(const ValueKey('dock-设置')), findsOneWidget);
    expect(find.byKey(const ValueKey('btn-today')), findsOneWidget);
    expect(find.byKey(const ValueKey('btn-add')), findsOneWidget);
    await db.close();
  });

  testWidgets('切到日记页：只保留 ＋（R-DOCK-04）', (tester) async {
    final db = await _memoryDb();
    await tester.pumpWidget(_app(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('dock-日记')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('btn-today')), findsNothing);
    expect(find.byKey(const ValueKey('btn-add')), findsOneWidget);
    expect(find.text('日记本'), findsWidgets); // 日记页大标题（R-DIA-01）
    await db.close();
  });

  testWidgets('切到设置页：圆钮左移淡出（R-SET-08）', (tester) async {
    final db = await _memoryDb();
    await tester.pumpWidget(_app(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('dock-设置')));
    await tester.pumpAndSettle();

    // 圆钮内容已被 AnimatedSwitcher 移除
    expect(find.byKey(const ValueKey('btn-today')), findsNothing);
    expect(find.byKey(const ValueKey('btn-add')), findsNothing);
    expect(find.text('设置'), findsWidgets); // 设置页大标题（R-SET-08 顶栏）
    await db.close();
  });

  testWidgets('设置页返回日历：圆钮恢复', (tester) async {
    final db = await _memoryDb();
    await tester.pumpWidget(_app(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('dock-设置')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('dock-日历')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('btn-today')), findsOneWidget);
    expect(find.byKey(const ValueKey('btn-add')), findsOneWidget);
    await db.close();
  });

  testWidgets('设置页：点深色→持久化落盘（R-SET-01 实时性排查）', (tester) async {
    final db = await _memoryDb();
    await tester.pumpWidget(_app(db));
    await tester.pumpAndSettle();
    // 切设置页
    await tester.tap(find.byKey(const ValueKey('dock-设置')));
    await tester.pumpAndSettle();
    // 点深色段
    await tester.tap(find.text('深色'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    // 验证落盘
    final container = ProviderScope.containerOf(
        tester.element(find.byType(DiaryApp).first),
        listen: false);
    final loaded = await container.read(settingsRepositoryProvider).load();
    expect(loaded.themeMode, AppThemeMode.dark);
    await db.close();
  });
}
