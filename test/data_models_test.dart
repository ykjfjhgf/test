import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/data/models/diary_entry.dart';
import 'package:flutter_application_2/data/models/notebook.dart';
import 'package:flutter_application_2/data/models/app_settings.dart';
import 'package:flutter_application_2/data/repositories/entry_repository.dart';

void main() {
  group('DiaryEntry', () {
    final now = DateTime(2026, 10, 24, 15, 10, 0);

    test('fromJson/toJson 往返一致', () {
      final entry = DiaryEntry(
        id: 'e1',
        notebookId: 'nb1',
        title: '无标题',
        content: '哈哈\n第二行',
        entryDate: DateTime(2026, 10, 24),
        createdAt: now,
        updatedAt: now,
        images: const ['/img/a.png', '/img/b.png'],
        isPrivate: true,
      );
      final restored = DiaryEntry.fromJson(entry.toJson());
      expect(restored, equals(entry));
    });

    test('copyWith 只改指定字段', () {
      final entry = DiaryEntry(
        id: 'e1',
        notebookId: 'nb1',
        title: '旧标题',
        content: '旧正文',
        entryDate: DateTime(2026, 10, 24),
        createdAt: now,
        updatedAt: now,
      );
      final changed = entry.copyWith(title: '新标题');
      expect(changed.title, '新标题');
      expect(changed.id, 'e1');
      expect(changed.content, '旧正文');
    });

    test('withUpdatedAt 刷新自动保存时间戳 (R-DATA-05)', () {
      final entry = DiaryEntry(
        id: 'e1',
        notebookId: 'nb1',
        title: '',
        content: '正文',
        entryDate: DateTime(2026, 10, 24),
        createdAt: now,
        updatedAt: now,
      );
      final saved = entry.withUpdatedAt(DateTime(2026, 10, 24, 15, 12));
      expect(saved.updatedAt, DateTime(2026, 10, 24, 15, 12));
      expect(saved.createdAt, now);
      expect(entry.updatedAt, now, reason: '原对象不可变');
    });

    test('无图与空标题默认值', () {
      final entry = DiaryEntry(
        id: 'e1',
        notebookId: 'nb1',
        title: '',
        content: '',
        entryDate: DateTime(2026, 10, 24),
        createdAt: now,
        updatedAt: now,
      );
      expect(entry.images, isEmpty);
      expect(entry.isPrivate, isFalse);
      expect(entry.isDraft, isFalse);
    });
  });

  group('Notebook', () {
    final now = DateTime(2026, 10, 24);

    test('fromJson/toJson 往返一致', () {
      final nb = Notebook(
        id: 'nb1',
        name: '工作日志',
        coverColorHex: '#0AA69A',
        isPrivate: true,
        passwordHash: 'abc123',
        createdAt: now,
        sortOrder: 1,
      );
      final restored = Notebook.fromJson(nb.toJson());
      expect(restored, equals(nb));
    });

    test('默认封面色为主题色', () {
      final nb = Notebook(id: 'nb1', name: '生活随笔', createdAt: now);
      expect(nb.coverColorHex, '#0AA69A');
      expect(nb.isPrivate, isFalse);
      expect(nb.sortOrder, 0);
    });
  });

  group('AppSettings', () {
    test('出厂默认值 (R-SET-01/02/05)', () {
      const s = AppSettings.defaults;
      expect(s.themeMode, AppThemeMode.system);
      expect(s.themeColorHex, '#0AA69A');
      expect(s.lockTimeout, LockTimeout.immediately);
      expect(s.hiddenBarEnabled, isTrue);
      expect(s.autoSaveHintEnabled, isTrue);
      expect(s.defaultNotebookId, isNull);
    });

    test('fromJson/toJson 往返一致', () {
      const s = AppSettings(
        themeMode: AppThemeMode.dark,
        themeColorHex: '#2563EB',
        lockTimeout: LockTimeout.fiveMinutes,
        defaultNotebookId: 'nb2',
        hiddenBarEnabled: false,
        autoSaveHintEnabled: true,
      );
      final restored = AppSettings.fromJson(s.toJson());
      expect(restored, equals(s));
    });

    test('copyWith 清除默认日记本', () {
      const s = AppSettings(defaultNotebookId: 'nb1');
      final cleared = s.copyWith(clearDefaultNotebook: true);
      expect(cleared.defaultNotebookId, isNull);
    });
  });

  test('DiarySort 枚举含两种排序 (R-DIA-05)', () {
    expect(DiarySort.values, hasLength(2));
    expect(DiarySort.updatedAtDesc.index, 0);
    expect(DiarySort.createdAtDesc.index, 1);
  });
}
