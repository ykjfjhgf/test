/// 应用设置实体（对应需求 R-SET-*）
///
/// 设置页所有可配置项的唯一来源；主题系统（core/theme）与 Dock 行为均读取本实体。
library;

/// 主题三选（R-SET-01）：深色 / 浅色 / 跟随系统
enum AppThemeMode { light, dark, system }

/// 锁定时长（R-SET-04）：离开后立即 / 1分钟 / 5分钟 / 关闭
enum LockTimeout { immediately, oneMinute, fiveMinutes, off }

/// 每周第一天（R-CAL-10，v0.1.1）：周一 / 周日
enum WeekStart { monday, sunday }

class AppSettings {
  /// 主题模式
  final AppThemeMode themeMode;

  /// 主题色 hex（如 '#0AA69A'），预设 6 色或自定义取色器写入（R-SET-02）
  final String themeColorHex;

  /// 私密本锁定时长
  final LockTimeout lockTimeout;

  /// 编辑器默认日记本（新日记落点，R-SET-05）
  final String? defaultNotebookId;

  /// 隐藏式日记本栏开关（R-SET-05），默认开
  final bool hiddenBarEnabled;

  /// 自动保存提示开关（R-SET-05），默认开
  final bool autoSaveHintEnabled;

  /// 私密本密码哈希（R-SET-04，SHA-256，不明文存储；未设置为 null）
  final String? privatePasswordHash;

  /// 每周第一天（R-CAL-10）：周一（默认）/ 周日
  final WeekStart firstWeekday;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.themeColorHex = '#0AA69A',
    this.lockTimeout = LockTimeout.immediately,
    this.defaultNotebookId,
    this.hiddenBarEnabled = true,
    this.autoSaveHintEnabled = true,
    this.privatePasswordHash,
    this.firstWeekday = WeekStart.monday,
  });

  /// 出厂默认设置
  static const AppSettings defaults = AppSettings();

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? themeColorHex,
    LockTimeout? lockTimeout,
    String? defaultNotebookId,
    bool clearDefaultNotebook = false,
    bool? hiddenBarEnabled,
    bool? autoSaveHintEnabled,
    String? privatePasswordHash,
    WeekStart? firstWeekday,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      themeColorHex: themeColorHex ?? this.themeColorHex,
      lockTimeout: lockTimeout ?? this.lockTimeout,
      defaultNotebookId:
          clearDefaultNotebook ? null : (defaultNotebookId ?? this.defaultNotebookId),
      hiddenBarEnabled: hiddenBarEnabled ?? this.hiddenBarEnabled,
      autoSaveHintEnabled: autoSaveHintEnabled ?? this.autoSaveHintEnabled,
      privatePasswordHash: privatePasswordHash ?? this.privatePasswordHash,
      firstWeekday: firstWeekday ?? this.firstWeekday,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: AppThemeMode.values.byName(json['themeMode'] as String? ?? 'system'),
      themeColorHex: json['themeColorHex'] as String? ?? '#0AA69A',
      lockTimeout: LockTimeout.values
          .byName(json['lockTimeout'] as String? ?? 'immediately'),
      defaultNotebookId: json['defaultNotebookId'] as String?,
      hiddenBarEnabled: json['hiddenBarEnabled'] as bool? ?? true,
      autoSaveHintEnabled: json['autoSaveHintEnabled'] as bool? ?? true,
      privatePasswordHash: json['privatePasswordHash'] as String?,
      firstWeekday: WeekStart.values
          .byName(json['firstWeekday'] as String? ?? 'monday'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'themeColorHex': themeColorHex,
      'lockTimeout': lockTimeout.name,
      'defaultNotebookId': defaultNotebookId,
      'hiddenBarEnabled': hiddenBarEnabled,
      'autoSaveHintEnabled': autoSaveHintEnabled,
      'privatePasswordHash': privatePasswordHash,
      'firstWeekday': firstWeekday.name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.themeColorHex == themeColorHex &&
        other.lockTimeout == lockTimeout &&
        other.defaultNotebookId == defaultNotebookId &&
        other.hiddenBarEnabled == hiddenBarEnabled &&
        other.autoSaveHintEnabled == autoSaveHintEnabled &&
        other.privatePasswordHash == privatePasswordHash &&
        other.firstWeekday == firstWeekday;
  }

  @override
  int get hashCode => Object.hash(themeMode, themeColorHex, lockTimeout,
      defaultNotebookId, hiddenBarEnabled, autoSaveHintEnabled, privatePasswordHash, firstWeekday);

  @override
  String toString() => 'AppSettings(themeMode: $themeMode, '
      'themeColorHex: $themeColorHex, lockTimeout: $lockTimeout)';
}
