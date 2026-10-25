/// 主题系统（core/theme）——由 AppSettings 动态生成 ThemeData
///
/// 对应需求 R-SET-01（深/浅/跟随系统）与 R-SET-02（主题色可控，全 App 统一生效）。
/// 组件统一通过 `Theme.of(context).extension<AppColors>()` 读取双套色板。
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/palette.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';

/// 双套主题的业务色板（通过 ThemeExtension 注入，组件可读）
class AppColors extends ThemeExtension<AppColors> {
  final Color pageBg;
  final Color card;
  final Color cardBright;
  final Color border;
  final Color imagePlaceholder;
  final Color grayCircle;
  final Color secondaryText;
  final Color holidayRed;
  final Color workBlue;
  final Color festivalGreen;
  final Color primaryShadow;

  const AppColors({
    required this.pageBg,
    required this.card,
    required this.cardBright,
    required this.border,
    required this.imagePlaceholder,
    required this.grayCircle,
    required this.secondaryText,
    required this.holidayRed,
    required this.workBlue,
    required this.festivalGreen,
    required this.primaryShadow,
  });

  static const AppColors dark = AppColors(
    pageBg: AppPalette.darkPageBg,
    card: AppPalette.darkCard,
    cardBright: AppPalette.darkCardBright,
    border: AppPalette.darkBorder,
    imagePlaceholder: AppPalette.darkImagePlaceholder,
    grayCircle: AppPalette.darkGrayCircle,
    secondaryText: AppPalette.darkSecondaryText,
    holidayRed: AppPalette.darkHolidayRed,
    workBlue: AppPalette.darkWorkBlue,
    festivalGreen: AppPalette.darkFestivalGreen,
    primaryShadow: AppPalette.primaryShadow,
  );

  static const AppColors light = AppColors(
    pageBg: AppPalette.lightPageBg,
    card: AppPalette.lightCard,
    cardBright: AppPalette.lightCard,
    border: AppPalette.lightBorder,
    imagePlaceholder: AppPalette.lightImagePlaceholder,
    grayCircle: AppPalette.lightGrayCircle,
    secondaryText: AppPalette.lightSecondaryText,
    holidayRed: AppPalette.lightHolidayRed,
    workBlue: AppPalette.lightWorkBlue,
    festivalGreen: AppPalette.lightFestivalGreen,
    primaryShadow: AppPalette.primaryShadow,
  );

  @override
  AppColors copyWith({
    Color? pageBg,
    Color? card,
    Color? cardBright,
    Color? border,
    Color? imagePlaceholder,
    Color? grayCircle,
    Color? secondaryText,
    Color? holidayRed,
    Color? workBlue,
    Color? festivalGreen,
    Color? primaryShadow,
  }) {
    return AppColors(
      pageBg: pageBg ?? this.pageBg,
      card: card ?? this.card,
      cardBright: cardBright ?? this.cardBright,
      border: border ?? this.border,
      imagePlaceholder: imagePlaceholder ?? this.imagePlaceholder,
      grayCircle: grayCircle ?? this.grayCircle,
      secondaryText: secondaryText ?? this.secondaryText,
      holidayRed: holidayRed ?? this.holidayRed,
      workBlue: workBlue ?? this.workBlue,
      festivalGreen: festivalGreen ?? this.festivalGreen,
      primaryShadow: primaryShadow ?? this.primaryShadow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      pageBg: Color.lerp(pageBg, other.pageBg, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardBright: Color.lerp(cardBright, other.cardBright, t)!,
      border: Color.lerp(border, other.border, t)!,
      imagePlaceholder: Color.lerp(imagePlaceholder, other.imagePlaceholder, t)!,
      grayCircle: Color.lerp(grayCircle, other.grayCircle, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      holidayRed: Color.lerp(holidayRed, other.holidayRed, t)!,
      workBlue: Color.lerp(workBlue, other.workBlue, t)!,
      festivalGreen: Color.lerp(festivalGreen, other.festivalGreen, t)!,
      primaryShadow: Color.lerp(primaryShadow, other.primaryShadow, t)!,
    );
  }
}

/// 主题装配入口
class AppTheme {
  AppTheme._();

  /// hex 字符串 → Color；支持 '#0AA69A'（6位）与 8 位含透明度写法
  static Color colorFromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length != 6 && cleaned.length != 8) {
      return const Color(0xFF0AA69A);
    }
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return const Color(0xFF0AA69A);
    if (cleaned.length == 6) return Color(0xFF000000 | value);
    return Color(value);
  }

  /// 由设置解析主题色（R-SET-02）
  static Color primaryOf(AppSettings settings) =>
      colorFromHex(settings.themeColorHex);

  /// MaterialApp 的 themeMode（R-SET-01 三选）
  static ThemeMode themeModeOf(AppSettings settings) {
    return switch (settings.themeMode) {
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.system => ThemeMode.system,
    };
  }

  static ThemeData light(Color primary) =>
      _build(Brightness.light, primary, AppColors.light);

  static ThemeData dark(Color primary) =>
      _build(Brightness.dark, primary, AppColors.dark);

  static ThemeData _build(
      Brightness brightness, Color primary, AppColors colors) {
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
      ),
      scaffoldBackgroundColor:
          brightness == Brightness.dark ? AppPalette.darkPageBg : AppPalette.lightPageBg,
    );
    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[colors],
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
