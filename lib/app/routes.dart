/// 路由集中注册（app/routes）——名称常量，页面一律经路由进入
library;

abstract final class AppRoutes {
  /// 主框架（Dock + 三页）
  static const String home = '/';

  /// 编辑器页（参数：{ 'date': iso, 'entryId': id? }，R-EDI-08）
  static const String editor = '/editor';
}
