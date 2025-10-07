import 'dart:convert';

class ProductDetail {
  final int id;
  final String title;
  final String content;
  final int displayOrder;
  final String isActive;
  ProductDetail({
    required this.id,
    required this.title,
    required this.content,
    required this.displayOrder,
    required this.isActive,
  });

  ProductDetail copyWith({
    int? id,
    String? title,
    String? content,
    int? displayOrder,
    String? isActive,
  }) {
    return ProductDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'title': title});
    result.addAll({'content': content});
    result.addAll({'displayOrder': displayOrder});
    result.addAll({'isActive': isActive});

    return result;
  }

  factory ProductDetail.fromMap(Map<String, dynamic> map) {
    return ProductDetail(
      id: map['id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      displayOrder: map['displayOrder']?.toInt() ?? 0,
      isActive: map['isActive'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductDetail.fromJson(String source) =>
      ProductDetail.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ProductDetail(id: $id, title: $title, content: $content, displayOrder: $displayOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductDetail &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.displayOrder == displayOrder &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        content.hashCode ^
        displayOrder.hashCode ^
        isActive.hashCode;
  }
}
