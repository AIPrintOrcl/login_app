import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_app/presentation/pages/login/auth_controller.dart';
import 'package:login_app/presentation/pages/login/google_auth_controller.dart';

class HomePage extends StatelessWidget {
  final authController = Get.put(AuthController());
  final googleAuthController = Get.put(GoogleAuthController());

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
              googleAuthController.user.displayName!,
            ),
            Text(
              googleAuthController.user.email,
            ),
            Obx(() {
              return logoutBtn();

              return googleLogoutBtn();

              return logoutBtn();
            }),
          ],
        ),
      ),
    );
  }

  ElevatedButton logoutBtn() {
    return ElevatedButton(
      onPressed: () {
        authController.logOut();
      },
      child: Text('Google LogOut'),
    );
  }

  ElevatedButton googleLogoutBtn() {
    return ElevatedButton(
      onPressed: () {
        googleAuthController.googleLogout();
      },
      child: Text('Google LogOut'),
    );
  }

}