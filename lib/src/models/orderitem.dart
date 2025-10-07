import 'dart:convert';

import 'product.dart';

class OrderItem {
  int? id;
  String? orderid; // just store the order's ID to avoid circular reference
  Product product;
  String uniquekey;
  String rowsign;
  int qty;
  double price;
  OrderItem({
    this.id,
    this.orderid,
    required this.product,
    required this.uniquekey,
    required this.rowsign,
    required this.qty,
    required this.price,
  });

  OrderItem copyWith({
    int? id,
    String? orderid,
    Product? product,
    String? uniquekey,
    String? rowsign,
    int? qty,
    double? price,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderid: orderid ?? this.orderid,
      product: product ?? this.product,
      uniquekey: uniquekey ?? this.uniquekey,
      rowsign: rowsign ?? this.rowsign,
      qty: qty ?? this.qty,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (id != null) {
      result.addAll({'id': id});
    }
    if (orderid != null) {
      result.addAll({'orderid': orderid});
    }
    result.addAll({'product': product.toMap()});
    result.addAll({'uniquekey': uniquekey});
    result.addAll({'rowsign': rowsign});
    result.addAll({'qty': qty});
    result.addAll({'price': price});

    return result;
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id']?.toInt(),
      orderid: map['orderid'],
      product: Product.fromMap(map['product']),
      uniquekey: map['uniquekey'] ?? '',
      rowsign: map['rowsign'] ?? '',
      qty: map['qty']?.toInt() ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItem.fromJson(String source) =>
      OrderItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderItem(id: $id, orderid: $orderid, product: $product, uniquekey: $uniquekey, rowsign: $rowsign, qty: $qty, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderItem &&
        other.id == id &&
        other.orderid == orderid &&
        other.product == product &&
        other.uniquekey == uniquekey &&
        other.rowsign == rowsign &&
        other.qty == qty &&
        other.price == price;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        orderid.hashCode ^
        product.hashCode ^
        uniquekey.hashCode ^
        rowsign.hashCode ^
        qty.hashCode ^
        price.hashCode;
  }
}
