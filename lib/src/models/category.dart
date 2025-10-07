import 'dart:convert';

class Category {
  final int id;
  final String categorycode;
  final String categoryname;
  final String description;
  final String isactive;
  final int displayorder;
  Category({
    required this.id,
    required this.categorycode,
    required this.categoryname,
    required this.description,
    required this.isactive,
    required this.displayorder,
  });

  Category copyWith({
    int? id,
    String? categorycode,
    String? categoryname,
    String? description,
    String? isactive,
    int? displayorder,
  }) {
    return Category(
      id: id ?? this.id,
      categorycode: categorycode ?? this.categorycode,
      categoryname: categoryname ?? this.categoryname,
      description: description ?? this.description,
      isactive: isactive ?? this.isactive,
      displayorder: displayorder ?? this.displayorder,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'categorycode': categorycode});
    result.addAll({'categoryname': categoryname});
    result.addAll({'description': description});
    result.addAll({'isactive': isactive});
    result.addAll({'displayorder': displayorder});

    return result;
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toInt() ?? 0,
      categorycode: map['categorycode'] ?? '',
      categoryname: map['categoryname'] ?? '',
      description: map['description'] ?? '',
      isactive: map['isactive'] ?? '',
      displayorder: map['displayorder']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Category(id: $id, categorycode: $categorycode, categoryname: $categoryname, description: $description, isactive: $isactive, displayorder: $displayorder)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.categorycode == categorycode &&
        other.categoryname == categoryname &&
        other.description == description &&
        other.isactive == isactive &&
        other.displayorder == displayorder;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        categorycode.hashCode ^
        categoryname.hashCode ^
        description.hashCode ^
        isactive.hashCode ^
        displayorder.hashCode;
  }
}
