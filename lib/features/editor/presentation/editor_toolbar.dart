/// 编辑器工具条（features/editor/presentation）——R-EDI-05（v0.1.1 R-EDI-11 改）
///
/// 紧凑居中的胶囊：图片（相册多选）/ 语音（系统录音）/ ＋添加（表格/拍摄/文件/涂鸦）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';

class EditorToolbar extends StatelessWidget {
  final VoidCallback onImage;
  final VoidCallback onVoice;
  final VoidCallback onAdd;

  const EditorToolbar({
    super.key,
    required this.onImage,
    required this.onVoice,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    Widget btn(IconData icon, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Icon(icon, size: 21, color: colors.secondaryText),
        ),
      );
    }

    // v0.1.1：紧凑居中——胶囊自适应宽度、居中排列、间距收窄
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Center(
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              btn(Icons.image_outlined, onImage),
              const SizedBox(width: 2),
              btn(Icons.mic_none, onVoice),
              const SizedBox(width: 2),
              btn(Icons.add, onAdd),
            ],
          ),
        ),
      ),
    );
  }
}
