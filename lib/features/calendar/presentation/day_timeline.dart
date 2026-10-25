/// 今日时间线面板（features/calendar/presentation）——选中日日记列表
///
/// R-CAL-05：标题「今天/选中日 + 农历 + 今日日记·N篇」+ 时间线卡片
/// （9px 青绿圆点 + 1px 连线；图片占位 48×48；标题/预览/时间）。
library;

import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/core/constants/dimens.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/core/utils/date_utils.dart';
import 'package:flutter_application_2/data/models/diary_entry.dart';
import 'package:flutter_application_2/data/providers.dart';
import 'package:flutter_application_2/features/calendar/domain/calendar_data.dart';

/// 选中日日记列表（按时间倒序）
final calendarEntriesProvider = FutureProvider.autoDispose
    .family<List<DiaryEntry>, DateTime>((ref, date) async {
  return ref.watch(entryRepositoryProvider).listByDate(date);
});

class DayTimeline extends ConsumerWidget {
  final DateTime date;

  /// 时间轴显示开关（R-CAL-11）：关闭时隐藏竖线圆点，卡片伸长（全宽）
  final bool timelineVisible;

  const DayTimeline(
      {super.key, required this.date, this.timelineVisible = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    final entriesAsync = ref.watch(calendarEntriesProvider(date));
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final lunar = CalendarData.markFor(date)?.lunar ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(
            children: [
              Text(
                isToday ? '今天' : DateUtils.weekday(date),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isToday ? primary : colors.secondaryText,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                lunar.isEmpty
                    ? DateUtils.shortDate(date)
                    : '${DateUtils.shortDate(date)} 农历$lunar',
                style: TextStyle(fontSize: 13, color: colors.secondaryText),
              ),
              const Spacer(),
              entriesAsync.when(
                data: (entries) => Text(
                  '今日日记·${entries.length}篇',
                  style: TextStyle(fontSize: 12, color: colors.secondaryText),
                ),
                loading: () => Text('今日日记·…',
                    style: TextStyle(fontSize: 12, color: colors.secondaryText)),
                error: (_, _) => Text('今日日记·0篇',
                    style: TextStyle(fontSize: 12, color: colors.secondaryText)),
              ),
            ],
          ),
        ),
        Expanded(
          child: entriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Text('加载失败', style: TextStyle(color: colors.secondaryText)),
            ),
            data: (entries) {
              if (entries.isEmpty) {
                return Center(
                  child: Text('这一天还没有日记，点「+」开始记录',
                      style: TextStyle(color: colors.secondaryText)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                itemCount: entries.length,
                itemBuilder: (context, i) =>
                    _timelineItem(context, entries[i], i, entries.length),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _timelineItem(BuildContext context, DiaryEntry e, int index, int total) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final primary = Theme.of(context).colorScheme.primary;

    // v0.1.1（R-CAL-11）：时间轴关闭 → 无轴列，卡片全宽
    if (!timelineVisible) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _cardContent(context, e),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 时间线轴：9px 圆点 + 1px 连线
          SizedBox(
            width: 16,
            child: Column(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: primary),
                ),
                if (index < total - 1)
                  Expanded(child: Container(width: 1, color: colors.border)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _cardContent(context, e),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardContent(BuildContext context, DiaryEntry e) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: [
        if (e.images.isNotEmpty) ...[
          Container(
            width: AppDimens.timelineImagePlaceholder,
            height: AppDimens.timelineImagePlaceholder,
            decoration: BoxDecoration(
              color: colors.imagePlaceholder,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image_outlined, color: Colors.black26),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.title.isEmpty ? '无标题' : e.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              if (e.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    e.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 12, color: colors.secondaryText, height: 1.4),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                DateUtils.time(e.updatedAt),
                style: TextStyle(fontSize: 11, color: colors.secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
