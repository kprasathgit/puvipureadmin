import 'package:flutter/material.dart';

import '../common/apiservice.dart';
import '../common/urls.dart';
import '../models/order.dart';
import '../models/user.dart';

class UserController with ChangeNotifier {
  List<User> users = [];
  bool loading = false;

  /// Fetch all users
  Future<void> fetchUsers() async {
    loading = true;
    notifyListeners();

    try {
      final result = await ApiService.get<List<dynamic>>(
        url: Urls.getAllUsers,
        fromJson: (data) => data as List<dynamic>,
      );

      if (result.status && result.returnObject != null) {
        users = (result.returnObject!)
            .map((e) => User.fromMap(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint("Error fetching users: ${result.message}");
      }
    } catch (e) {
      debugPrint("Exception fetching users: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Fetch a single user by UID
  Future<User?> fetchUserByUid(String uid) async {
    try {
      final result = await ApiService.get<Map<String, dynamic>>(
        url: '${Urls.userMappingUrl}/$uid/getuser',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (result.status && result.returnObject != null) {
        User user = User.fromMap(result.returnObject!);
        int index = users.indexWhere((u) => u.uid == uid);
        if (index != -1) {
          users[index] = user;
        } else {
          users.add(user);
        }
        notifyListeners();
        return user;
      } else {
        debugPrint("Error fetching user $uid: ${result.message}");
      }
    } catch (e) {
      debugPrint("Exception fetching user $uid: $e");
    }
    return null;
  }

  /// Fetch orders for a specific user
  Future<List<Order>> fetchUserOrders(String uid) async {
    try {
      final result = await ApiService.get<List<dynamic>>(
        url: '${Urls.userMappingUrl}/$uid/getuserorders',
        fromJson: (data) => data as List<dynamic>,
      );

      if (result.status && result.returnObject != null) {
        List<Order> orders = (result.returnObject!)
            .map((e) => Order.fromMap(e as Map<String, dynamic>))
            .toList();
        return orders;
      } else {
        debugPrint("Error fetching orders for user $uid: ${result.message}");
      }
    } catch (e) {
      debugPrint("Exception fetching orders for user $uid: $e");
    }
    return [];
  }
}
