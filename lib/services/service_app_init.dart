import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
// import 'package:login_app/presentation/pages/app_stop_page.dart';
// import 'package:login_app/presentation/pages/main_page.dart';
import 'package:login_app/presentation/pages/password/password_page.dart';
// import 'package:login_app/presentation/widgets/buttons/button_sound.dart';
// import 'package:login_app/utils/const.dart';
import 'package:login_app/utils/getx_controller.dart';
import 'package:login_app/web3dart/web3dart.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// loading 중 필요한 데이터 체크
class ServiceAppInit extends GetxService {
  final db = firestore.FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  final RxInt total_image = 1.obs;
  final RxInt current_image = 0.obs; /* RxInt : GetX의 반응형 변수를 사용하여 이미지 총 개수와 현재 이미지 인덱스 관리 가능. */

  void _checkWalletAddress() async {
    /*final infoRef = storage.ref().child("info");
    ListResult test = await infoRef.listAll();
    total_image.value = test.items.length;

    test.items.forEach((element) async {
      final appDocDir = await getApplicationDocumentsDirectory();
      final filePath = "${appDocDir.absolute}/images/info/${element.name}";
      final file = File(filePath);

      if (await file.exists()) {
        print("storage test: file ${element.name} already exist");
      } else {
        print("storage test: create file ${element.name}");
        print("storage test: ${infoRef.fullPath}");
        print("storage test: ${infoRef.child(element.name).fullPath}");
        final downloadTask = infoRef.child(element.name).writeToFile(file);
        await downloadTask.snapshotEvents.listen((taskSnapshot) {
          switch (taskSnapshot.state) {
            case TaskState.running:
            // TODO: Handle this case.
              break;
            case TaskState.paused:
            // TODO: Handle this case.
              break;
            case TaskState.success:
              current_image.value += 1;
              print("storage test: file download finished ${element.name}");
              break;
            case TaskState.canceled:
            // TODO: Handle this case.
              break;
            case TaskState.error:
              print("storage test: error ${taskSnapshot.toString()}");
            // TODO: Handle this case.
              break;
          }
        });
      }
    });

    print("storage test download completed!");*/
    if (getx.isWalletExist) { /* 지갑 존재 여부 확인. 지갑이 존재할 경우 패스워드 페이지로 이동 */
      Future.delayed(
          const Duration(seconds: 5),
          () => Get.off(() => const PasswordPage(), /* Get.off : 페이지 이동, 이동 효과 및 지연 시간 설정 */
              arguments: true,
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500)));
    } else { /* 지갑이 존재하지 않을 경우 메인 페이지로 이동 */
      Future.delayed(
          const Duration(seconds: 5),
          () => Get.off(() => const MainPage(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500)));
    }
  }

  // 지갑 주소를 가져오고 GetX의 반응형 변수들을 업데이트한다.
  Future<bool> getWalletAddress() async {
    if (getx.isWalletExist) {
      final walletFile = await Wallet.getJsonFromFile();
      getx.keystoreFile.value = json.decode(walletFile);
      getx.walletAddress.value = getx.keystoreFile["address"];

      return true;
    }

    return false;
  }

  // Firebase Firestore에서 앱의 설정 비교하고 앱의 버전 상태 확인
  void _checkFirebaseFireStore() {
    final docRef = db.collection(CONFIG);
    docRef.snapshots().listen(
      (event) async {
        bool appState = false;
        if (Platform.isAndroid) { /* 앱의 현재 플랫폼에 따라 Firestore에 저장된 설정을 가져온다. */
          appState = event.docs.first['androidState'];
        } else if (Platform.isIOS) {
          appState = event.docs.first['iosState'];
        }
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String buildNumber = packageInfo.buildNumber;

        /// 앱의 빌드 번호와 비교하여 버전 업데이트 여부 확인
        if (int.parse(buildNumber) < event.docs.first["version"] || !appState && getx.mode == "abis") { /* 버전이 낮거나 앱의 상태가 비활성 일 경우 */
          Future.delayed(Duration(seconds: 5), () {
            buttonSoundController.pauseSound();
            Get.to(() => const AppStopPage(),
                duration: Duration(milliseconds: 500),
                transition: Transition.fadeIn);
          });
        } else { /* 그렇지 않을 경우 지갑 주소 유무 확인하고 사운드 재생한다. */
          _checkWalletAddress();
          buttonSoundController.playSound();
        }
      },
      onError: (error) => print("Listen failed: $error"),
    );
  }

  // 앱의 빌드 번호 확인. 이전에 저장된 번호와 비교하여 변경 사항 존재할 경우 SharedPreferences(영구 저장소)에 저장한다.
  Future<void> checkBuildNumber() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();;
    PackageInfo packageInfo = await PackageInfo.fromPlatform(); /* 현재 빌드 번호 가져온다. */
    String buildNumber = packageInfo.buildNumber;

    final lastNumber = sharedPrefs.getInt('lastNumber') ?? 0;
    if (lastNumber != int.parse(buildNumber)) { /* 이전에 저장된 번호와 비교하여 변경 사항 존재할 경우 SharedPreferences(영구 저장소)에 저장한다. */
      sharedPrefs.setBool('guide', false);
      sharedPrefs.setInt('lastNumber', int.parse(buildNumber));
    }
  }

  // 애플리케이션이 시작될 때 초기화해야 하는 작업 수행.
  void init() async {
    getx.isWalletExist = await Wallet.isKeystoreExist(); /* 지갑 파일의 존재 여부 확인하고 업데이트한다. */

    await checkBuildNumber(); /* 앱의 빌드 번호를 확인하고 SharedPreferences를 통해 관리하는 초기 설정을 업데이트 */
    await getWalletAddress(); /* 지갑 주소를 가져오고 GetX의 반응형 변수들을 업데이트한다. */
    await getx.getInitialValue(); /* 초기 데이터 값 설정 */
  }

  // GetX의 라이프 사이클.
  @override
  void onInit() {
    _checkFirebaseFireStore();
    init();
    super.onInit();
  }
}
