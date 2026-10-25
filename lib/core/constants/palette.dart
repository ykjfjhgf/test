/// 全局色板（双套主题）——颜色唯一来源（core/constants）
///
/// 对应 docs/02-设计规格/设计总览.md 色板；组件禁止硬编码 hex。
library;

import 'package:flutter/material.dart';

class AppPalette {
  AppPalette._();

  /// 默认主题色（设置页可换，R-SET-02）
  static const String defaultThemeColorHex = '#0AA69A';

  /// 主题渐变（两主题共用）
  static const Color primaryGradientTop = Color(0xFF0FC6B0);
  static const Color primaryGradientBottom = Color(0xFF0A8F7F);
  static const Color primaryShadow = Color(0x5910A69A); // rgba(10,166,154,.35)

  // ---- 深色 ----
  static const Color darkPageBg = Color(0xFF101218);
  static const Color darkCard = Color(0xFF17191F);
  static const Color darkCardBright = Color(0xFF1E2129);
  static const Color darkBorder = Color(0xFF2B2F3A);
  static const Color darkImagePlaceholder = Color(0xFF242832);
  static const Color darkGrayCircle = Color(0xFF3A3F4C);
  static const Color darkSecondaryText = Color(0xFF8B93A3);
  static const Color darkHolidayRed = Color(0xFFF87171);
  static const Color darkWorkBlue = Color(0xFF7AA2FF);
  static const Color darkFestivalGreen = Color(0xFF34D399);

  // ---- 浅色 ----
  static const Color lightPageBg = Color(0xFFF2F4F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE3E8EF);
  static const Color lightImagePlaceholder = Color(0xFFEEF4FF);
  static const Color lightGrayCircle = Color(0xFFC7CED8);
  static const Color lightSecondaryText = Color(0xFF94A3B8);
  static const Color lightHolidayRed = Color(0xFFEF4444);
  static const Color lightWorkBlue = Color(0xFF2563EB);
  static const Color lightFestivalGreen = Color(0xFF059669);
}
