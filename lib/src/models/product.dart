import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;

import 'package:puvipureadmin/src/models/category.dart';
import 'package:puvipureadmin/src/models/productdetail.dart';
import 'package:puvipureadmin/src/models/productimage.dart';

class Product {
  final int id;
  final String procode;
  final String proname;
  final String description;
  final double price;
  final double priceqty;
  final String priceqtyunit;
  final double stockqty;
  final String imageurl;
  final String isactive;
  final int displayorder;
  final Category category;
  final String slug;
  final List<ProductImage> images;
  final List<ProductDetail> details;
  Product({
    required this.id,
    required this.procode,
    required this.proname,
    required this.description,
    required this.price,
    required this.priceqty,
    required this.priceqtyunit,
    required this.stockqty,
    required this.imageurl,
    required this.isactive,
    required this.displayorder,
    required this.category,
    required this.slug,
    required this.images,
    required this.details,
  });

  Product copyWith({
    int? id,
    String? procode,
    String? proname,
    String? description,
    double? price,
    double? priceqty,
    String? priceqtyunit,
    double? stockqty,
    String? imageurl,
    String? isactive,
    int? displayorder,
    Category? category,
    String? slug,
    List<ProductImage>? images,
    List<ProductDetail>? details,
  }) {
    return Product(
      id: id ?? this.id,
      procode: procode ?? this.procode,
      proname: proname ?? this.proname,
      description: description ?? this.description,
      price: price ?? this.price,
      priceqty: priceqty ?? this.priceqty,
      priceqtyunit: priceqtyunit ?? this.priceqtyunit,
      stockqty: stockqty ?? this.stockqty,
      imageurl: imageurl ?? this.imageurl,
      isactive: isactive ?? this.isactive,
      displayorder: displayorder ?? this.displayorder,
      category: category ?? this.category,
      slug: slug ?? this.slug,
      images: images ?? this.images,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'procode': procode});
    result.addAll({'proname': proname});
    result.addAll({'description': description});
    result.addAll({'price': price});
    result.addAll({'priceqty': priceqty});
    result.addAll({'priceqtyunit': priceqtyunit});
    result.addAll({'stockqty': stockqty});
    result.addAll({'imageurl': imageurl});
    result.addAll({'isactive': isactive});
    result.addAll({'displayorder': displayorder});
    result.addAll({'category': category.toMap()});
    result.addAll({'slug': slug});
    result.addAll({'images': images.map((x) => x.toMap()).toList()});
    result.addAll({'details': details.map((x) => x.toMap()).toList()});

    return result;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toInt() ?? 0,
      procode: map['procode'] ?? '',
      proname: map['proname'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      priceqty: map['priceqty']?.toDouble() ?? 0.0,
      priceqtyunit: map['priceqtyunit'] ?? '',
      stockqty: map['stockqty']?.toDouble() ?? 0.0,
      imageurl: map['imageurl'] ?? '',
      isactive: map['isactive'] ?? '',
      displayorder: map['displayorder']?.toInt() ?? 0,
      category: Category.fromMap(map['category']),
      slug: map['slug'] ?? '',
      images: List<ProductImage>.from(
        map['images']?.map((x) => ProductImage.fromMap(x)),
      ),
      details: List<ProductDetail>.from(
        map['details']?.map((x) => ProductDetail.fromMap(x)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Product(id: $id, procode: $procode, proname: $proname, description: $description, price: $price, priceqty: $priceqty, priceqtyunit: $priceqtyunit, stockqty: $stockqty, imageurl: $imageurl, isactive: $isactive, displayorder: $displayorder, category: $category, slug: $slug, images: $images, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.procode == procode &&
        other.proname == proname &&
        other.description == description &&
        other.price == price &&
        other.priceqty == priceqty &&
        other.priceqtyunit == priceqtyunit &&
        other.stockqty == stockqty &&
        other.imageurl == imageurl &&
        other.isactive == isactive &&
        other.displayorder == displayorder &&
        other.category == category &&
        other.slug == slug &&
        listEquals(other.images, images) &&
        listEquals(other.details, details);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        procode.hashCode ^
        proname.hashCode ^
        description.hashCode ^
        price.hashCode ^
        priceqty.hashCode ^
        priceqtyunit.hashCode ^
        stockqty.hashCode ^
        imageurl.hashCode ^
        isactive.hashCode ^
        displayorder.hashCode ^
        category.hashCode ^
        slug.hashCode ^
        images.hashCode ^
        details.hashCode;
  }
}
