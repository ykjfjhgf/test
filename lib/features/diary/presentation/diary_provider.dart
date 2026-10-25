/// 日记页状态管理与 Provider（features/diary/presentation）
///
/// R-DIA-02 选择日记本、R-DIA-04 宫格/列表、R-DIA-05 排序。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/data/models/diary_entry.dart';
import 'package:flutter_application_2/data/models/notebook.dart';
import 'package:flutter_application_2/data/providers.dart';
import 'package:flutter_application_2/data/repositories/entry_repository.dart';
import 'package:flutter_application_2/features/diary/domain/diary_state.dart';

/// 日记本列表流（选择条 / 顶栏统计共用）
final notebooksProvider = StreamProvider<List<Notebook>>(
    (ref) => ref.watch(notebookRepositoryProvider).watchAll());

/// 全量日记流（顶栏「N篇」统计）
final allEntriesProvider = StreamProvider<List<DiaryEntry>>(
    (ref) => ref.watch(entryRepositoryProvider).watchAll());

final diaryProvider = NotifierProvider<DiaryNotifier, DiaryState>(DiaryNotifier.new);

class DiaryNotifier extends Notifier<DiaryState> {
  @override
  DiaryState build() {
    // 笔记本列表就绪后自动选中第一个（R-DIA-02）
    ref.listen(notebooksProvider, (_, next) {
      final ids = next.value?.map((n) => n.id).toList() ?? const <String>[];
      final current = state.currentNotebookId;
      if (current == null && ids.isNotEmpty) {
        selectNotebook(ids.first);
      }
    });
    return const DiaryState();
  }

  void selectNotebook(String id) {
    state = state.copyWith(currentNotebookId: id);
  }

  void setViewMode(DiaryViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void setSort(DiarySort sort) {
    state = state.copyWith(sort: sort);
  }
}
