import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:login_app/presentation/pages/password/password_page_controller.dart';

/* 비밀번호 입력을 위한 키패드와 비밀번호 설정 및 확인 가능 기능 제공. */

// 비밀번호 입력 페이지. 기존 지갑이 있는 경우와 새로운 지갑을 만드는 경우로 구분되어 있다.
class PasswordPage extends StatelessWidget {
  const PasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasWallet = Get.arguments == null ? false : true; /* 지갑 기존/새로운 확인. Get.arguments는 현재 라우트로 전달된 인수(arguments)를 가져오는 데 사용 */
    final controller = Get.put(PasswordPageController());
    return Scaffold(
      appBar: hasWallet
          ? null /* 지갑이 있을 경우 */
          : AppBar( /* 지갑이 없을 경우 */
              elevation: 0,
              leading: InkWell(
                  onTap: () => Get.back(),
                  child: const Center(
                      child: Icon(Icons.arrow_back_ios, color: Colors.black))),
              backgroundColor: HexColor('#EAFAD9'),
            ),
      body: Container( /* 지갑이 있을 경우 */
          color: HexColor('#EAFAD9'),
          child: Obx(
            () => Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Spacer(flex: 1),
                  SizedBox(
                    width: Get.width * 0.8,
                    child: Text(
                      controller.isWalletExist? "password_text2".tr:
                      controller.isFirstPasswordDone
                          ? 'confirm_password_text1'.tr
                          : 'password_text1'.tr,
                      style: TextStyle(
                          fontSize: 26,
                          color: HexColor('#555D42'),
                          fontFamily: 'ONE_Mobile_POP_OTF',
                          fontWeight: FontWeight.w400,
                          height: 1.45),
                      textAlign: TextAlign.center,
                      textWidthBasis: TextWidthBasis.parent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Spacer(flex: 1),
                  Text(
                      controller.isConfirmPassWord
                          ? controller.confirmPassWord
                              .replaceAll(RegExp('[0-9]'), "●")
                          : controller.passWord
                              .replaceAll(RegExp('[0-9]'), "●"),
                      style: TextStyle(
                          letterSpacing: 10,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: HexColor("#D9D9D9"))),
                  const Spacer(flex: 1),
                  const KeyPad(),
                  const Spacer(flex: 1),
                  const PasswordInfo()
                ]),
          )),
    );
  }
}

// 비밀번호 입력을 위한 키패드. 사용자가 숫자를 입력하면 비밀번호가 설정된다.
class KeyPad extends StatelessWidget {
  const KeyPad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PasswordPageController>();
    return Obx(() => Column(
          children: [
            ...controller.keyPadNums
                .map((x) => SizedBox(
                      height: 70,
                      child: Row(
                        children: x
                            .map((y) => Expanded(
                                child:
                                    KeyPadKey(label: y.toString(), value: y)))
                            .toList(),
                      ),
                    ))
                .toList(),
          ],
        ));
  }
}

class KeyPadKey extends StatelessWidget {
  final String label;
  final dynamic value;
  const KeyPadKey({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PasswordPageController>();
    return InkWell(
        onTap: () {
          if (Get.isSnackbarOpen) {
            return;
          }
          if (!controller.isClicked) {
            Get.snackbar('password'.tr, 'password_notice_check'.tr,
                duration: Duration(seconds: 1));
            return;
          }
          controller.setKeyPadNums(value);
          if (controller.isConfirmPassWord) {
            controller.setConfirmPassWord(value);
          } else {
            controller.setPassWord(value);
          }
        },
        child: Center(
            child: Text(
          label,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            fontFamily: 'ONE_Mobile_POP_OTF',
          ),
        )));
  }
}

// 비밀번호 설정 주의 사항 읽고 체크해야 패스워드 입력 가능.
class PasswordInfo extends StatelessWidget {
  const PasswordInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PasswordPageController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: HexColor('#555D42'),
      height: 74,
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Checkbox(
                  value: controller.isClicked,
                  onChanged: (value) => controller.setIsClicked = value!))
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'password_notice'.tr,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
