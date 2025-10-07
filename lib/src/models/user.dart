import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:puvipureadmin/src/common/constantvalues.dart';

class User {
  int? id;
  String? uid;
  String? name;
  String? username;
  String? password;
  bool? isemailverified;
  bool? ismobilenoverified;
  String? mobileno;
  String? address;
  String? photourl;
  String? oauth2provider;
  String? jwttoken;
  String? refreshtoken;
  DateTime? oauthcreationtime;
  DateTime? oauthlastsignin;
  bool? is2faEnabled;
  String? twofactorauthtoken;
  BigInt? lastsignintimestamp;
  DateTime? createddate;
  DateTime? createdtime;
  DateTime? updateddatetime;
  String? fcmtoken; // <-- New field added

  User({
    this.id,
    this.uid,
    this.name,
    this.username,
    this.password,
    this.isemailverified,
    this.ismobilenoverified,
    this.mobileno,
    this.address,
    this.photourl,
    this.oauth2provider,
    this.jwttoken,
    this.refreshtoken,
    this.oauthcreationtime,
    this.oauthlastsignin,
    this.is2faEnabled,
    this.twofactorauthtoken,
    this.lastsignintimestamp,
    this.createddate,
    this.createdtime,
    this.updateddatetime,
    this.fcmtoken, // <-- New field in constructor
  });

  User copyWith({
    int? id,
    String? uid,
    String? name,
    String? username,
    String? password,
    bool? isemailverified,
    bool? ismobilenoverified,
    String? mobileno,
    String? address,
    String? photourl,
    String? oauth2provider,
    String? jwttoken,
    String? refreshtoken,
    DateTime? oauthcreationtime,
    DateTime? oauthlastsignin,
    bool? is2faEnabled,
    String? twofactorauthtoken,
    BigInt? lastsignintimestamp,
    DateTime? createddate,
    DateTime? createdtime,
    DateTime? updateddatetime,
    String? fcmtoken, // <-- New field
  }) {
    return User(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      isemailverified: isemailverified ?? this.isemailverified,
      ismobilenoverified: ismobilenoverified ?? this.ismobilenoverified,
      mobileno: mobileno ?? this.mobileno,
      address: address ?? this.address,
      photourl: photourl ?? this.photourl,
      oauth2provider: oauth2provider ?? this.oauth2provider,
      jwttoken: jwttoken ?? this.jwttoken,
      refreshtoken: refreshtoken ?? this.refreshtoken,
      oauthcreationtime: oauthcreationtime ?? this.oauthcreationtime,
      oauthlastsignin: oauthlastsignin ?? this.oauthlastsignin,
      is2faEnabled: is2faEnabled ?? this.is2faEnabled,
      twofactorauthtoken: twofactorauthtoken ?? this.twofactorauthtoken,
      lastsignintimestamp: lastsignintimestamp ?? this.lastsignintimestamp,
      createddate: createddate ?? this.createddate,
      createdtime: createdtime ?? this.createdtime,
      updateddatetime: updateddatetime ?? this.updateddatetime,
      fcmtoken: fcmtoken ?? this.fcmtoken, // <-- copyWith
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (name != null) 'name': name,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (isemailverified != null) 'isemailverified': isemailverified,
      if (ismobilenoverified != null) 'ismobilenoverified': ismobilenoverified,
      if (mobileno != null) 'mobileno': mobileno,
      if (address != null) 'address': address,
      if (photourl != null) 'photourl': photourl,
      if (oauth2provider != null) 'oauth2provider': oauth2provider,
      if (jwttoken != null) 'jwttoken': jwttoken,
      if (refreshtoken != null) 'refreshtoken': refreshtoken,
      if (oauthcreationtime != null)
        'oauthcreationtime': oauthcreationtime!.millisecondsSinceEpoch,
      if (oauthlastsignin != null)
        'oauthlastsignin': oauthlastsignin!.millisecondsSinceEpoch,
      if (is2faEnabled != null) 'is2faEnabled': is2faEnabled,
      if (twofactorauthtoken != null) 'twofactorauthtoken': twofactorauthtoken,
      if (lastsignintimestamp != null)
        'lastsignintimestamp': lastsignintimestamp.toString(),
      if (createddate != null)
        'createddate': createddate!.millisecondsSinceEpoch,
      if (createdtime != null)
        'createdtime': createdtime!.millisecondsSinceEpoch,
      if (updateddatetime != null)
        'updateddatetime': updateddatetime!.millisecondsSinceEpoch,
      if (fcmtoken != null) 'fcmtoken': fcmtoken, // <-- toMap
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt(),
      uid: map['uid'],
      name: map['name'],
      username: map['username'],
      password: map['password'],
      isemailverified: map['isemailverified'],
      ismobilenoverified: map['ismobilenoverified'],
      mobileno: map['mobileno'],
      address: map['address'],
      photourl: map['photourl'],
      oauth2provider: map['oauth2provider'],
      jwttoken: map['jwttoken'],
      refreshtoken: map['refreshtoken'],
      oauthcreationtime: getDateFromMap(map['oauthcreationtime']),
      oauthlastsignin: getDateFromMap(map['oauthlastsignin']),
      is2faEnabled: map['is2faEnabled'],
      twofactorauthtoken: map['twofactorauthtoken'],
      lastsignintimestamp: map['lastsignintimestamp'] != null
          ? BigInt.tryParse(map['lastsignintimestamp'].toString())
          : null,
      createddate: getDateFromMap(map['createddate']),
      createdtime: getDateFromMap(map['createdtime']),
      updateddatetime: getDateFromMap(map['updateddatetime']),
      fcmtoken: map['fcmtoken'], // <-- fromMap
    );
  }

  static DateTime? getDateFromMap(dynamic input) {
    try {
      if (input is Map<String, dynamic>) {
        int? year = input['year'];
        int? month = input['monthValue'];
        int? day = input['dayOfMonth'];
        int? hour = input['hour'];
        int? minute = input['minute'];
        int? second = input['second'];
        int? nano = input['nano'];

        if (year != null && month != null && day != null) {
          return DateTime(
            year,
            month,
            day,
            hour ?? 0,
            minute ?? 0,
            second ?? 0,
            (nano ?? 0) ~/ 1000,
          );
        }
      } else if (input is String) {
        if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input.trim())) {
          return DateTime.parse(input.trim());
        }
        if (input.contains('.') && input.split('.').last.length == 9) {
          input = input.substring(0, input.lastIndexOf('.') + 7);
        }
        String fixed = fixFractionSeparator(input);
        return DateFormat(ConstantValues.dateTimeWithMicroSeconds).parse(fixed);
      } else if (input is int) {
        return DateTime.fromMillisecondsSinceEpoch(input);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static String fixFractionSeparator(String s) {
    final regex = RegExp(r':(?=\d{6}$)');
    if (regex.hasMatch(s)) {
      return s.replaceFirst(regex, '.');
    }
    return s;
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(id: $id, uid: $uid, name: $name, username: $username, password: $password, isemailverified: $isemailverified, ismobilenoverified: $ismobilenoverified, mobileno: $mobileno, address: $address, photourl: $photourl, oauth2provider: $oauth2provider, jwttoken: $jwttoken, refreshtoken: $refreshtoken, oauthcreationtime: $oauthcreationtime, oauthlastsignin: $oauthlastsignin, is2faEnabled: $is2faEnabled, twofactorauthtoken: $twofactorauthtoken, lastsignintimestamp: $lastsignintimestamp, createddate: $createddate, createdtime: $createdtime, updateddatetime: $updateddatetime, fcmtoken: $fcmtoken)';
  }
}
