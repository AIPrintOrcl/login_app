import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_app/presentation/pages/login/auth_controller.dart';
import 'package:login_app/presentation/pages/login/google_auth_controller.dart';
import 'package:login_app/presentation/pages/login/register_page.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final googleAuthController = Get.put(GoogleAuthController());

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
            ElevatedButton(
              onPressed: (){
                // if(googleLoginController.googleSignInAccount.value == null)
                //   googleLoginController.googleLogin(); /* 구글 로그인 */
                // else Get.to(() => HomePage());
                googleAuthController.googleLoin();
              },
              child: Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }

}