/// 设置分组行（features/settings/presentation）——分组卡片内的一行
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';

class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroup({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.secondaryText),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) Divider(height: 1, color: colors.border),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 普通设置行（icon + 标题 + 尾部）
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;
  final Widget? trailingWidget;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 15)),
            ),
            if (trailingWidget != null)
              trailingWidget!
            else if (trailing != null)
              Row(
                children: [
                  Text(trailing!,
                      style: TextStyle(fontSize: 13, color: colors.secondaryText)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: colors.secondaryText),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
