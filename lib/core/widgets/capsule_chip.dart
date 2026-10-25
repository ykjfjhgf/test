/// 通用胶囊组件（core/widgets）——日记页选择条 / 设置页分组 / 编辑器隐藏栏共用
///
/// 规格（R-DIA-02）：选中=青绿实线描边+浅青绿字；未选=灰描边+灰字；
/// `dashed: true` 表示「＋ 新建」虚线胶囊。
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';

class CapsuleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool dashed;
  final VoidCallback? onTap;

  const CapsuleChip({
    super.key,
    required this.label,
    this.selected = false,
    this.dashed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final primary = theme.colorScheme.primary;

    final Color borderColor;
    final Color textColor;
    if (dashed) {
      borderColor = colors.secondaryText.withValues(alpha: .7);
      textColor = colors.secondaryText;
    } else if (selected) {
      borderColor = primary;
      textColor = primary;
    } else {
      borderColor = colors.border;
      textColor = colors.secondaryText;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        // v0.1.1（R-DIA-02 改）：高度收紧，文本上下居中
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: dashed
              ? Border.all(color: borderColor, width: 1)
              : Border.all(color: borderColor, width: selected ? 1.6 : 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
