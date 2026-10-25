/// 设置页领域（features/settings/domain）——主题色预设 / 文案映射
///
/// R-SET-01/02：预设 6 色 + 自定义取色器；锁定时长四选文案（R-SET-04）。
library;

class SettingsDomain {
  SettingsDomain._();

  /// 预设主题色（R-SET-02：青绿 / 蓝 / 紫 / 橙 / 粉 / 彩虹）
  static const List<({String name, String hex})> presetColors = [
    (name: '青绿', hex: '#0AA69A'),
    (name: '蓝', hex: '#2563EB'),
    (name: '紫', hex: '#7C3AED'),
    (name: '橙', hex: '#EA580C'),
    (name: '粉', hex: '#DB2777'),
    (name: '彩虹', hex: '#8B5CF6'),
  ];

  /// 锁定时长文案（R-SET-04）
  static String lockTimeoutLabel(String name) => switch (name) {
        'immediately' => '离开后立即',
        'oneMinute' => '1分钟',
        'fiveMinutes' => '5分钟',
        _ => '关闭',
      };
}
