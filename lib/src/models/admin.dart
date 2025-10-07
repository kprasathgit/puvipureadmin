import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:puvipureadmin/src/common/constantvalues.dart';

class Admin {
  final int id;
  final String username;
  final String role;
  final String? jwttoken;
  final String? refreshtoken;
  final bool active;
  final DateTime? lastlogin;
  final List<String> fcmtokens;
  Admin({
    required this.id,
    required this.username,
    required this.role,
    this.jwttoken,
    this.refreshtoken,
    required this.active,
    this.lastlogin,
    required this.fcmtokens,
  });

  Admin copyWith({
    int? id,
    String? username,
    String? role,
    String? jwttoken,
    String? refreshtoken,
    bool? active,
    DateTime? lastlogin,
    List<String>? fcmtokens,
  }) {
    return Admin(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      jwttoken: jwttoken ?? this.jwttoken,
      refreshtoken: refreshtoken ?? this.refreshtoken,
      active: active ?? this.active,
      lastlogin: lastlogin ?? this.lastlogin,
      fcmtokens: fcmtokens ?? this.fcmtokens,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'username': username});
    result.addAll({'role': role});
    if (jwttoken != null) {
      result.addAll({'jwttoken': jwttoken});
    }
    if (refreshtoken != null) {
      result.addAll({'refreshtoken': refreshtoken});
    }
    result.addAll({'active': active});
    if (lastlogin != null) {
      result.addAll({'lastlogin': lastlogin!.millisecondsSinceEpoch});
    }
    result.addAll({'fcmtokens': fcmtokens});

    return result;
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id']?.toInt() ?? 0,
      username: map['username'] ?? '',
      role: map['role'] ?? '',
      jwttoken: map['jwttoken'],
      refreshtoken: map['refreshtoken'],
      active: map['active'] ?? false,
      lastlogin: getDateFromMap(map['lastlogin']),

      fcmtokens: List<String>.from(map['fcmtokens']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Admin.fromJson(String source) => Admin.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Admin(id: $id, username: $username, role: $role, jwttoken: $jwttoken, refreshtoken: $refreshtoken, active: $active, lastlogin: $lastlogin, fcmtokens: $fcmtokens)';
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Admin &&
        other.id == id &&
        other.username == username &&
        other.role == role &&
        other.jwttoken == jwttoken &&
        other.refreshtoken == refreshtoken &&
        other.active == active &&
        other.lastlogin == lastlogin &&
        listEquals(other.fcmtokens, fcmtokens);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        role.hashCode ^
        jwttoken.hashCode ^
        refreshtoken.hashCode ^
        active.hashCode ^
        lastlogin.hashCode ^
        fcmtokens.hashCode;
  }
}
