/// 动画时长与曲线（core/constants）——动效参数唯一来源
///
/// 对应 docs/02-设计规格/交互规格.md；禁止魔法时长。
library;

import 'package:flutter/animation.dart';

class AppAnimations {
  AppAnimations._();

  /// 月历⇄周历折叠缓动时长（R-CAL-04，300–350ms 取中）
  static const Duration foldDuration = Duration(milliseconds: 320);

  /// Dock 圆钮左移淡出过渡（R-SET-08）
  static const Duration dockTransition = Duration(milliseconds: 300);

  /// 通用缓动曲线
  static const Curve easeInOut = Curves.easeInOut;

  /// 拖动判定阈值（隐藏式拖动栏 / 折叠手柄，单位逻辑像素）
  static const double dragThreshold = 12;
  static const double foldDragThreshold = 24;
}
