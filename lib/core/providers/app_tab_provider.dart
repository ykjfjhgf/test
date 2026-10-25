/// 全局 Tab 状态（core/providers）——Dock 三页切换的跨页入口
///
/// 日记页菜单「设置」等跨页跳转经此切换（feature 间禁止互 import，走 core）。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTab { diary, calendar, settings }

class AppTabNotifier extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.calendar;

  void set(AppTab tab) => state = tab;
}

final appTabProvider =
    NotifierProvider<AppTabNotifier, AppTab>(AppTabNotifier.new);
