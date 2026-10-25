/// ＋菜单（features/editor/presentation）——R-EDI-06
///
/// 表格（可调行列）/ 拍摄 / 文件 / 涂鸦；由工具条「＋」触发。
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';

enum AddMenuAction { table, camera, file, sketch }

class AddMenu {
  AddMenu._();

  static Future<AddMenuAction?> show(BuildContext context) async {
    final colors = Theme.of(context).extension<AppColors>()!;

    return showModalBottomSheet<AddMenuAction>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _item(ctx, Icons.grid_on_outlined, '表格', AddMenuAction.table),
            _item(ctx, Icons.photo_camera_outlined, '拍摄', AddMenuAction.camera),
            _item(ctx, Icons.folder_outlined, '文件', AddMenuAction.file),
            _item(ctx, Icons.brush_outlined, '涂鸦', AddMenuAction.sketch),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Widget _item(BuildContext context, IconData icon, String label, AddMenuAction action) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      onTap: () => Navigator.pop(context, action),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.secondaryText),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
