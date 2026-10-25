/// 日记页（features/diary/presentation）——顶栏 + 选择条 + 卡片区
///
/// R-DIA-01 顶栏（大标题+「N本·M篇」+搜索/更多圆钮）；R-DIA-02 选择条；
/// R-DIA-03/04 卡片宫格/列表；R-DIA-05 更多菜单；R-DIA-06 搜索入口；
/// Dock 由 HomeShell 提供（仅「+」，R-DIA-07）。
library;

import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/core/providers/app_tab_provider.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/core/widgets/round_button.dart';
import 'package:flutter_application_2/data/models/diary_entry.dart';
import 'package:flutter_application_2/data/providers.dart';
import 'package:flutter_application_2/data/repositories/entry_repository.dart';
import 'package:flutter_application_2/features/diary/domain/diary_state.dart';
import 'package:flutter_application_2/features/diary/presentation/diary_provider.dart';
import 'package:flutter_application_2/features/diary/presentation/more_menu.dart';
import 'package:flutter_application_2/features/diary/presentation/notebook_bar.dart';
import 'package:flutter_application_2/features/diary/presentation/note_grid.dart';
import 'package:flutter_application_2/features/diary/presentation/search_page.dart';

/// 当前日记本条目（按排序）
final diaryEntriesProvider = FutureProvider.autoDispose
    .family<List<DiaryEntry>, (String, DiarySort)>((ref, args) {
  final (notebookId, sort) = args;
  return ref.watch(entryRepositoryProvider).listByNotebook(notebookId, sort: sort);
});

class DiaryPage extends ConsumerWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final notebooks = ref.watch(notebooksProvider).value ?? const [];
    final allEntries = ref.watch(allEntriesProvider).value ?? const <DiaryEntry>[];
    final state = ref.watch(diaryProvider);

    final currentId = state.currentNotebookId;
    final entriesAsync = currentId == null
        ? null
        : ref.watch(diaryEntriesProvider((currentId, state.sort)));

    return Column(
      children: [
        // 顶栏（R-DIA-01）
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 4),
          child: Row(
            children: [
              const Text('日记本',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Text(
                '${notebooks.length}本 · ${allEntries.length}篇',
                style: TextStyle(fontSize: 13, color: colors.secondaryText),
              ),
              const Spacer(),
              // v0.1.1（R-DIA-01 改）：右上角搜索/更多=表面色圆钮（对齐参考图白底图标）
              RoundButton(
                variant: RoundButtonVariant.surface,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                ),
                child: Icon(Icons.search,
                    color: Theme.of(context).colorScheme.onSurface, size: 20),
              ),
              const SizedBox(width: 8),
              RoundButton(
                variant: RoundButtonVariant.surface,
                onTap: () => _openMore(context, ref, state, notebooks.length),
                child: Icon(Icons.more_horiz,
                    color: Theme.of(context).colorScheme.onSurface, size: 22),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const NotebookBar(),
        // 卡片区（R-DIA-03/04）
        Expanded(
          child: entriesAsync == null
              ? Center(
                  child: Text('暂无日记本，点击「＋ 新建日记本」开始',
                      style: TextStyle(color: colors.secondaryText)),
                )
              : entriesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(
                      child: Text('加载失败', style: TextStyle(color: colors.secondaryText))),
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Center(
                        child: Text('这本日记本还没有内容',
                            style: TextStyle(color: colors.secondaryText)),
                      );
                    }
                    return state.viewMode == DiaryViewMode.grid
                        ? NoteGrid(entries: entries, onOpen: (e) => _openEntry(context, ref, e))
                        : NoteList(entries: entries, onOpen: (e) => _openEntry(context, ref, e));
                  },
                ),
        ),
      ],
    );
  }

  void _openMore(BuildContext context, WidgetRef ref, DiaryState state, int count) async {
    final action = await MoreMenu.show(context, state, count);
    if (!context.mounted || action == null) return;
    switch (action) {
      case DiaryMenuAction.toggleView:
        ref.read(diaryProvider.notifier).setViewMode(
            state.viewMode == DiaryViewMode.grid ? DiaryViewMode.list : DiaryViewMode.grid);
      case DiaryMenuAction.settings:
        ref.read(appTabProvider.notifier).set(AppTab.settings);
      case DiaryMenuAction.sortByCreated:
        ref.read(diaryProvider.notifier).setSort(DiarySort.createdAtDesc);
      case DiaryMenuAction.sortByUpdated:
        ref.read(diaryProvider.notifier).setSort(DiarySort.updatedAtDesc);
      case DiaryMenuAction.setPrivate:
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('私密设置请在「设置 → 隐私与安全」中配置')));
    }
  }

  void _openEntry(BuildContext context, WidgetRef ref, DiaryEntry e) {
    // 打开编辑器（编辑既有条目）——由编辑器页接收 entryId
    Navigator.pushNamed(context, '/editor', arguments: {'entryId': e.id});
  }
}
