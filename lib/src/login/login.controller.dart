import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:puvipureadmin/project/routes/app_route_constants.dart';
import 'package:puvipureadmin/src/common/apiservice.dart';
import 'package:puvipureadmin/src/common/urls.dart';
import 'package:puvipureadmin/src/models/admin.dart';
import 'package:puvipureadmin/src/notification/notification.service.dart';
import 'package:puvipureadmin/src/storage/securestorage.dart';

class LoginController with ChangeNotifier {
  bool loading = false;
  String? error;
  Admin? admin; // store logged-in admin
  User? firebaseUser;

  Future<bool> login(String username, String password) async {
    loading = true;
    notifyListeners();

    final result = await ApiService.post<Admin>(
      url: Urls.adminLogin,
      body: {"username": username, "password": password},
      fromJson: (data) => Admin.fromMap(data),
    );

    loading = false;

    if (result.status && result.returnObject != null) {
      admin = result.returnObject!;
      final adminId = admin!.id.toString();
      final userName = admin!.username.toString();
      final jwt = admin!.jwttoken;

      if (jwt != null) {
        // 🔒 Save session securely
        await AppSecureStorage.saveAuth(adminId, jwt);
      }

      // 3️⃣ Firebase anonymous sign-in
      firebaseUser = (await FirebaseAuth.instance.signInAnonymously()).user;

      // 🔔 Save FCM token to backend
      final fcm = await NotificationService.getAndSaveToken();
      if (fcm != null) {
        await ApiService.post(
          url: Urls.adminAddFcm,
          body: {"username": userName, "fcmtoken": fcm},
          fromJson: (json) => json,
        );
      }

      // 🔹 Fetch admin PIN from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(username)
          .get();

      final pin = doc.data()?['pin']?.toString();
      if (pin != null && pin.length == 4) {
        await AppSecureStorage.saveAdminPin(pin); // ✅ use new helper
      }

      notifyListeners();
      return true;
    } else {
      error = result.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    await AppSecureStorage.clearAll();
    admin = null;
    notifyListeners();

    // Sign out from Firebase
    if (firebaseUser != null) {
      await FirebaseAuth.instance.signOut();
      firebaseUser = null;
    }
    context.go(AppRouteConstants.login);
  }
}
