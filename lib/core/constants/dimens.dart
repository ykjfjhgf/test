/// 关键尺寸常量（core/constants）——尺寸唯一来源
///
/// 对应 docs/02-设计规格/设计总览.md「关键尺寸」；禁止魔法数字。
library;

class AppDimens {
  AppDimens._();

  // Dock / 圆钮
  static const double dockRadius = 999;
  static const double dockIcon = 18;
  static const double dockLabel = 10;
  static const double roundButton = 44; // 「今」「+」直径
  static const double roundButtonGap = 8;
  static const double dockCircleGap = 44; // 胶囊栏与右侧按钮间距=一个图标宽
  static const double dockCapsuleWidth = 280; // 胶囊栏固定宽度（v0.1.1 R-DOCK-05：280+gap44+圆钮44≤屏宽393-边距40）
  static const double gestureBarWidth = 120;
  static const double gestureBarHeight = 4;
  static const double foldHandleHotArea = 56; // 折叠拖拽热区（v0.1.1 R-CAL-09）

  // 日历
  static const double calendarGridGap = 3;
  static const double calendarCellHeight = 50;
  static const double dateCircle = 22;
  static const double timelineImagePlaceholder = 48;

  // 通用
  static const double minTouchTarget = 44;
}
