import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:puvipureadmin/src/models/delivery.dart';
import 'package:puvipureadmin/src/models/orderitem.dart';

class Order {
  int? id;
  String orderid;
  String userid;
  String orderstatus; // keep as string
  String paymentmode; // keep as string
  String paymentstatus; // keep as string
  String? paymentid;
  double totalamount;
  String shippingaddress;
  String uniquekey;
  String rowsign;
  List<OrderItem> items;
  Delivery? delivery;
  String razorpayorderid;
  Order({
    this.id,
    required this.orderid,
    required this.userid,
    required this.orderstatus,
    required this.paymentmode,
    required this.paymentstatus,
    this.paymentid,
    required this.totalamount,
    required this.shippingaddress,
    required this.uniquekey,
    required this.rowsign,
    required this.items,
    this.delivery,
    required this.razorpayorderid,
  });

  Order copyWith({
    int? id,
    String? orderid,
    String? userid,
    String? orderstatus,
    String? paymentmode,
    String? paymentstatus,
    String? paymentid,
    double? totalamount,
    String? shippingaddress,
    String? uniquekey,
    String? rowsign,
    List<OrderItem>? items,
    Delivery? delivery,
    String? razorpayorderid,
  }) {
    return Order(
      id: id ?? this.id,
      orderid: orderid ?? this.orderid,
      userid: userid ?? this.userid,
      orderstatus: orderstatus ?? this.orderstatus,
      paymentmode: paymentmode ?? this.paymentmode,
      paymentstatus: paymentstatus ?? this.paymentstatus,
      paymentid: paymentid ?? this.paymentid,
      totalamount: totalamount ?? this.totalamount,
      shippingaddress: shippingaddress ?? this.shippingaddress,
      uniquekey: uniquekey ?? this.uniquekey,
      rowsign: rowsign ?? this.rowsign,
      items: items ?? this.items,
      delivery: delivery ?? this.delivery,
      razorpayorderid: razorpayorderid ?? this.razorpayorderid,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (id != null) {
      result.addAll({'id': id});
    }
    result.addAll({'orderid': orderid});
    result.addAll({'userid': userid});
    result.addAll({'orderstatus': orderstatus});
    result.addAll({'paymentmode': paymentmode});
    result.addAll({'paymentstatus': paymentstatus});
    if (paymentid != null) {
      result.addAll({'paymentid': paymentid});
    }
    result.addAll({'totalamount': totalamount});
    result.addAll({'shippingaddress': shippingaddress});
    result.addAll({'uniquekey': uniquekey});
    result.addAll({'rowsign': rowsign});
    result.addAll({'items': items.map((x) => x.toMap()).toList()});
    if (delivery != null) {
      result.addAll({'delivery': delivery!.toMap()});
    }
    result.addAll({'razorpayorderid': razorpayorderid});

    return result;
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id']?.toInt(),
      orderid: map['orderid'] ?? '',
      userid: map['userid'] ?? '',
      orderstatus: map['orderstatus'] ?? '',
      paymentmode: map['paymentmode'] ?? '',
      paymentstatus: map['paymentstatus'] ?? '',
      paymentid: map['paymentid'],
      totalamount: map['totalamount']?.toDouble() ?? 0.0,
      shippingaddress: map['shippingaddress'] ?? '',
      uniquekey: map['uniquekey'] ?? '',
      rowsign: map['rowsign'] ?? '',
      items: List<OrderItem>.from(
        map['items']?.map((x) => OrderItem.fromMap(x)),
      ),
      delivery: map['delivery'] != null
          ? Delivery.fromMap(map['delivery'])
          : null,
      razorpayorderid: map['razorpayorderid'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Order(id: $id, orderid: $orderid, userid: $userid, orderstatus: $orderstatus, paymentmode: $paymentmode, paymentstatus: $paymentstatus, paymentid: $paymentid, totalamount: $totalamount, shippingaddress: $shippingaddress, uniquekey: $uniquekey, rowsign: $rowsign, items: $items, delivery: $delivery, razorpayorderid: $razorpayorderid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Order &&
        other.id == id &&
        other.orderid == orderid &&
        other.userid == userid &&
        other.orderstatus == orderstatus &&
        other.paymentmode == paymentmode &&
        other.paymentstatus == paymentstatus &&
        other.paymentid == paymentid &&
        other.totalamount == totalamount &&
        other.shippingaddress == shippingaddress &&
        other.uniquekey == uniquekey &&
        other.rowsign == rowsign &&
        listEquals(other.items, items) &&
        other.delivery == delivery &&
        other.razorpayorderid == razorpayorderid;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        orderid.hashCode ^
        userid.hashCode ^
        orderstatus.hashCode ^
        paymentmode.hashCode ^
        paymentstatus.hashCode ^
        paymentid.hashCode ^
        totalamount.hashCode ^
        shippingaddress.hashCode ^
        uniquekey.hashCode ^
        rowsign.hashCode ^
        items.hashCode ^
        delivery.hashCode ^
        razorpayorderid.hashCode;
  }
}
