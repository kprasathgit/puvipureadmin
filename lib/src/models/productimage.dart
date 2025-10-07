import 'dart:convert';

class ProductImage {
  final int id;
  final String imageurl;
  final int displayorder;
  final String isactive;
  ProductImage({
    required this.id,
    required this.imageurl,
    required this.displayorder,
    required this.isactive,
  });

  ProductImage copyWith({
    int? id,
    String? imageurl,
    int? displayorder,
    String? isactive,
  }) {
    return ProductImage(
      id: id ?? this.id,
      imageurl: imageurl ?? this.imageurl,
      displayorder: displayorder ?? this.displayorder,
      isactive: isactive ?? this.isactive,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'imageurl': imageurl});
    result.addAll({'displayorder': displayorder});
    result.addAll({'isactive': isactive});

    return result;
  }

  factory ProductImage.fromMap(Map<String, dynamic> map) {
    return ProductImage(
      id: map['id']?.toInt() ?? 0,
      imageurl: map['imageurl'] ?? '',
      displayorder: map['displayorder']?.toInt() ?? 0,
      isactive: map['isactive'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductImage.fromJson(String source) =>
      ProductImage.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ProductImage(id: $id, imageurl: $imageurl, displayorder: $displayorder, isactive: $isactive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductImage &&
        other.id == id &&
        other.imageurl == imageurl &&
        other.displayorder == displayorder &&
        other.isactive == isactive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        imageurl.hashCode ^
        displayorder.hashCode ^
        isactive.hashCode;
  }
}
