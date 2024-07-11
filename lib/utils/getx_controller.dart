import 'dart:math';
import 'package:get/get.dart';
import 'package:login_app/utils/const.dart';
import 'package:login_app/utils/enums.dart';
import 'package:login_app/utils/utility_function.dart';
import 'package:login_app/web3dart/credentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:login_app/web3dart/web3dart.dart';
import 'package:login_app/services/service_functions.dart';
// import 'package:login_app/presentation/pages/collecting/collecting_view_controller.dart';
// import 'package:login_app/presentation/pages/collecting/mission_view_controller.dart';
// import 'package:login_app/services/main_timer.dart';

/// 전역으로 가지고 있어야 할 데이터
class ReactiveCommonController extends GetxController {
  //baobab or main net
  final mode = "abis_test";

  // web3dart 관련
  late final Web3Client client;
  late final chainID;
  late double baitPrice;

  final RxString deviceID = "".obs;

  late DeployedContract dAppContract;
  late DeployedContract baitContract;
  late DeployedContract ggnzContract;
  late DeployedContract eggContract;
  late DeployedContract miscContract;
  late DeployedContract otpContract;

  int gogIndex = 1;
  int gopIndex = 2;
  int ocnzIndex = 3;

  late final bool isWalletExist;

  // get data from firestore
  final firestore.FirebaseFirestore db = firestore.FirebaseFirestore.instance;

  RxDouble klay = 0.0.obs;
  RxDouble gog = 0.0.obs;
  RxDouble gop = 0.0.obs;
  RxDouble ocnz = 0.0.obs;
  RxDouble bait = 0.0.obs;
  RxDouble ggnz = 0.0.obs;
  RxDouble maxHealth = 0.0.obs;

  final gogImageUrls = [].obs;
  final gopImageUrls = [].obs;
  final ocnzImageUrls = [].obs;
  final ocnzInfo = {}.obs;

  final RxList woodBoxTime = [].obs;
  final RxList continueTime = [].obs;

  /// 지갑 주소
  RxString walletAddress = "".obs;
  RxMap keystoreFile = {}.obs;

  /// 환경게이지
  RxDouble environmentLevel = 360.0.obs;
  double environmentBad = 240.0;
  double environmentNormal = 480.0;
  double environmentGood = 600.0;

  /// 건강도 (건강도는 전역으로 가지고 있다 새롭게 play 버튼을 누르면 사라지게 작업?)
  RxDouble healthLevel = 0.0.obs;

  final RxMap itemUsed = {}.obs;
  final RxMap getReward = {}.obs;
  final RxMap collectingReward = {}.obs;
  // final collectingViewController = Get.find<CollectingViewController>();
  // final missionViewController = Get.find<MissionViewController>();

  // late final mainTimer timer;

  @override
  void onInit() {
    chainID = getChainID(mode);
    client = getClient(mode);
    // timer = mainTimer(db);

    super.onInit();
  }

  Future<bool> getInitialValue() async {
    dAppContract = await getContract('assets/${mode}/OlchaeneezDAppControllerABI.json');
    baitContract = await getContract('assets/${mode}/OlchaeneezBaitABI.json');
    ggnzContract = await getContract('assets/${mode}/GGNZ.json');
    eggContract = await getContract('assets/${mode}/OlchaeneezEggABI.json');
    miscContract = await getContract('assets/${mode}/OlchaeneezMiscABI.json');
    otpContract = await getContract('assets/${mode}/OlchaeneezOfThePlanetABI.json');

    try {
      if (walletAddress.value != "") {
        // if (mode == "abis") {
        await getGogGop();
        await checkErrorLength(db);
        deviceID.value = await getDeviceInfo();
        // }

        await getWalletCoinBalance(["KLAY", "BAIT", "GGNZ"]);
        await getEggs(List.generate(3, (index) => BigInt.from(index + 1)));
        await getItems(List.generate(20, (index) => BigInt.from(index + 1)));

        // await getCollectionData();
        // await getDailyMissionData();

        final response = await client.call(
            contract: dAppContract,
            function: dAppContract.function("ggnzRate"),
            params: []);

        baitPrice = 1 / response[0].toDouble();

        // await getFirebaseInitialData();
        // await checkCollecting();

        return true;
      }
    } catch (e) {
       await appendUserErrorDB(db, {
        "type": "starting application",
         "error": e.toString(),
      });
    }

    return false;
  }

  Future<bool> getItems(List<BigInt> itemIDs) async {
    List<EthereumAddress> userAddresses = List.generate(itemIDs.length,
        (index) => EthereumAddress.fromHex(walletAddress.value));

    final response = await client.call(
        contract: miscContract,
        function: miscContract.function("balanceOfBatch"),
        params: [userAddresses, itemIDs]);

    print("get items count: $response");

    for (int idx = 0; idx < itemIDs.length; idx++) {
      final id = itemIDs[idx].toInt();
      late final item;
      if (id < 3) {
        // case of ItemBoxType
        item = ItemBoxType.getById(id);
      } else {
        // case of ItemNames
        item = ItemNames.getById(id);
      }

      items.value[item.key]?["amount"] = response[0][idx].toInt();
    }
    return true;
  }

  Future<List> getEggs(List<BigInt> EggIDs) async {
    List<EthereumAddress> userAddresses = List.generate(
        EggIDs.length, (index) => EthereumAddress.fromHex(walletAddress.value));

    final response = await client.call(
        contract: eggContract,
        function: eggContract.function("balanceOfBatch"),
        params: [userAddresses, EggIDs]);

    print("get eggs count: $response");

    for (int idx = 0; idx < EggIDs.length; idx++) {
      final egg_type = EggType.getById(EggIDs[idx].toInt());
      items.value[egg_type.key]?["amount"] = response[0][idx].toInt();
    }

    return response[0];
  }

  Future<bool> getGogGop() async {
    final balance = await client.call(
        sender: EthereumAddress.fromHex(getx.walletAddress.value),
        contract: getx.dAppContract,
        function: getx.dAppContract.function("isHolder"),
        params: []);

    getx.gog.value = balance[0].toDouble();
    getx.gop.value = balance[1].toDouble();
    getx.ocnz.value = balance[2].toDouble();

    print("test gog, gop, ocnz: $balance");

    if (getx.gog.value > 0) {
      getGogImageURL();
    }

    if (getx.gop.value > 0) {
      getGopImageURL();
    }

    if (getx.ocnz.value > 0) {
      getOcnzImageURL();
    }

    return true;
  }

  Future<bool> getWalletCoinBalance(List<String> l) async {
    final userAddress = EthereumAddress.fromHex(getx.walletAddress.value);

    if (l.contains("KLAY")) {
      final klaybalance = await getx.client.getBalance(userAddress);
      getx.klay.value = klaybalance.getValueInUnit(EtherUnit.ether);
    }

    if (l.contains("BAIT")) {
      getx.bait.value = (await getx.client.call(
              sender: userAddress,
              contract: getx.baitContract,
              function: getx.baitContract.function("balanceOf"),
              params: [userAddress, BigInt.one]))[0]
          .toDouble();
    }

    if (l.contains("GGNZ")) {
      getx.ggnz.value = (await getx.client.call(
                  sender: userAddress,
                  contract: getx.ggnzContract,
                  function: getx.ggnzContract.function("balanceOf"),
                  params: [userAddress]))[0]
              .toDouble() /
          pow(10, 18);
    }

    return true;
  }

  /*
  Future<void> getFirebaseInitialData() async {
    await db.collection(getUserCollectionName(mode))
        .doc(walletAddress.value)
        .get()
        .then((doc) async {
      if (doc.exists) {
        environmentLevel.value = doc.data()!["environmentLevel"] != null
            ? (doc.data()!["environmentLevel"].toDouble())
            : 360.0;

        if (doc.data()!["woodBoxTime"] != null) {
          woodBoxTime.value = doc.data()!["woodBoxTime"];
        }
        if (doc.data()!["continueTime"] != null) {
          continueTime.value = doc.data()!["continueTime"];
        }
        if (doc.data()!["itemUsed"] != null) {
          itemUsed.value = doc.data()!["itemUsed"];
        }
        if (doc.data()!["getReward"] != null) {
          getReward.value = doc.data()!["getReward"];
        }
      } else {
        await db
            .collection(getUserCollectionName(mode))
            .doc(getx.walletAddress.value)
            .set({
          "environmentLevel": 360.0,
          "woodBoxTime": [],
          "continueTime": [],
          "itemUsed": {},
          "getReward": {},
        });
      }

      timer.updateAll();
    });
  }

  Future<void> getCollectionData() async {
    await db.collection("collection").orderBy("id").get().then((querySnapshot) {
      collectingViewController.collectings.value = [];

      for (var docSnapshot in querySnapshot.docs) {
        final data = docSnapshot.data();
        final require = collectingViewController.getRequire(data["mission"]);

        collectingViewController.collectings.value.add({
          "title": data["name"],
          "content": data["content"],
          "require": require,
          "current": 0,
          "mission": data["mission"],
          "reward": data["reward"],
          "rewards": collectingViewController.getRewardsList(data["reward"]),
        });
      }

      collectingViewController.collectings.value.add(
          {'title': '', 'content': '', "require": 1, "current": 1, "rewards": []}
      );
    });
  }

  Future<void> checkCollecting() async {
    collectingReward.value = {
      "health": 0,
      "environment": 0,
    };

    for (var collecting in collectingViewController.collectings.value) {
      if (collecting["mission"] != null) {
        int current = collectingViewController.getCurrent(collecting["mission"]);
        collecting["current"] = current;

        if (collecting["require"] == current) {
          (collecting["reward"]! as Map).forEach((key, value) {
            collectingReward.value[key] += value;
          });
        }
      }
    }

    collectingViewController.getCollectings();
    collectingViewController.showSelectedOptions();
  }

  Future<void> getDailyMissionData() async {
    await db.collection("mission").orderBy("id").get().then((querySnapshot) {
      missionViewController.missions = [];

      for (var docSnapshot in querySnapshot.docs) {
        final data = docSnapshot.data();
        final int require = missionViewController.getRequire(data["mission"]);

        missionViewController.missions.add({
          "title": "",
          "id": data["id"],
          "content": data["content"],
          "complete_max_count": require,
          "complete_count": 0,
          "mission": data["mission"],
          "mission_type": missionViewController.getMissionType(data["type"]),
          "rewards": data["rewards_text"],
          "rewards_id": data["rewards_id"],
          "rewards_image": 'assets/iron_box.png',
          "isGetRewards": false
        });
      }
    });
  }
  */

  int getItemUsedCount(String id) {
    if (itemUsed.value[id] != null) {
      return itemUsed.value[id]!;
    } else {
      return 0;
    }
  }

  void getGogImageURL() async {
    final gog = await client.call(
        sender: EthereumAddress.fromHex(getx.walletAddress.value),
        contract: getx.dAppContract,
        function: getx.dAppContract.function("tokenByIndexies"),
        params: [
          BigInt.from(gogIndex),
          BigInt.from(0),
          BigInt.from(getx.gog.value),
          EthereumAddress.fromHex(getx.walletAddress.value),
        ]);

    List<String> parsedGog = List.from(gog);
    gogImageUrls.value = [];

    if (parsedGog.isNotEmpty) {
      final gogTokenIDs = parsedGog[0]
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((gogTokenID) => int.parse(gogTokenID))
          .toList();
      final gogImages = gogTokenIDs
          .map((tokenID) =>
              'https://gaeguneez-v1.s3.ap-northeast-2.amazonaws.com/${tokenID}.png')
          .toList();

      if (gogImages.isNotEmpty) {
        getx.gogImageUrls.addAll(gogImages);
      }
    }
  }

  void getGopImageURL() async {
    final gop = await client.call(
        sender: EthereumAddress.fromHex(getx.walletAddress.value),
        contract: getx.dAppContract,
        function: getx.dAppContract.function("tokenByIndexies"),
        params: [
          BigInt.from(gopIndex),
          BigInt.from(0),
          BigInt.from(getx.gop.value),
          EthereumAddress.fromHex(getx.walletAddress.value),
        ]);

    List<String> parsedGop = List.from(gop);
    gopImageUrls.value = [];

    if (parsedGop.isNotEmpty) {
      final gopTokenIDs = parsedGop[0]
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((gopTokenID) => int.parse(gopTokenID))
          .toList();
      final gopImages = gopTokenIDs
          .map((tokenID) =>
              'https://gaeguneez-v2.s3.ap-northeast-2.amazonaws.com/${tokenID}.png')
          .toList();

      if (gopImages.isNotEmpty) {
        getx.gopImageUrls.addAll(gopImages);
      }
    }
  }

  void getOcnzImageURL() async {
    final ocnz = await client.call(
        sender: EthereumAddress.fromHex(getx.walletAddress.value),
        contract: getx.dAppContract,
        function: getx.dAppContract.function("tokenByIndexies"),
        params: [
          BigInt.from(ocnzIndex),
          BigInt.from(0),
          BigInt.from(getx.ocnz.value),
          EthereumAddress.fromHex(getx.walletAddress.value),
        ]);

    List<String> parsedOcnz = List.from(ocnz);
    ocnzImageUrls.value = [];

    if (parsedOcnz.isNotEmpty) {
      final ocnzTokenIDs = parsedOcnz[0]
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((ocnzTokenID) => int.parse(ocnzTokenID))
          .toList();

      await db.collection(getx.mode == "abis"? "nft": "nft_test")
          .where(TOKEN_ID, whereIn: ocnzTokenIDs)
          .where(HEALTH, isGreaterThanOrEqualTo: 0)
          .get().then((querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          final data = docSnapshot.data();
          ocnzInfo[data['image']] = data['health'];
          ocnzImageUrls.value.add(data['image']);
        }
      });
    }
  }

  /// 지갑 내 아이템
  RxMap<String, Map<String, dynamic>> items = RxMap({
    ItemNames.pillS.key: {
      "imageUrl": ItemNames.pillS.imageUrl,
      "name": ItemNames.pillS.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.count.name,
      "abilityCount": 30.0,
      'inventoryItemDescription': '${ItemNames.pillS.key} Description',
      "tokenID": ItemNames.pillS.tokenID,
    },
    ItemNames.pillM.key: {
      "imageUrl": ItemNames.pillM.imageUrl,
      "name": ItemNames.pillM.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.count.name,
      "abilityCount": 60.0,
      'inventoryItemDescription': '${ItemNames.pillM.key} Description',
      "tokenID": ItemNames.pillM.tokenID,
    },
    ItemNames.pillL.key: {
      "imageUrl": ItemNames.pillL.imageUrl,
      "name": ItemNames.pillL.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.count.name,
      "abilityCount": 100.0,
      'inventoryItemDescription': '${ItemNames.pillL.key} Description',
      "tokenID": ItemNames.pillL.tokenID,
    },
    ItemNames.drinkS.key: {
      "imageUrl": ItemNames.drinkS.imageUrl,
      "name": ItemNames.drinkS.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.count.name,
      "abilityCount": 30.0,
      'inventoryItemDescription': '${ItemNames.drinkS.key} Description',
      "tokenID": ItemNames.drinkS.tokenID,
    },
    ItemNames.drinkM.key: {
      "imageUrl": ItemNames.drinkM.imageUrl,
      "name": ItemNames.drinkM.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.count.name,
      "abilityCount": 50.0,
      'inventoryItemDescription': '${ItemNames.drinkM.key} Description',
      "tokenID": ItemNames.drinkM.tokenID,
    },
    ItemNames.drinkL.key: {
      "imageUrl": ItemNames.drinkL.imageUrl,
      "name": ItemNames.drinkL.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.count.name,
      "abilityCount": 100.0,
      'inventoryItemDescription': '${ItemNames.drinkL.key} Description',
      "tokenID": ItemNames.drinkL.tokenID,
    },
    ItemNames.purifierAir.key: {
      "imageUrl": ItemNames.purifierAir.imageUrl,
      "name": ItemNames.purifierAir.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 10.0,
      'durability': 15.0,
      'inventoryItemDescription': '${ItemNames.purifierAir.key} Description',
      "tokenID": ItemNames.purifierAir.tokenID,
    },
    ItemNames.purifierVita.key: {
      "imageUrl": ItemNames.purifierVita.imageUrl,
      "name": ItemNames.purifierVita.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 20.0,
      'durability': 15.0,
      'inventoryItemDescription': '${ItemNames.purifierVita.key} Description',
      "tokenID": ItemNames.purifierVita.tokenID,
    },
    ItemNames.purifierBoyang.key: {
      "imageUrl": ItemNames.purifierBoyang.imageUrl,
      "name": ItemNames.purifierBoyang.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 30.0,
      'durability': 10.0,
      'inventoryItemDescription': '${ItemNames.purifierBoyang.key} Description',
      "tokenID": ItemNames.purifierBoyang.tokenID,
    },
    ItemNames.purifierCureAll.key: {
      "imageUrl": ItemNames.purifierCureAll.imageUrl,
      "name": ItemNames.purifierCureAll.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 80.0,
      'durability': 5.0,
      'inventoryItemDescription':
          '${ItemNames.purifierCureAll.key} Description',
      "tokenID": ItemNames.purifierCureAll.tokenID,
    },
    ItemNames.purifierImmortality.key: {
      "imageUrl": ItemNames.purifierImmortality.imageUrl,
      "name": ItemNames.purifierImmortality.key,
      "amount": 0,
      'itemTo': ItemTo.health.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 120.0,
      'durability': 5.0,
      'inventoryItemDescription':
          '${ItemNames.purifierImmortality.key} Description',
      "tokenID": ItemNames.purifierImmortality.tokenID,
    },
    ItemNames.motor.key: {
      "imageUrl": ItemNames.motor.imageUrl,
      "name": ItemNames.motor.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 20.0,
      'durability': 15.0,
      'inventoryItemDescription': '${ItemNames.motor.key} Description',
      "tokenID": ItemNames.motor.tokenID,
    },
    ItemNames.motorRemodel.key: {
      "imageUrl": ItemNames.motorRemodel.imageUrl,
      "name": ItemNames.motorRemodel.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 40.0,
      'durability': 15.0,
      'inventoryItemDescription': '${ItemNames.motorRemodel.key} Description',
      "tokenID": ItemNames.motorRemodel.tokenID,
    },
    ItemNames.motorBlack.key: {
      "imageUrl": ItemNames.motorBlack.imageUrl,
      "name": ItemNames.motorBlack.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 60.0,
      'durability': 10.0,
      'inventoryItemDescription': '${ItemNames.motorBlack.key} Description',
      "tokenID": ItemNames.motorBlack.tokenID,
    },
    ItemNames.motorDash.key: {
      "imageUrl": ItemNames.motorDash.imageUrl,
      "name": ItemNames.motorDash.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 80.0,
      'durability': 5.0,
      'inventoryItemDescription': '${ItemNames.motorDash.key} Description',
      "tokenID": ItemNames.motorDash.tokenID,
    },
    ItemNames.motorGoldBlack.key: {
      "imageUrl": ItemNames.motorGoldBlack.imageUrl,
      "name": ItemNames.motorGoldBlack.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 100.0,
      'durability': 5.0,
      'inventoryItemDescription': '${ItemNames.motorGoldBlack.key} Description',
      "tokenID": ItemNames.motorGoldBlack.tokenID,
    },
    ItemNames.motorPlazmaDash.key: {
      "imageUrl": ItemNames.motorPlazmaDash.imageUrl,
      "name": ItemNames.motorPlazmaDash.key,
      "amount": 0,
      'itemTo': ItemTo.environment.name,
      'abilityType': ItemAbilityType.percent.name,
      "abilityCount": 120.0,
      'durability': 5.0,
      'inventoryItemDescription':
          '${ItemNames.motorPlazmaDash.key} Description',
      "tokenID": ItemNames.motorPlazmaDash.tokenID,
    },
    ItemNames.OCNZMint.key: {
      "imageUrl": ItemNames.OCNZMint.imageUrl,
      "name": ItemNames.OCNZMint.key,
      "amount": 0,
      'itemTo': '',
      'abilityType': ItemAbilityType.mint.name,
      "abilityCount": 0,
      'inventoryItemDescription': '${ItemNames.OCNZMint.key} Description',
      "tokenID": ItemNames.OCNZMint.tokenID,
    },
    "egg": {
      "imageUrl": EggType.egg.imageUrl,
      "name": EggType.egg.name,
      'abilityType': ItemAbilityType.egg.name,
      "eggID": EggType.egg.eggID,
      "amount": 0,
    },
    "eggSpecial": {
      "imageUrl": EggType.eggSpecial.imageUrl,
      "name": EggType.eggSpecial.name,
      'abilityType': ItemAbilityType.egg.name,
      "eggID": EggType.eggSpecial.eggID,
      "amount": 0,
    },
    "eggPremium": {
      "imageUrl": EggType.eggPremium.imageUrl,
      "name": EggType.eggPremium.name,
      'abilityType': ItemAbilityType.egg.name,
      "eggID": EggType.eggPremium.eggID,
      "amount": 0,
    },
    ItemBoxType.woodRandomBox.key: {
      "imageUrl": ItemBoxType.woodRandomBox.imageUrl,
      "name": ItemBoxType.woodRandomBox.key,
      'abilityType': ItemAbilityType.itembox.name,
      "amount": 0,
      'inventoryItemDescription':
          '${ItemBoxType.woodRandomBox.key} Description',
      "tokenID": ItemBoxType.woodRandomBox.tokenID,
    },
    // ItemBoxType.ironRandomBox.key: {
    //   "imageUrl": ItemBoxType.ironRandomBox.imageUrl,
    //   "name": ItemBoxType.ironRandomBox.key,
    //   'abilityType': ItemAbilityType.itembox.name,
    //   "amount": 0,
    //   'inventoryItemDescription':
    //       '${ItemBoxType.ironRandomBox.key} Description',
    // "tokenID": ItemBoxType.ironRandomBox.tokenID,
    // },
  });

  late Web3PrivateKey credentials;
  RxDouble volume = 100.0.obs;
  RxInt environmentTime = 0.obs;
  RxBool isBackground = false.obs;
}

final getx = Get.put(ReactiveCommonController());
