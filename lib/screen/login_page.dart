import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_app/controller/auth_controller.dart';
import 'package:login_app/controller/login_controller.dart';
import 'package:login_app/screen/home_page.dart';
import 'package:login_app/screen/register_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final googleLoginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AuthController.instance
                    .login(emailController.text.trim(), passwordController.text.trim());
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Get.to(() => RegisterPage());
              },
              child: Text('Register'),
            ),
            SizedBox(height: 20),
            FloatingActionButton.extended(
              onPressed: (){
                if(googleLoginController.googleSignInAccount.value == null)
                  googleLoginController.googleLogin(); /* 구글 로그인 */
                else Get.to(() => HomePage());
              },
              icon: Image.asset(
                'assets/images/google_icon.png',
                height: 32,
                width: 32,
              ),
              label: Text('Sign in with Google'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton googleLoginButton() {
    return FloatingActionButton.extended(
      onPressed: (){
        /// 구글 로그인
        googleLoginController.googleLogin();
      },
      icon: Image.asset(
        'assets/images/google_icon.png',
        height: 32,
        width: 32,
      ),
      label: Text('Sign in with Google'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }

}