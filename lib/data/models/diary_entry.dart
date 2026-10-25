/// 日记实体（对应需求 R-DATA-02）
///
/// 一条日记 = 标题 + 正文 + 所属日期 + 图片 + 归属日记本。
/// 纯数据对象，不依赖 Flutter / 数据库，可序列化为 JSON。
class DiaryEntry {
  /// 唯一 ID（生成器实现由仓储层决定，如 uuid）
  final String id;

  /// 所属日记本 ID（多日记本支持，R-DATA-03）
  final String notebookId;

  /// 标题；空字符串表示「无标题」占位
  final String title;

  /// 正文（富文本区域保存的文本内容）
  final String content;

  /// 日记所属日期（日历页按此日期展示，R-CAL-05/07）
  final DateTime entryDate;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// 本地图片文件路径列表（相册插入，R-EDI-05）
  final List<String> images;

  /// 私密标记（密码本，R-DATA-04）
  final bool isPrivate;

  /// 草稿标记（编辑器「保存草稿」，R-EDI-01）
  final bool isDraft;

  const DiaryEntry({
    required this.id,
    required this.notebookId,
    required this.title,
    required this.content,
    required this.entryDate,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
    this.isPrivate = false,
    this.isDraft = false,
  });

  /// 自动保存时间戳（R-DATA-05）：返回新的 updatedAt 实例
  DiaryEntry withUpdatedAt(DateTime now) => copyWith(updatedAt: now);

  DiaryEntry copyWith({
    String? id,
    String? notebookId,
    String? title,
    String? content,
    DateTime? entryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? images,
    bool? isPrivate,
    bool? isDraft,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      notebookId: notebookId ?? this.notebookId,
      title: title ?? this.title,
      content: content ?? this.content,
      entryDate: entryDate ?? this.entryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      isPrivate: isPrivate ?? this.isPrivate,
      isDraft: isDraft ?? this.isDraft,
    );
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      notebookId: json['notebookId'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      entryDate: DateTime.parse(json['entryDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      images: (json['images'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      isPrivate: json['isPrivate'] as bool? ?? false,
      isDraft: json['isDraft'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notebookId': notebookId,
      'title': title,
      'content': content,
      'entryDate': entryDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'images': images,
      'isPrivate': isPrivate,
      'isDraft': isDraft,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiaryEntry &&
        other.id == id &&
        other.notebookId == notebookId &&
        other.title == title &&
        other.content == content &&
        other.entryDate == entryDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isPrivate == isPrivate &&
        other.isDraft == isDraft &&
        _listEquals(other.images, images);
  }

  @override
  int get hashCode => Object.hash(id, notebookId, title, content, entryDate,
      createdAt, updatedAt, isPrivate, isDraft, Object.hashAll(images));

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() => 'DiaryEntry(id: $id, notebookId: $notebookId, '
      'title: "$title", entryDate: ${entryDate.toIso8601String()})';
}
