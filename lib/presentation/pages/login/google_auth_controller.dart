import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthController extends GetxController {
  GoogleSignIn _googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;


  googleLoin() async {
    final googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      _user = googleUser;
      GoogleSignInAuthentication _authentication = await googleUser
          .authentication;
      OAuthCredential _googleCredential = GoogleAuthProvider.credential(
        idToken: _authentication.idToken,
        accessToken: _authentication.accessToken,
      );
      await FirebaseAuth.instance.signInWithCredential(_googleCredential);
    }
  }

  void googleLogout() async {
    await _googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}

  /*
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
  */

  /////////////////////////////////////////


  /*
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get getUser => _user!;

  googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;
      *//* 구글 로그인 실패 시 반환 *//*
      _user = googleUser;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      /// 구글 로그인 성공 시 패스워드 페이지 이동
      Get.off(() => const PasswordPage());

      update();
      return null;
    } catch (e) {
      return '구글 로그인 중 오류가 발생했습니다. : ${e}';
    }
  }

  // 로그아웃
  void logout() async {
    try {
      await googleSignIn.disconnect();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // 로그아웃 중 예외 처리
      Get.snackbar('Logout Error', '로그아웃 중 오류가 발생했습니다: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
  */