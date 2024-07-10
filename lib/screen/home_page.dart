import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_app/controller/auth_controller.dart';
import 'package:login_app/controller/login_controller.dart';

class HomePage extends StatelessWidget {
  final googleLoginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              AuthController.instance.logOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                googleLoginController.googleSignInAccount.value?.displayName ?? '',
            ),
            Text(
              googleLoginController.googleSignInAccount.value?.email ?? '',
            ),
          ],
        ),
      ),
    );
  }
}