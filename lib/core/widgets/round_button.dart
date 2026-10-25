/// 圆形按钮（core/widgets）——Dock 右侧「今」「+」与顶栏搜索/更多共用
///
/// 规格（R-DOCK-04）：44×44 圆形，主题渐变底 + 白色内容，主题色阴影。
/// v0.1.1：渐变顶色由主题色动态派生（跟随设置主题色，R-SET-02）；
/// 新增 `surface` 变体（浅底+边框，供顶栏辅助按钮，对齐参考图白底黑图标）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/dimens.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';

enum RoundButtonVariant { primary, surface }

class RoundButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final RoundButtonVariant variant;

  const RoundButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = AppDimens.roundButton,
    this.variant = RoundButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final primary = theme.colorScheme.primary;

    final BoxDecoration decoration;
    if (variant == RoundButtonVariant.surface) {
      // 表面色变体：卡片底色 + 边框，无渐变/阴影（顶栏辅助按钮，R-DIA-01 改）
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: colors.card,
        border: Border.all(color: colors.border),
      );
    } else {
      // 主变体：主题渐变（顶色=主题色提亮），跟随设置主题色
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(primary, Colors.white, 0.28)!, primary],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primaryShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: decoration,
        child: Center(child: child),
      ),
    );
  }
}
