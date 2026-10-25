/// 折叠手柄（features/calendar/presentation）——月历与下方之间
///
/// R-CAL-04：左右细线 + 居中灰色短条（120×4）；
/// v0.1.1（R-CAL-09）：拖拽热区加大（整条 60px 区域均可拖），下方列表滚动优先。
/// 拖拽：上拉 → 折叠为周历；下拉 → 复位；点击 = 切换。缓动见 animations.dart。
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/constants/dimens.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';

class FoldHandle extends StatelessWidget {
  final bool isFolded;
  final VoidCallback onFold;
  final VoidCallback onUnfold;

  const FoldHandle({
    super.key,
    required this.isFolded,
    required this.onFold,
    required this.onUnfold,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // 整条手柄线均可命中（含透明区）
      onTap: isFolded ? onUnfold : onFold,
      onVerticalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v < -300) onFold(); // 上拉收起
        if (v > 300) onUnfold(); // 下拉复位
      },
      child: SizedBox(
        height: AppDimens.foldHandleHotArea, // 热区加大（R-CAL-09）
        child: Row(
          children: [
            Expanded(child: Container(height: 1, color: colors.border)),
            Container(
              width: AppDimens.gestureBarWidth,
              height: AppDimens.gestureBarHeight,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: colors.grayCircle,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Expanded(child: Container(height: 1, color: colors.border)),
          ],
        ),
      ),
    );
  }
}
