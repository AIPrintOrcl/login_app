import 'package:get/get.dart';
// import 'package:login_app/presentation/pages/incubator/incubator_page.dart';
// import 'package:login_app/presentation/pages/incubator/pre_incubator_page.dart';
import 'package:login_app/web3dart/credentials.dart';
import 'package:login_app/utils/getx_controller.dart';
import 'package:login_app/web3dart/crypto.dart';
import 'dart:math';

class PasswordPageController extends GetxController {
  final _isClicked = false.obs;
  bool get isClicked => _isClicked.value;
  set setIsClicked(bool value) => _isClicked.value = value;

  final _walletAddress = "".obs;
  String get walletAddress => _walletAddress.value;
  set setWalletAddress(String value) => _walletAddress.value = value;

  final _isFirstPasswordDone = false.obs;
  bool get isFirstPasswordDone => _isFirstPasswordDone.value;

  late final bool isWalletExist;

  final _keyPadNums = [
    ["2", "6", "4"],
    ["9", "5", "7"],
    ["3", "1", "8"],
    ['reset', "0", "<"]
  ].obs;
  List<List<dynamic>> get keyPadNums => _keyPadNums;

  final _passWord = "".obs;
  String get passWord => _passWord.value;

  final _confirmPassWord = "".obs;
  String get confirmPassWord => _confirmPassWord.value;

  final _recordPassWord = "".obs;
  String get recordPassWord => _recordPassWord.value;

  bool get isConfirmPassWord => _recordPassWord.value.length == 6;

  setKeyPadNums(String value) {
    if (_passWord.value.length == 6 || value == 'reset' || value == "<") {
      return;
    }
    for (var x in _keyPadNums) {
      if (!x.contains("0")) {
        x.shuffle();
      }
    }
    // _keyPadNums.shuffle();
  }

  setPassWord(String value) async {
    if (value != "<" && _passWord.value.length < 6 && value != 'reset') {
      _passWord.value = _passWord.value + value;
    }

    if (value == 'reset') {
      _passWord.value = "";
    }

    if (value == "<") {
      if (_passWord.value.isEmpty) {
        return;
      }
      _passWord.value =
          _passWord.value.substring(0, _passWord.value.length - 1);
    }

    if (_passWord.value.length == 6) {
      //check password with existing keystore file
      if (isWalletExist) {
        try {
          final walletFile = await Wallet.getJsonFromFile();
          getx.credentials = Wallet.fromJson(walletFile, '${_passWord.value}').privateKey;

          // Get.off(() => const IncubatorPage(),
          //     transition: Transition.fadeIn,
          //     duration: const Duration(milliseconds: 500)
          // );
          return;
        } on ArgumentError {
          if (!Get.isSnackbarOpen) {
            Get.snackbar('지갑주소 비밀번호와 일치하지 않습니다.', '', duration: Duration(seconds: 1));
          }
          _passWord.value = "";
          return;
        }
      } else {
        _isFirstPasswordDone.value = true;
        _recordPassWord.value = _passWord.value;
        _passWord.value = "";
      }
    }
  }

  setConfirmPassWord(String value) async {
    if (value != "<" && _confirmPassWord.value.length < 6 && value != 'reset') {
      _confirmPassWord.value = _confirmPassWord.value + value;
    }

    if (value == 'reset') {
      _confirmPassWord.value = "";
    }

    if (value == "<") {
      if (_confirmPassWord.value.isEmpty) {
        return;
      }
      _confirmPassWord.value = _confirmPassWord.value
          .substring(0, _confirmPassWord.value.length - 1);
    }

    if (_confirmPassWord.value.length == 6 &&
        _recordPassWord.value == _confirmPassWord.value) {

      late final credential;
      if (Get.arguments != null && Get.arguments["key"] != null) {
        credential = Web3PrivateKey.fromHex(Get.arguments["key"]);
      } else {
        credential = Web3PrivateKey.createRandom(Random.secure());
      }

      //create new wallet
      Wallet wallet = Wallet.createNew(
          credential,
          _confirmPassWord.value,
          Random.secure());

      setWalletAddress = wallet.privateKey.address.hexEip55;
      getx.walletAddress.value = wallet.privateKey.address.hexEip55;
      getx.credentials = wallet.privateKey;
      wallet.saveAsJsonFile(data: wallet.toJson());

      await getx.getInitialValue();

      // Get.off(() => const PreIncubatorPage(),
      //     transition: Transition.fadeIn,
      //     duration: const Duration(milliseconds: 500)
      // );
    }

    if (_confirmPassWord.value.length == 6 &&
        _recordPassWord.value != _confirmPassWord.value &&
        !Get.isSnackbarOpen) {
      Get.snackbar('password'.tr, 'password_check'.tr);
    }
  }

  @override
  void onInit() {
    isWalletExist = getx.isWalletExist;
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
