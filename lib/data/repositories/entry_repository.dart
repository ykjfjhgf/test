/// 日记仓储接口（数据层契约）
///
/// 由 data/datasources 下的实现（drift/SQLite）落地；
/// UI 与业务只依赖本接口（单向依赖，见 docs/03-项目工程/项目结构设计.md）。
/// 对应需求：R-DATA-02/05/06，R-CAL-07，R-EDI-02/08。
library;

import '../models/diary_entry.dart';

/// 日记排序方式（对应日记页更多菜单两种排序，R-DIA-05）
enum DiarySort {
  /// 按修改时间（默认选中项，✓）
  updatedAtDesc,

  /// 按创建时间
  createdAtDesc,
}

abstract interface class EntryRepository {
  /// 监听全部日记变化（跨功能域刷新用）
  Stream<List<DiaryEntry>> watchAll();

  /// 按日期取日记（日历页底部时间线面板，R-CAL-05）
  Future<List<DiaryEntry>> listByDate(DateTime date);

  /// 按日记本取日记（日记页卡片区，R-DIA-03）
  Future<List<DiaryEntry>> listByNotebook(String notebookId,
      {DiarySort sort = DiarySort.updatedAtDesc});

  /// 全库搜索（跨所有日记本，按月份分组由调用方处理，R-DIA-06）
  Future<List<DiaryEntry>> search(String keyword);

  /// 新建日记（R-EDI-08：日历入口默认保存到选中日期）
  Future<DiaryEntry> create(DiaryEntry entry);

  /// 更新（输入即自动保存，R-DATA-05）
  Future<void> update(DiaryEntry entry);

  /// 移动日记本（编辑器「⋯」菜单，R-EDI-01）
  Future<void> move(String entryId, String newNotebookId);

  /// 删除（编辑器「⋯」菜单）
  Future<void> delete(String entryId);

  /// 保存草稿（编辑器「⋯」菜单，R-EDI-01）
  Future<void> saveDraft(DiaryEntry draft);
}
