/// 全库搜索界面（features/diary/presentation）——R-DIA-06
///
/// 圆角搜索框 + 取消；标题「全部日记本·已找到N项」；按月分组结果；
/// 条目脚注「日期 | 所属日记本」。全库搜索（跨所有日记本）。
library;

import 'dart:async';

import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/core/utils/date_utils.dart';
import 'package:flutter_application_2/data/models/notebook.dart';
import 'package:flutter_application_2/data/providers.dart';
import 'package:flutter_application_2/features/diary/presentation/diary_provider.dart';
import 'package:flutter_application_2/services/search_service.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _keyword = '';
  List<SearchGroup> _groups = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final kw = value.trim();
      final groups = kw.isEmpty
          ? const <SearchGroup>[]
          : SearchService.groupByMonth(
              await ref.read(entryRepositoryProvider).search(kw));
      if (mounted) {
        setState(() {
          _keyword = kw;
          _groups = groups;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final notebooks = ref.watch(notebooksProvider).value ?? const <Notebook>[];
    final nameOf = {for (final n in notebooks) n.id: n.name};
    final total = _groups.fold<int>(0, (s, g) => s + g.entries.length);

    return Scaffold(
      backgroundColor: colors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // 顶栏：圆角搜索框 + 取消
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: _onChanged,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: '搜索日记内容…',
                        hintStyle: TextStyle(fontSize: 14, color: colors.secondaryText),
                        prefixIcon: Icon(Icons.search, size: 20, color: colors.secondaryText),
                        filled: true,
                        fillColor: colors.card,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide(color: colors.border),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
            // 标题：全部日记本 · 已找到N项
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
              child: Row(
                children: [
                  Text(
                    _keyword.isEmpty
                        ? '全部日记本'
                        : '全部日记本·已找到$total项',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _keyword.isEmpty
                  ? Center(
                      child: Text('输入关键词搜索全部日记本',
                          style: TextStyle(color: colors.secondaryText)),
                    )
                  : _groups.isEmpty
                      ? Center(
                          child: Text('未找到相关内容',
                              style: TextStyle(color: colors.secondaryText)),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          children: [
                            for (final group in _groups) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  SearchService.monthLabel(group.monthKey),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: colors.secondaryText,
                                  ),
                                ),
                              ),
                              for (final e in group.entries)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.card,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.title.isEmpty ? '无标题' : e.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                      if (e.content.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            e.content,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: colors.secondaryText,
                                                height: 1.4),
                                          ),
                                        ),
                                      const SizedBox(height: 6),
                                      // 脚注：日期 | 所属日记本
                                      Text(
                                        '${DateUtils.shortDate(e.entryDate)} | ${nameOf[e.notebookId] ?? '未知日记本'}',
                                        style: TextStyle(
                                            fontSize: 11, color: colors.secondaryText),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
