/// 日记仓储的 drift 实现（数据层，对应 EntryRepository 接口）
///
/// 表结构见 data/datasources/db.dart；UI 只依赖接口，本实现可整体替换。
/// 对应需求：R-DATA-02/05/06、R-CAL-05/07、R-DIA-03/06、R-EDI-01/02/08。
library;

import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_application_2/data/datasources/db.dart';
import 'package:flutter_application_2/data/models/diary_entry.dart';
import 'package:flutter_application_2/data/repositories/entry_repository.dart';

class DriftEntryRepository implements EntryRepository {
  final AppDatabase _db;

  DriftEntryRepository(this._db);

  // ---- 模型 ⇄ 行 映射 ----

  DiaryEntry _toModel(DiaryEntryRow row) {
    return DiaryEntry(
      id: row.id,
      notebookId: row.notebookId,
      title: row.title,
      content: row.content,
      entryDate: row.entryDate,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      images: (jsonDecode(row.imagesJson) as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isPrivate: row.isPrivate,
      isDraft: row.isDraft,
    );
  }

  DiaryEntriesCompanion _toCompanion(DiaryEntry e) {
    return DiaryEntriesCompanion.insert(
      id: e.id,
      notebookId: e.notebookId,
      title: Value(e.title),
      content: Value(e.content),
      entryDate: e.entryDate,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      imagesJson: Value(jsonEncode(e.images)),
      isPrivate: Value(e.isPrivate),
      isDraft: Value(e.isDraft),
    );
  }

  // ---- 接口实现 ----

  @override
  Stream<List<DiaryEntry>> watchAll() {
    return (_db.select(_db.diaryEntries))
        .watch()
        .map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<List<DiaryEntry>> listByDate(DateTime date) async {
    // 当日 00:00 ~ 次日 00:00 区间
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final rows = await (_db.select(_db.diaryEntries)
          ..where((t) =>
              t.entryDate.isBiggerOrEqualValue(dayStart) &
              t.entryDate.isSmallerThanValue(dayEnd))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    return rows.map(_toModel).toList();
  }

  @override
  Future<List<DiaryEntry>> listByNotebook(
    String notebookId, {
    DiarySort sort = DiarySort.updatedAtDesc,
  }) async {
    final query = _db.select(_db.diaryEntries)
      ..where((t) => t.notebookId.equals(notebookId));
    switch (sort) {
      case DiarySort.updatedAtDesc:
        query.orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
      case DiarySort.createdAtDesc:
        query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    }
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  @override
  Future<List<DiaryEntry>> search(String keyword) async {
    if (keyword.trim().isEmpty) return const [];
    final pattern = '%${keyword.trim()}%';
    final rows = await (_db.select(_db.diaryEntries)
          ..where((t) =>
              t.title.like(pattern) | t.content.like(pattern) |
              t.notebookId.like(pattern))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    return rows.map(_toModel).toList();
  }

  @override
  Future<DiaryEntry> create(DiaryEntry entry) async {
    await _db.into(_db.diaryEntries).insert(_toCompanion(entry));
    return entry;
  }

  @override
  Future<void> update(DiaryEntry entry) async {
    await (_db.update(_db.diaryEntries)..where((t) => t.id.equals(entry.id)))
        .write(DiaryEntriesCompanion(
          notebookId: Value(entry.notebookId),
          title: Value(entry.title),
          content: Value(entry.content),
          entryDate: Value(entry.entryDate),
          updatedAt: Value(entry.updatedAt),
          imagesJson: Value(jsonEncode(entry.images)),
          isPrivate: Value(entry.isPrivate),
          isDraft: Value(entry.isDraft),
        ));
  }

  @override
  Future<void> move(String entryId, String newNotebookId) async {
    await (_db.update(_db.diaryEntries)..where((t) => t.id.equals(entryId)))
        .write(DiaryEntriesCompanion(
      notebookId: Value(newNotebookId),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> delete(String entryId) async {
    await (_db.delete(_db.diaryEntries)..where((t) => t.id.equals(entryId)))
        .go();
  }

  @override
  Future<void> saveDraft(DiaryEntry draft) async {
    await _db.into(_db.diaryEntries).insert(
          _toCompanion(draft.copyWith(isDraft: true)),
          mode: InsertMode.insertOrReplace,
        );
  }
}
