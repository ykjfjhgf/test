/// 编辑器状态（features/editor/domain）——条目内容与自动保存时间戳
///
/// 纯数据对象；自动保存语义（R-EDI-02：输入即保存，无未保存态）。
library;

import 'package:flutter_application_2/data/models/diary_entry.dart';

class EditorState {
  final String? entryId;

  /// 归属日记本（编辑器可换，R-EDI-03/08）
  final String notebookId;

  final String title;
  final String content;
  final DateTime entryDate;
  final List<String> images;
  final bool isDraft;

  /// 最近一次自动保存时间（信息行「✓ 已自动保存 HH:mm」）
  final DateTime? lastSavedAt;

  const EditorState({
    this.entryId,
    required this.notebookId,
    this.title = '',
    this.content = '',
    required this.entryDate,
    this.images = const [],
    this.isDraft = false,
    this.lastSavedAt,
  });

  bool get isEmpty => title.trim().isEmpty && content.trim().isEmpty && images.isEmpty;

  EditorState copyWith({
    String? entryId,
    String? notebookId,
    String? title,
    String? content,
    DateTime? entryDate,
    List<String>? images,
    bool? isDraft,
    DateTime? lastSavedAt,
  }) {
    return EditorState(
      entryId: entryId ?? this.entryId,
      notebookId: notebookId ?? this.notebookId,
      title: title ?? this.title,
      content: content ?? this.content,
      entryDate: entryDate ?? this.entryDate,
      images: images ?? this.images,
      isDraft: isDraft ?? this.isDraft,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
    );
  }

  DiaryEntry toEntry(String id, {required DateTime createdAt}) => DiaryEntry(
        id: id,
        notebookId: notebookId,
        title: title.trim(),
        content: content.trimRight(),
        entryDate: entryDate,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        images: images,
        isDraft: isDraft,
      );
}
