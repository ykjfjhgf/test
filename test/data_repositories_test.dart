/// 数据层集成测试：drift 仓储 CRUD / 查询 / 搜索 / 设置持久化
///
/// 使用 NativeDatabase.memory() 内存库；sqlite3 原生库由
/// pubspec 的 hooks 配置加载系统 winsqlite3.dll（无需 override）。
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_2/data/datasources/db.dart';
import 'package:flutter_application_2/data/datasources/drift_entry_repository.dart';
import 'package:flutter_application_2/data/datasources/drift_notebook_repository.dart';
import 'package:flutter_application_2/data/datasources/drift_settings_repository.dart';
import 'package:flutter_application_2/data/models/diary_entry.dart';
import 'package:flutter_application_2/data/models/notebook.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';
import 'package:flutter_application_2/data/repositories/entry_repository.dart';

void main() {
  late AppDatabase db;
  late DriftEntryRepository entries;
  late DriftNotebookRepository notebooks;
  late DriftSettingsRepository settings;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    entries = DriftEntryRepository(db);
    notebooks = DriftNotebookRepository(db);
    settings = DriftSettingsRepository(db);
  });

  tearDown(() => db.close());

  final now = DateTime(2026, 10, 24, 15, 10);

  group('NotebookRepository', () {
    test('新建/更新/列表（按 sortOrder 排序）', () async {
      await notebooks.create(Notebook(
          id: 'nb1', name: '工作日志', createdAt: now, sortOrder: 0));
      await notebooks.create(Notebook(
          id: 'nb2', name: '生活随笔', createdAt: now, sortOrder: 1));

      var list = await notebooks.watchAll().first;
      expect(list.map((n) => n.id).toList(), ['nb1', 'nb2']);

      await notebooks.update(Notebook(
          id: 'nb1',
          name: '工作日志V2',
          coverColorHex: '#2563EB',
          createdAt: now,
          sortOrder: 0));
      list = await notebooks.watchAll().first;
      expect(list.first.name, '工作日志V2');
      expect(list.first.coverColorHex, '#2563EB');
    });

    test('删除日记本', () async {
      await notebooks.create(
          Notebook(id: 'nb1', name: '临时', createdAt: now));
      await notebooks.delete('nb1');
      expect(await notebooks.watchAll().first, isEmpty);
    });
  });

  group('EntryRepository', () {
    DiaryEntry entry(String id,
        {String notebookId = 'nb1',
        String title = '',
        String content = '',
        DateTime? date,
        bool draft = false}) {
      return DiaryEntry(
        id: id,
        notebookId: notebookId,
        title: title,
        content: content,
        entryDate: date ?? DateTime(2026, 10, 24),
        createdAt: now,
        updatedAt: now,
        images: const ['/img/a.png'],
        isDraft: draft,
      );
    }

    test('按日期查询（R-CAL-05）', () async {
      await entries.create(entry('e1', date: DateTime(2026, 10, 24)));
      await entries.create(entry('e2', date: DateTime(2026, 10, 23)));

      final on24 = await entries.listByDate(DateTime(2026, 10, 24));
      expect(on24.map((e) => e.id), ['e1']);

      final on23 = await entries.listByDate(DateTime(2026, 10, 23));
      expect(on23.map((e) => e.id), ['e2']);
    });

    test('按日记本查询 + 排序（R-DIA-03/05）', () async {
      await entries.create(entry('e1', notebookId: 'nb1', content: '旧'));
      await entries.create(entry('e2', notebookId: 'nb1', content: '新'));
      await entries.create(entry('e3', notebookId: 'nb2', content: '别本'));

      await entries.update(entry('e1', notebookId: 'nb1')
          .withUpdatedAt(DateTime(2026, 10, 24, 8)));

      // e1 更新为 08:00，e2 保持 15:10 → 按修改时间倒序 e2 在前
      final byUpdated =
          await entries.listByNotebook('nb1', sort: DiarySort.updatedAtDesc);
      expect(byUpdated.first.id, 'e2');
      final byCreated =
          await entries.listByNotebook('nb1', sort: DiarySort.createdAtDesc);
      expect(byCreated.length, 2);
      expect((await entries.listByNotebook('nb2')).single.id, 'e3');
    });

    test('全库搜索（R-DIA-06）', () async {
      await entries.create(entry('e1', title: '湖边散步', content: '桂花开了'));
      await entries.create(entry('e2', title: '吃饭', content: '拌面不错'));
      await entries.create(
          entry('e3', notebookId: 'nb2', title: '无标题', content: '秋天，桂花'));

      final hit = await entries.search('桂花');
      expect(hit.map((e) => e.id).toSet(), {'e1', 'e3'});

      final byTitle = await entries.search('散步');
      expect(byTitle.single.id, 'e1');

      expect(await entries.search('  '), isEmpty);
    });

    test('更新/移动/删除/草稿（R-EDI-01/02）', () async {
      await entries.create(entry('e1'));
      await entries.update(entry('e1', content: '自动保存后的正文')
          .withUpdatedAt(DateTime(2026, 10, 24, 15, 12)));
      expect((await entries.listByNotebook('nb1')).first.content,
          '自动保存后的正文');

      await entries.move('e1', 'nb2');
      expect((await entries.listByNotebook('nb2')).single.id, 'e1');

      await entries.saveDraft(entry('e9', title: '草稿', draft: true));
      final draft = (await entries.watchAll().first)
          .firstWhere((e) => e.id == 'e9');
      expect(draft.isDraft, isTrue);

      await entries.delete('e1');
      expect(await entries.watchAll().first, hasLength(1));
    });
  });

  group('SettingsRepository', () {
    test('默认值 + 保存 + 重载（R-SET-*）', () async {
      expect(await settings.load(), AppSettings.defaults);

      const custom = AppSettings(
        themeMode: AppThemeMode.dark,
        themeColorHex: '#7C3AED',
        lockTimeout: LockTimeout.fiveMinutes,
        defaultNotebookId: 'nb1',
        hiddenBarEnabled: false,
      );
      await settings.save(custom);
      expect(await settings.load(), custom);

      // 覆盖（insertOrReplace）
      await settings.save(custom.copyWith(themeMode: AppThemeMode.light));
      expect((await settings.load()).themeMode, AppThemeMode.light);
    });

    test('watch 推送变化', () async {
      final sink = settings.watch().asBroadcastStream();
      final first = await sink.first;
      expect(first, AppSettings.defaults);
    });
  });
}
