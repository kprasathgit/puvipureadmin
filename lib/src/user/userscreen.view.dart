import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvipureadmin/src/user/usercontroller.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Users")),
      body: userController.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userController.users.length,
              itemBuilder: (_, index) {
                final user = userController.users[index];
                return ListTile(
                  title: Text(user.name ?? ""),
                  subtitle: Text(user.mobileno ?? ""),
                );
              },
            ),
    );
  }
}
