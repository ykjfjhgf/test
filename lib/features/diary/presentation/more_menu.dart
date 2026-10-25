/// 更多菜单（features/diary/presentation）——R-DIA-05
///
/// 编辑 / 宫格模式(反显) / 设为私密 / 设置 / 分隔线 / 按创建时间排序 / 按修改时间排序(✓)。
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/data/repositories/entry_repository.dart';
import 'package:flutter_application_2/features/diary/domain/diary_state.dart';

class MoreMenu {
  MoreMenu._();

  /// 弹出底部菜单，返回用户选择
  static Future<DiaryMenuAction?> show(
      BuildContext context, DiaryState state, int notebookCount) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isGrid = state.viewMode == DiaryViewMode.grid;

    return showModalBottomSheet<DiaryMenuAction>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // v0.1.1 外观对齐
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _item(ctx, Icons.edit_outlined, '编辑'),
            _item(ctx, isGrid ? Icons.view_list_outlined : Icons.grid_view_outlined,
                isGrid ? '列表模式' : '宫格模式', value: DiaryMenuAction.toggleView),
            _item(ctx, Icons.lock_outline, '设为私密', value: DiaryMenuAction.setPrivate),
            _item(ctx, Icons.settings_outlined, '设置', value: DiaryMenuAction.settings),
            const Divider(height: 1),
            // v0.1.1（R-DIA-05 改）：排序两行无前置图标（对齐参考图），保留对勾
            _sortItem(ctx, '按创建时间排序',
                checked: state.sort == DiarySort.createdAtDesc,
                value: DiaryMenuAction.sortByCreated),
            _sortItem(ctx, '按修改时间排序',
                checked: state.sort == DiarySort.updatedAtDesc,
                value: DiaryMenuAction.sortByUpdated),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Widget _sortItem(BuildContext context, String label,
      {required bool checked, required DiaryMenuAction value}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 15,
                    color: checked ? theme.colorScheme.primary : null),
              ),
            ),
            if (checked)
              Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  static Widget _item(BuildContext context, IconData icon, String label,
      {DiaryMenuAction? value, bool checked = false}) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: checked ? Theme.of(context).colorScheme.primary : colors.secondaryText),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 15, color: checked ? Theme.of(context).colorScheme.primary : null)),
            ),
            if (checked)
              Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

/// 菜单动作
enum DiaryMenuAction { toggleView, setPrivate, settings, sortByCreated, sortByUpdated }
