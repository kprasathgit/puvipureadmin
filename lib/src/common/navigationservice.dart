import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:puvipureadmin/project/routes/app_route_constants.dart';

class NavigationService {
  // Global navigator key for GoRouter
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Navigate to orders list (no orderId)
  static void navigateToOrders() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    context.go(AppRouteConstants.orders);
  }

  /// Navigate directly to a specific order
  static void navigateToOrder(String orderId) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    context.push("${AppRouteConstants.orders}?orderId=$orderId");
  }

  static void navigateToRoot() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    context.go(AppRouteConstants.root);
  }

  /// Generic navigation method
  static void navigateTo(String path) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    context.go(path);
  }

  /// Push navigation (instead of replace)
  static void pushTo(String path) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    context.push(path);
  }
}
