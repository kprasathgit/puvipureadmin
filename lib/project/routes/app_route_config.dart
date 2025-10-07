import 'package:go_router/go_router.dart';
import 'package:puvipureadmin/project/routes/app_route_constants.dart';
import 'package:puvipureadmin/src/common/navigationservice.dart';
import 'package:puvipureadmin/src/dashboard/dashboard.view.dart';
import 'package:puvipureadmin/src/login/login.view.dart';
import 'package:puvipureadmin/src/order/orderscreen.view.dart';
import 'package:puvipureadmin/src/product/productscreen.view.dart';
import 'package:puvipureadmin/src/rootscreen/rootscreen.view.dart';
import 'package:puvipureadmin/src/user/userscreen.view.dart';

class MyAppRouter {
  late final GoRouter router;

  MyAppRouter() {
    router = GoRouter(
      initialLocation: AppRouteConstants.root,
      navigatorKey: NavigationService.navigatorKey,
      // redirect: (context, state) {
      //   final data = NotificationService.pendingData;

      //   // If an orderId exists from a notification → redirect
      //   if (data != null && data['orderid'] != null) {
      //     final orderId = data['orderid'];

      //     // 🔄 clear it immediately so it doesn’t keep redirecting
      //     NotificationService.clearPending();

      //     return "${AppRouteConstants.orders}?orderId=$orderId";
      //   }

      //   return null; // stay on whatever route is requested
      // },
      routes: [
        GoRoute(
          path: AppRouteConstants.root,
          builder: (context, state) => const RootScreen(),
        ),
        GoRoute(
          path: AppRouteConstants.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRouteConstants.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRouteConstants.users,
          builder: (context, state) => const UserScreen(),
        ),
        // GoRoute(
        //   path: AppRouteConstants.orders,
        //   builder: (context, state) => const OrderScreen(),
        // ),
        GoRoute(
          path: AppRouteConstants.orders,
          builder: (context, state) {
            final orderId = state.uri.queryParameters['orderId'];
            return OrderScreen(orderId: orderId);
          },
        ),

        GoRoute(
          path: AppRouteConstants.products,
          builder: (context, state) => const ProductScreen(),
        ),
        // Specific order by ID
        // GoRoute(
        //   path: "${AppRouteConstants.orders}/:orderId",
        //   builder: (context, state) {
        //     final orderId = state.pathParameters['orderId'];
        //     return OrderScreen(orderId: orderId);
        //   },
        // ),
      ],
    );
  }
}
