class OrderItem {
  int? id;
  String? procode;
  int qty;
  double price;
  String? uniquekey;
  String? rowsign;
  OrderItem({
    this.id,
    this.procode,
    this.qty = 0,
    this.price = 0.0,
    this.uniquekey,
    this.rowsign,
  });
  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    id: j['id'] != null ? int.tryParse(j['id'].toString()) : null,
    procode: j['procode']?.toString(),
    qty: j['qty'] != null ? int.tryParse(j['qty'].toString()) ?? 0 : 0,
    price: j['price'] != null
        ? double.tryParse(j['price'].toString()) ?? 0.0
        : 0.0,
    uniquekey: j['uniquekey']?.toString(),
    rowsign: j['rowsign']?.toString(),
  );
}

class Delivery {
  String? couriername;
  String? deliverystatus;
  String? trackingid;
  String? trackingurl;
  Delivery({
    this.couriername,
    this.deliverystatus,
    this.trackingid,
    this.trackingurl,
  });
  factory Delivery.fromJson(Map<String, dynamic> j) => Delivery(
    couriername: j['couriername']?.toString(),
    deliverystatus: j['deliverystatus']?.toString(),
    trackingid: j['trackingid']?.toString(),
    trackingurl: j['trackingurl']?.toString(),
  );
}

class UserShort {
  String? uid;
  String? username;
  String? mobileno;
  String? name;
  String? address;
  UserShort({this.uid, this.username, this.mobileno, this.name, this.address});
  factory UserShort.fromJson(Map<String, dynamic> j) => UserShort(
    uid: j['uid']?.toString(),
    username: j['username']?.toString(),
    mobileno: j['mobileno']?.toString(),
    name: j['name']?.toString(),
    address: j['address']?.toString(),
  );
}

class OrderFull {
  String? orderid;
  String? orderstatus;
  String? paymentstatus;
  String? paymentmode;
  String? paymentid;
  double totalamount;
  String? shippingaddress;
  String? uniquekey;
  String? rowsign;
  String? userid;
  Delivery? delivery;
  UserShort? user;
  List<OrderItem> items;
  OrderFull({
    this.orderid,
    this.orderstatus,
    this.items = const [],
    this.delivery,
    this.user,
    this.totalamount = 0.0,
    this.shippingaddress,
    this.paymentid,
    this.paymentmode,
    this.paymentstatus,
    this.uniquekey,
    this.rowsign,
    this.userid,
  });

  factory OrderFull.fromJson(Map<String, dynamic> j) {
    var itemsList = <OrderItem>[];
    if (j['items'] != null) {
      // in our backend we return items as actual list (not a GROUP_CONCAT string) inside DTO - if you keep GROUP_CONCAT, backend mapping already converted to list
      if (j['items'] is List) {
        itemsList = (j['items'] as List)
            .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (j['items'] is String) {
        // fallback if backend returned a string (but our backend code returns list)
        // ignore here
      }
    }
    return OrderFull(
      orderid: j['orderid']?.toString(),
      orderstatus: j['orderstatus']?.toString(),
      paymentid: j['paymentid']?.toString(),
      paymentstatus: j['paymentstatus']?.toString(),
      paymentmode: j['paymentmode']?.toString(),
      totalamount: j['totalamount'] != null
          ? double.tryParse(j['totalamount'].toString()) ?? 0.0
          : 0.0,
      shippingaddress: j['shippingaddress']?.toString(),
      uniquekey: j['uniquekey']?.toString(),
      rowsign: j['rowsign']?.toString(),
      userid: j['userid']?.toString(),
      delivery: j['delivery'] != null
          ? Delivery.fromJson(Map<String, dynamic>.from(j['delivery']))
          : null,
      user: j['user'] != null
          ? UserShort.fromJson(Map<String, dynamic>.from(j['user']))
          : null,
      items: itemsList,
    );
  }
}
