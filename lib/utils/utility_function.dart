import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:login_app/utils/getx_controller.dart';
import 'package:login_app/services/service_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ntp/ntp.dart';


// Firebase Firestore와의 데이터 상호작용, 디바이스 정보 획득, 특정 데이터의 상태 확인 및 설정

/*
* 기능: getUserCollectionName(getx.mode) 컬렉션의
*  getx.walletAddress.value 문서를 data로 업데이트합니다.
* 파라미터:
*   db: Firestore 데이터베이스 인스턴스
*   data: 업데이트할 데이터
*   needTimer: 타이머가 필요한지 여부 (사용되지 않음)
*/
Future<void> updateUserDB(FirebaseFirestore db, data, bool needTimer) async {
  await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update(data);
}

/*
* 기능: 현재 시간 정보를 추가하여 사용자 오류 데이터를
*  Firestore의 "error" 하위 컬렉션에 추가합니다.
* 파라미터:
*   db: Firestore 데이터베이스 인스턴스
*   data: 추가할 오류 데이터
*/
Future<void> appendUserErrorDB(FirebaseFirestore db, Map<String, dynamic> data) async {
  DateTime currentTime = await NTP.now();
  print(data);
  data["time"] = currentTime.toUtc().add(Duration(hours: 9)).toString();
  data["timemillis"] = currentTime.millisecondsSinceEpoch;

  await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value)
      .collection("error").add(data);
}

/*
* 기능: 타이머가 필요한 경우 현재 시간 정보를 추가하고, 지정된 컬렉션에 데이터를 추가합니다.
*  추가된 문서의 ID를 반환합니다.
* 파라미터:
*   db: Firestore 데이터베이스 인스턴스
*   collection_name: 데이터가 추가될 컬렉션 이름
*   data: 추가할 데이터
*   needTimer: 타이머가 필요한지 여부
* */
Future<String> adddataUserCollectionDB(FirebaseFirestore db, String collection_name, Map<String, dynamic> data, bool needTimer) async {
  late final String docID;

  if (needTimer) {
    DateTime currentTime = await NTP.now();
    data["time"] = currentTime.toUtc().add(Duration(hours: 9)).toString();
    data["timemillis"] = currentTime.millisecondsSinceEpoch;
  }

  await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value)
      .collection(collection_name).add(data).then((value) => docID = value.id);

  return docID;
}

/*
* 기능: 지정된 컬렉션의 문서를 업데이트합니다.
* 파라미터:
*   db: Firestore 데이터베이스 인스턴스
*   collection_name: 업데이트할 컬렉션 이름
*   docID: 업데이트할 문서 ID
*   data: 업데이트할 데이터
* */
Future<void> updateUserCollectionDB(FirebaseFirestore db, String collection_name, String docID, data) async {
  await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value)
      .collection(collection_name).doc(docID).update(data);
}

/*
* 기능: 디바이스 정보를 가져와 Android의 경우 디바이스 ID를,
*  iOS의 경우 identifierForVendor를 반환합니다.
* 파라미터: 없음
* */
Future<String> getDeviceInfo() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final device_info = await deviceInfoPlugin.deviceInfo;

  if (Platform.isAndroid) {
    return device_info.data["id"].toString();
  } else if (Platform.isIOS) {
    return device_info.data["identifierForVendor"];
  }
  device_info.data.forEach((key, value) {
    print("index: " + key.toString() + ", value: " + value.toString());
  });

  return "no device info";
}

/*
* 기능: 지정된 id와 mint_id로 "dispatch" 컬렉션을 조회하여 조건에 맞는 문서가 있는지 확인하고,
* 그 결과를 반환합니다.
* 파라미터:
*   db: Firestore 데이터베이스 인스턴스
*   id: 확인할 ID
*   mint_id: 확인할 mint ID
* */
// return type
// 1: collection database are empty - make new database
// 2: collection is exist but device is not equal - cannot process dispatch
// 3: collection is exist and device is equal but dispatch is not finished. - need to continue dispatch
// 4: device is equal and dispatch is finished. - cannot process dispatch
Future<Map> canDispatchDevice(FirebaseFirestore db, String id, String mint_id) async  {
  Map result_data = {};

  await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value)
      .collection("dispatch").where("id", isEqualTo: id).where("mint_id", isEqualTo: mint_id).limit(1).get().then((querySnapshot) {
        if (querySnapshot.docs.length != 0) {
          final doc = querySnapshot.docs[0];
          result_data["docID"] = doc.id;

          if (doc.data()["device"] != getx.deviceID.value) {
            result_data["result"] = 2;
          } else if (!doc.data()["finished"]) {
            result_data["result"] = 3;
          } else {
            result_data["result"] = 4;
          }
        } else {
          result_data["result"] = 1;
        }
  });

  return result_data;
}

/*
* 기능: 주어진 문자열의 SHA-256 해시를 반환합니다.
* 파라미터:
*   s: 해시를 생성할 문자열
* */
String getSHA256(String s) {
  return sha256.convert(utf8.encode(s)).toString();
}

/*
* 기능: 사용자의 오류 로그 길이를 확인하고, 길이가 제한을 초과하는 경우 일부 로그를 삭제합니다.
* 파라미터:
*   db: Firestore 데이터베이스 인스턴스
* */
Future<void> checkErrorLength(FirebaseFirestore db) async {
  await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).get().then((doc) async {
    final data = doc.data();
    if (data?["errorLogs"] != null) {
      final length = data?["errorLogs"].length;
      final limit_length = getx.mode == "abis"? 50 : 5;
      final sublist_length = getx.mode == "abis"? 30 : 3;

      if (length > limit_length) {
        await db.collection(getUserCollectionName(getx.mode)).doc(getx.walletAddress.value).update({
          "errorLogs": data?["errorLogs"].sublist(length - sublist_length)
        });
      }
    }
  });
}

/*
* 기능: 주어진 데이터 맵에 필요한 키가 존재하지 않을 경우 기본값을 설정합니다.
* 파라미터:
*   data: 확인할 데이터 맵
*   time: 기본 타임 인터벌 값
* */
void checkMarimoData(Map data, int time) {
  if (data["health"] == null) {
    data["health"] = 0;
  }
  if (data["time"] == null) {
    data["time"] = 0;
  }
  if (data["marimoList"] == null) {
    data["marimoList"] = List.generate(13, (index) => '');
  }
  if (data["marimoPartsNumMap"] == null) {
    Map<String, String> tempMap = {};
    data["marimoPartsNumMap"] = tempMap;
  }
  if (data["time_interval"] == null) {
    data["time_interval"] = time;
  }
  if (data["marimoPartCheck"] == null) {
    data["marimoPartCheck"] = [false, false, false, false];
  }
  if (data["environmentTime"] == null) {
    data["environmentTime"] = 0;
  }
}