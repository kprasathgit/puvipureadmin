import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:puvipureadmin/firebase_options.dart';
import 'package:puvipureadmin/src/app.dart';
import 'package:puvipureadmin/src/common/navigationservice.dart';
import 'package:puvipureadmin/src/notification/notification.service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications
//  await NotificationService.init();

  await NotificationService.init(onTap: (data) {
    final orderId = data['orderid'];
    if (orderId != null) {
      // Navigate to OrderScreen and scroll/open the order card
      NavigationService.navigateToRoot();
    }
  });

  runApp(const App());
}
