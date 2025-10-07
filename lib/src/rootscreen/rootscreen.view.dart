import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:puvipureadmin/project/routes/app_route_constants.dart';
import 'package:puvipureadmin/src/storage/securestorage.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final token = await AppSecureStorage.getAuthToken();
    setState(() {
      _loggedIn = token != null;
      _checking = false;
    });

    if (!_checking) {
      if (_loggedIn) {
        context.go(AppRouteConstants.dashboard);
      } else {
        context.go(AppRouteConstants.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const SizedBox.shrink();
  }
}
