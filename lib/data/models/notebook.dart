/// 日记本实体（对应需求 R-DATA-03）
///
/// 一个日记本 = 名称 + 封面色 + 私密（密码本）。
/// 日记页选择条 / 编辑器隐藏式拖动栏 / 设置页「日记本管理」均以本实体为数据源。
class Notebook {
  /// 唯一 ID
  final String id;

  /// 名称，如「工作日志」「生活随笔」
  final String name;

  /// 封面色 hex（如 '#0AA69A'），新建日记本时可选（R-SET-03）
  final String coverColorHex;

  /// 是否私密（密码本，R-DATA-04）
  final bool isPrivate;

  /// 私密本密码哈希；非私密本为 null
  final String? passwordHash;

  final DateTime createdAt;

  /// 排序权重（日记页选择条顺序）
  final int sortOrder;

  const Notebook({
    required this.id,
    required this.name,
    this.coverColorHex = '#0AA69A',
    this.isPrivate = false,
    this.passwordHash,
    required this.createdAt,
    this.sortOrder = 0,
  });

  Notebook copyWith({
    String? id,
    String? name,
    String? coverColorHex,
    bool? isPrivate,
    String? passwordHash,
    DateTime? createdAt,
    int? sortOrder,
  }) {
    return Notebook(
      id: id ?? this.id,
      name: name ?? this.name,
      coverColorHex: coverColorHex ?? this.coverColorHex,
      isPrivate: isPrivate ?? this.isPrivate,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory Notebook.fromJson(Map<String, dynamic> json) {
    return Notebook(
      id: json['id'] as String,
      name: json['name'] as String,
      coverColorHex: json['coverColorHex'] as String? ?? '#0AA69A',
      isPrivate: json['isPrivate'] as bool? ?? false,
      passwordHash: json['passwordHash'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coverColorHex': coverColorHex,
      'isPrivate': isPrivate,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
      'sortOrder': sortOrder,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notebook &&
        other.id == id &&
        other.name == name &&
        other.coverColorHex == coverColorHex &&
        other.isPrivate == isPrivate &&
        other.passwordHash == passwordHash &&
        other.createdAt == createdAt &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode => Object.hash(id, name, coverColorHex, isPrivate,
      passwordHash, createdAt, sortOrder);

  @override
  String toString() => 'Notebook(id: $id, name: "$name", '
      'isPrivate: $isPrivate, sortOrder: $sortOrder)';
}
