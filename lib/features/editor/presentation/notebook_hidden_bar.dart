/// 隐藏式日记本拖动栏（features/editor/presentation）——R-EDI-04
///
/// 常态仅标题右角「📓 当前日记本」标签；在标题行/信息行区域**横向拖动**
/// → 胶囊行滑出（全部日记本）；选中后自动收起。
/// ⚠️ 用户明确否决滑轨/滑块/箭头样式（反例见讨论阶段附图）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/core/constants/animations.dart';
import 'package:flutter_application_2/core/widgets/capsule_chip.dart';
import 'package:flutter_application_2/data/models/notebook.dart';
import 'package:flutter_application_2/features/diary/presentation/diary_provider.dart';
import 'package:flutter_application_2/features/editor/presentation/editor_provider.dart';

/// 包裹标题/信息行区域的隐藏式拖动栏
class HiddenNotebookBar extends ConsumerStatefulWidget {
  final Widget child;

  const HiddenNotebookBar({super.key, required this.child});

  @override
  ConsumerState<HiddenNotebookBar> createState() => _HiddenNotebookBarState();
}

class _HiddenNotebookBarState extends ConsumerState<HiddenNotebookBar> {
  bool _expanded = false;
  double _dragDx = 0;

  void _onDragUpdate(DragUpdateDetails d) {
    _dragDx += d.delta.dx;
    // 横向位移 >12px 判定拖动展开（交互规格：阈值 12）
    if (!_expanded && _dragDx.abs() > AppAnimations.dragThreshold) {
      setState(() => _expanded = true);
    }
  }

  void _onDragEnd(DragEndDetails d) {
    _dragDx = 0;
    // 松手后保持展开，等待选中或点击收起（R-EDI-09 候选细化）
  }

  @override
  Widget build(BuildContext context) {
    final notebooks = ref.watch(notebooksProvider).value ?? const <Notebook>[];
    final editor = ref.watch(editorProvider).value;
    final currentId = editor?.notebookId ?? '';

    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onTap: () => setState(() => _expanded = !_expanded),
          child: widget.child,
        ),
        // 胶囊行滑出区域（AnimatedSize 缓动，无轨道容器）
        AnimatedSize(
          duration: AppAnimations.dockTransition,
          curve: AppAnimations.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final nb in notebooks) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CapsuleChip(
                            label: nb.name,
                            selected: nb.id == currentId,
                            onTap: () {
                              ref.read(editorProvider.notifier).moveTo(nb.id);
                              setState(() => _expanded = false);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
