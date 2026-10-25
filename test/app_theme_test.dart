/// 主题系统单元测试：hex 解析 / 双套生成 / 设置驱动（R-SET-01/02）
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_2/core/constants/palette.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';

void main() {
  group('colorFromHex', () {
    test('带 # 六位 hex 解析', () {
      expect(AppTheme.colorFromHex('#0AA69A'), const Color(0xFF0AA69A));
    });

    test('不带 # 解析', () {
      expect(AppTheme.colorFromHex('2563EB'), const Color(0xFF2563EB));
    });

    test('非法输入回退主题色', () {
      expect(AppTheme.colorFromHex('xyz'), const Color(0xFF0AA69A));
      expect(AppTheme.colorFromHex('#12'), const Color(0xFF0AA69A));
    });
  });

  group('主题生成', () {
    test('深色 ThemeData 携带 AppColors 扩展', () {
      final theme = AppTheme.dark(const Color(0xFF0AA69A));
      expect(theme.brightness, Brightness.dark);
      final colors = theme.extension<AppColors>();
      expect(colors, isNotNull);
      expect(colors!.pageBg, AppPalette.darkPageBg);
    });

    test('浅色 ThemeData 携带 AppColors 扩展', () {
      final theme = AppTheme.light(const Color(0xFF0AA69A));
      expect(theme.brightness, Brightness.light);
      final colors = theme.extension<AppColors>();
      expect(colors, isNotNull);
      expect(colors!.pageBg, AppPalette.lightPageBg);
    });

    test('自定义主题色驱动 ColorScheme（R-SET-02）', () {
      final purple = AppTheme.light(const Color(0xFF7C3AED)).colorScheme.primary;
      final teal = AppTheme.light(const Color(0xFF0AA69A)).colorScheme.primary;
      expect(purple, isNot(equals(teal)));
    });
  });

  group('设置驱动（R-SET-01/02）', () {
    test('主题模式三选映射', () {
      expect(AppTheme.themeModeOf(
          const AppSettings(themeMode: AppThemeMode.dark)), ThemeMode.dark);
      expect(AppTheme.themeModeOf(
          const AppSettings(themeMode: AppThemeMode.light)), ThemeMode.light);
      expect(AppTheme.themeModeOf(
          const AppSettings(themeMode: AppThemeMode.system)), ThemeMode.system);
    });

    test('主题色解析来自设置', () {
      expect(
          AppTheme.primaryOf(
              const AppSettings(themeColorHex: '#2563EB')),
          const Color(0xFF2563EB));
      expect(AppTheme.primaryOf(const AppSettings()), const Color(0xFF0AA69A));
    });
  });
}
