import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvipureadmin/project/routes/app_route_config.dart';
import 'package:puvipureadmin/src/dashboard/dashboard.controller.dart';
import 'package:puvipureadmin/src/login/login.controller.dart';
import 'package:puvipureadmin/src/order/ordercontroller.dart';
import 'package:puvipureadmin/src/product/productcontroller.dart';
import 'package:puvipureadmin/src/user/usercontroller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = MyAppRouter();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final data = NotificationService.pendingData;
    //   if (data != null && data['orderid'] != null) {
    //     final orderId = data['orderid']!;
    //     NotificationService.clearPending();

    //     // 🚀 Push Orders on top of Dashboard
    //     NavigationService.pushTo(
    //       "${AppRouteConstants.orders}?orderId=$orderId",
    //     );
    //   }
    // });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
      ],

      child: MaterialApp.router(
        title: 'Puvi Admin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: appRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
