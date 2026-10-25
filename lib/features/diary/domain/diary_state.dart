/// 日记页状态（features/diary/domain）——当前日记本 / 视图模式 / 排序
///
/// 纯数据对象，由 presentation 的 Notifier 持有；排序对应 R-DIA-05 菜单。
library;

import 'package:flutter_application_2/data/repositories/entry_repository.dart';

enum DiaryViewMode { grid, list }

class DiaryState {
  /// 当前选中日记本 ID；null = 未选中（加载后自动选第一个，R-DIA-02）
  final String? currentNotebookId;

  /// 宫格 / 列表（R-DIA-04）
  final DiaryViewMode viewMode;

  /// 排序（R-DIA-05：默认修改时间）
  final DiarySort sort;

  const DiaryState({
    this.currentNotebookId,
    this.viewMode = DiaryViewMode.grid,
    this.sort = DiarySort.updatedAtDesc,
  });

  DiaryState copyWith({String? currentNotebookId, DiaryViewMode? viewMode, DiarySort? sort}) {
    return DiaryState(
      currentNotebookId: currentNotebookId ?? this.currentNotebookId,
      viewMode: viewMode ?? this.viewMode,
      sort: sort ?? this.sort,
    );
  }
}
