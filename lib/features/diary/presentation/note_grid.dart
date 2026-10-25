/// 宫格/列表布局（features/diary/presentation）——卡片展示容器
///
/// R-DIA-04：宫格=两列瀑布流（按累计高度平衡左右列）；列表=单列。
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/data/models/diary_entry.dart';
import 'package:flutter_application_2/features/diary/presentation/note_card.dart';

/// 两列瀑布流（R-DIA-04 宫格模式）
class NoteGrid extends StatelessWidget {
  final List<DiaryEntry> entries;
  final ValueChanged<DiaryEntry> onOpen;

  const NoteGrid({super.key, required this.entries, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final left = <Widget>[];
    final right = <Widget>[];
    // 简单高度平衡：按索引估算卡片高度（有预览的卡片更高）
    var leftH = 0.0;
    var rightH = 0.0;
    for (final e in entries) {
      final h = 96.0 + (e.content.isEmpty ? 0 : 44.0);
      if (leftH <= rightH) {
        left.add(NoteCard(entry: e, onTap: () => onOpen(e)));
        leftH += h;
      } else {
        right.add(NoteCard(entry: e, onTap: () => onOpen(e)));
        rightH += h;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: _withGaps(left))),
          const SizedBox(width: 10),
          Expanded(child: Column(children: _withGaps(right))),
        ],
      ),
    );
  }

  List<Widget> _withGaps(List<Widget> items) {
    return [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(height: 10),
        items[i],
      ],
    ];
  }
}

/// 单列列表（R-DIA-04 列表模式）
class NoteList extends StatelessWidget {
  final List<DiaryEntry> entries;
  final ValueChanged<DiaryEntry> onOpen;

  const NoteList({super.key, required this.entries, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => NoteCard(entry: entries[i], onTap: () => onOpen(entries[i])),
    );
  }
}
