/// 设置仓储接口（数据层契约）
///
/// 持久化 AppSettings（主题模式/主题色/锁定时长/编辑器偏好）。
/// 实现落 data/datasources；主题系统与设置页读取。对应需求：R-SET-*。
library;

import '../models/app_settings.dart';

abstract interface class SettingsRepository {
  /// 加载设置（启动时调用；无记录时返回 AppSettings.defaults）
  Future<AppSettings> load();

  /// 保存设置（设置页任何变更即保存）
  Future<void> save(AppSettings settings);

  /// 监听设置变化（主题切换即时生效，R-SET-01/02）
  Stream<AppSettings> watch();
}
