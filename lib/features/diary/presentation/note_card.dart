/// 日记卡片（features/diary/presentation）——宫格/列表共用
///
/// R-DIA-03：首行 日期(10月24日·周六) ｜ 相对时间(1小时前) 两端对齐；
/// 标题「无标题」占位；预览=正文前几行（保留 emoji/换行）。
library;

import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/core/utils/date_utils.dart';
import 'package:flutter_application_2/data/models/diary_entry.dart';

class NoteCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final now = DateTime.now();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 首行：日期 ｜ 相对时间
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateUtils.shortDateWithWeekday(entry.entryDate),
                    style: TextStyle(fontSize: 12, color: colors.secondaryText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateUtils.relative(now, entry.updatedAt),
                  style: TextStyle(fontSize: 11, color: colors.secondaryText),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // 标题
            Text(
              entry.title.isEmpty ? '无标题' : entry.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: entry.title.isEmpty ? colors.secondaryText : null,
              ),
            ),
            // 预览（含图片提示）
            if (entry.content.isNotEmpty || entry.images.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                entry.content.isEmpty
                    ? '[${entry.images.length}张图片]'
                    : entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.secondaryText,
                  height: 1.4,
                ),
              ),
            ],
            if (entry.isDraft) ...[
              const SizedBox(height: 6),
              Text('草稿',
                  style: TextStyle(fontSize: 10, color: colors.festivalGreen)),
            ],
          ],
        ),
      ),
    );
  }
}
