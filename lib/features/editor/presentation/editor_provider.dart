/// 编辑器状态管理与 Provider（features/editor/presentation）
///
/// R-EDI-02 自动保存（防抖 300ms，输入即保存）；R-EDI-08 入口日期差异。
/// 路由参数：{ 'date': 'yyyy-MM-dd', 'entryId': id? }。
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/data/providers.dart';
import 'package:flutter_application_2/features/editor/domain/editor_state.dart';

/// 编辑器参数（来自路由）
class EditorArgs {
  final DateTime date;
  final String? entryId;

  const EditorArgs({required this.date, this.entryId});
}

final editorProvider =
    AsyncNotifierProvider<EditorNotifier, EditorState>(EditorNotifier.new);

class EditorNotifier extends AsyncNotifier<EditorState> {
  final EditorArgs args;

  EditorNotifier({EditorArgs? args})
      : args = args ?? EditorArgs(date: DateTime.now());

  Timer? _debounce;

  @override
  Future<EditorState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    final settings = await ref.watch(settingsRepositoryProvider).watch().first;
    final defaultNotebookId = settings.defaultNotebookId;

    // 编辑既有条目（日记页点开）
    if (args.entryId != null) {
      final all = await ref.watch(entryRepositoryProvider).watchAll().first;
      final entry = all.where((e) => e.id == args.entryId).firstOrNull;
      if (entry != null) {
        return EditorState(
          entryId: entry.id,
          notebookId: entry.notebookId,
          title: entry.title,
          content: entry.content,
          entryDate: entry.entryDate,
          images: entry.images,
          isDraft: entry.isDraft,
          lastSavedAt: entry.updatedAt,
        );
      }
    }

    // 新建：默认笔记本（设置 R-SET-05）或第一个笔记本
    final notebooks = await ref.watch(notebookRepositoryProvider).watchAll().first;
    final nbId = defaultNotebookId ?? (notebooks.isEmpty ? '' : notebooks.first.id);
    return EditorState(notebookId: nbId, entryDate: args.date);
  }

  /// 输入即自动保存（R-EDI-02）
  void onTitleChanged(String v) {
    state = AsyncData(state.requireValue.copyWith(title: v));
    _scheduleSave();
  }

  void onContentChanged(String v) {
    state = AsyncData(state.requireValue.copyWith(content: v));
    _scheduleSave();
  }

  void insertText(String v) {
    final s = state.requireValue;
    state = AsyncData(s.copyWith(content: s.content.isEmpty ? v : '${s.content}\n$v'));
    _scheduleSave();
  }

  /// 插入图片/涂鸦路径（v0.1.1 R-EDI-07 改）：追加 images 并在正文插入标记
  void addImages(List<String> paths) {
    if (paths.isEmpty) return;
    final s = state.requireValue;
    final images = [...s.images, ...paths];
    final marker = paths.length == 1 ? '[图片]' : '[图片]×${paths.length}';
    final content = s.content.isEmpty ? marker : '${s.content}\n$marker';
    state = AsyncData(s.copyWith(images: images, content: content));
    _scheduleSave();
  }

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), saveNow);
  }

  Future<void> saveNow() async {
    final s = state.requireValue;
    if (s.isEmpty) return; // 空内容不落库
    final repo = ref.read(entryRepositoryProvider);
    final now = DateTime.now();
    if (s.entryId == null) {
      final entry = s.toEntry('e-${now.microsecondsSinceEpoch}', createdAt: now);
      await repo.create(entry);
      state = AsyncData(s.copyWith(entryId: entry.id, lastSavedAt: now));
    } else {
      // 保留原 createdAt
      final all = await repo.watchAll().first;
      final old = all.where((e) => e.id == s.entryId).firstOrNull;
      final entry = s.toEntry(s.entryId!, createdAt: old?.createdAt ?? now);
      await repo.update(entry);
      state = AsyncData(s.copyWith(lastSavedAt: now));
    }
  }

  /// 换日记本（R-EDI-08：隐藏栏选择后自动保存归属）
  Future<void> moveTo(String notebookId) async {
    final s = state.requireValue;
    state = AsyncData(s.copyWith(notebookId: notebookId));
    if (s.entryId != null) {
      await ref.read(entryRepositoryProvider).move(s.entryId!, notebookId);
    } else {
      await saveNow();
    }
  }

  /// 保存草稿（R-EDI-01「⋯」菜单）
  Future<void> saveDraft() async {
    final s = state.requireValue;
    if (s.isEmpty) return;
    state = AsyncData(s.copyWith(isDraft: true));
    await saveNow();
  }

  /// 删除（R-EDI-01「⋯」菜单）
  Future<void> delete() async {
    final s = state.requireValue;
    if (s.entryId != null) {
      await ref.read(entryRepositoryProvider).delete(s.entryId!);
    }
  }
}
