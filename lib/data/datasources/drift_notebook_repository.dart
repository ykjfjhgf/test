/// 日记本仓储的 drift 实现（数据层，对应 NotebookRepository 接口）
///
/// 对应需求：R-DATA-03、R-DIA-02、R-SET-03。
library;

import 'package:drift/drift.dart';
import 'package:flutter_application_2/data/datasources/db.dart';
import 'package:flutter_application_2/data/models/notebook.dart';
import 'package:flutter_application_2/data/repositories/notebook_repository.dart';

class DriftNotebookRepository implements NotebookRepository {
  final AppDatabase _db;

  DriftNotebookRepository(this._db);

  Notebook _toModel(NotebookRow row) {
    return Notebook(
      id: row.id,
      name: row.name,
      coverColorHex: row.coverColorHex,
      isPrivate: row.isPrivate,
      passwordHash: row.passwordHash,
      createdAt: row.createdAt,
      sortOrder: row.sortOrder,
    );
  }

  @override
  Stream<List<Notebook>> watchAll() {
    final query = _db.select(_db.notebooks)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<Notebook> create(Notebook notebook) async {
    await _db.into(_db.notebooks).insert(NotebooksCompanion.insert(
      id: notebook.id,
      name: notebook.name,
      coverColorHex: Value(notebook.coverColorHex),
      isPrivate: Value(notebook.isPrivate),
      passwordHash: Value(notebook.passwordHash),
      createdAt: notebook.createdAt,
      sortOrder: Value(notebook.sortOrder),
    ));
    return notebook;
  }

  @override
  Future<void> update(Notebook notebook) async {
    await (_db.update(_db.notebooks)..where((t) => t.id.equals(notebook.id)))
        .write(NotebooksCompanion(
      name: Value(notebook.name),
      coverColorHex: Value(notebook.coverColorHex),
      isPrivate: Value(notebook.isPrivate),
      passwordHash: Value(notebook.passwordHash),
      sortOrder: Value(notebook.sortOrder),
    ));
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.notebooks)..where((t) => t.id.equals(id))).go();
  }
}
