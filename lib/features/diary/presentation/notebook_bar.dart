/// 日记本选择条（features/diary/presentation）——横向滑动胶囊 + 新建
///
/// R-DIA-02：选中=青绿实线；未选=灰描边；末尾「＋ 新建日记本」虚线胶囊；
/// 新建流程（R-SET-03：命名/封面色/私密）由设置页承担，此处弹命名对话框。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/core/widgets/capsule_chip.dart';
import 'package:flutter_application_2/data/models/notebook.dart';
import 'package:flutter_application_2/data/providers.dart';
import 'package:flutter_application_2/features/diary/presentation/diary_provider.dart';

class NotebookBar extends ConsumerWidget {
  const NotebookBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebooks = ref.watch(notebooksProvider).value ?? const <Notebook>[];
    final diaryState = ref.watch(diaryProvider);

    return SizedBox(
      // v0.1.1（R-DIA-02 改）：高度收紧至 38，胶囊文字居中
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final nb in notebooks) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CapsuleChip(
                label: nb.name,
                selected: nb.id == diaryState.currentNotebookId,
                onTap: () => ref.read(diaryProvider.notifier).selectNotebook(nb.id),
              ),
            ),
          ],
          CapsuleChip(
            label: '＋ 新建日记本',
            dashed: true,
            onTap: () => _createNotebook(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _createNotebook(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建日记本'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '日记本名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    final repo = ref.read(notebookRepositoryProvider);
    final notebooks = await repo.watchAll().first;
    await repo.create(Notebook(
      id: 'nb-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      createdAt: DateTime.now(),
      sortOrder: notebooks.length,
    ));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已创建「$name」')));
    }
  }
}
