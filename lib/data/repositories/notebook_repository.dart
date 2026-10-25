/// 日记本仓储接口（数据层契约）
///
/// 实现落 data/datasources；供日记页选择条、编辑器隐藏式拖动栏、
/// 设置页「日记本管理」共用。对应需求：R-DATA-03、R-DIA-02、R-SET-03。
library;

import '../models/notebook.dart';

abstract interface class NotebookRepository {
  /// 监听日记本列表变化（排序按 sortOrder，R-DIA-02）
  Stream<List<Notebook>> watchAll();

  /// 新建日记本（选择条「＋ 新建」/ 设置页「＋ 新建日记本」，R-SET-03）
  Future<Notebook> create(Notebook notebook);

  /// 更新（重命名 / 封面色 / 私密开关）
  Future<void> update(Notebook notebook);

  /// 删除（需同步处理归属日记，后续扩展）
  Future<void> delete(String id);
}
