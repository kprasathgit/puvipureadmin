import 'dart:convert';
class Delivery {
  int? id;
  String? orderid; // just store orderId
  String? couriername;
  String? trackingid;
  String? trackingurl;
  String uniquekey;
  String rowsign;
  String deliverystatus; // keep as string like 'PN', 'PR', etc.
  Delivery({
    this.id,
    this.orderid,
    this.couriername,
    this.trackingid,
    this.trackingurl,
    required this.uniquekey,
    required this.rowsign,
    required this.deliverystatus,
  });



  Delivery copyWith({
    int? id,
    String? orderid,
    String? couriername,
    String? trackingid,
    String? trackingurl,
    String? uniquekey,
    String? rowsign,
    String? deliverystatus,
  }) {
    return Delivery(
      id: id ?? this.id,
      orderid: orderid ?? this.orderid,
      couriername: couriername ?? this.couriername,
      trackingid: trackingid ?? this.trackingid,
      trackingurl: trackingurl ?? this.trackingurl,
      uniquekey: uniquekey ?? this.uniquekey,
      rowsign: rowsign ?? this.rowsign,
      deliverystatus: deliverystatus ?? this.deliverystatus,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    if(id != null){
      result.addAll({'id': id});
    }
    if(orderid != null){
      result.addAll({'orderid': orderid});
    }
    if(couriername != null){
      result.addAll({'couriername': couriername});
    }
    if(trackingid != null){
      result.addAll({'trackingid': trackingid});
    }
    if(trackingurl != null){
      result.addAll({'trackingurl': trackingurl});
    }
    result.addAll({'uniquekey': uniquekey});
    result.addAll({'rowsign': rowsign});
    result.addAll({'deliverystatus': deliverystatus});
  
    return result;
  }

  factory Delivery.fromMap(Map<String, dynamic> map) {
    return Delivery(
      id: map['id']?.toInt(),
      orderid: map['orderid'],
      couriername: map['couriername'],
      trackingid: map['trackingid'],
      trackingurl: map['trackingurl'],
      uniquekey: map['uniquekey'] ?? '',
      rowsign: map['rowsign'] ?? '',
      deliverystatus: map['deliverystatus'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Delivery.fromJson(String source) => Delivery.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Delivery(id: $id, orderid: $orderid, couriername: $couriername, trackingid: $trackingid, trackingurl: $trackingurl, uniquekey: $uniquekey, rowsign: $rowsign, deliverystatus: $deliverystatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Delivery &&
      other.id == id &&
      other.orderid == orderid &&
      other.couriername == couriername &&
      other.trackingid == trackingid &&
      other.trackingurl == trackingurl &&
      other.uniquekey == uniquekey &&
      other.rowsign == rowsign &&
      other.deliverystatus == deliverystatus;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      orderid.hashCode ^
      couriername.hashCode ^
      trackingid.hashCode ^
      trackingurl.hashCode ^
      uniquekey.hashCode ^
      rowsign.hashCode ^
      deliverystatus.hashCode;
  }
}
