import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:puvipureadmin/project/routes/app_route_constants.dart';
import 'package:puvipureadmin/src/login/login.controller.dart';

class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      builder: (context, loginController, child) {
        return Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text("Puvi Admin", style: TextStyle(fontSize: 24)),
              ),
              ListTile(
                title: const Text("Dashboard"),
                onTap: () {
                  context.push(AppRouteConstants.dashboard);
                },
              ),
              // ListTile(
              //   title: const Text("Users"),
              //   onTap: () {
              //     context.push(AppRouteConstants.users);
              //   },
              // ),
              ListTile(
                title: const Text("Orders"),
                onTap: () {
                  context.push(AppRouteConstants.orders);
                },
              ),
              ListTile(
                title: const Text("Products"),
                onTap: () {
                  context.push(AppRouteConstants.products);
                },
              ),

              const Divider(),
               ListTile(
                  leading: const Icon(Icons.logout, color: Colors.blueGrey),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await loginController.logout(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
