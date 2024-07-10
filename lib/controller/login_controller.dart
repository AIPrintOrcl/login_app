import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_app/screen/home_page.dart';

class LoginController extends GetxController {
  var _googleSignIn = GoogleSignIn();

  var googleSignInAccount = Rx<GoogleSignInAccount?>(null);

  // 로그인
  googleLogin() async {
      googleSignInAccount.value = await _googleSignIn.signIn();
  }

  // 로그아웃
  Future<void> logout() async {
    googleSignInAccount.value = await _googleSignIn.signOut();
  }

}