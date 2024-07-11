import 'package:get/get.dart';

enum ItemNames {
  pillS('Clean Pill', '깨끗하게 정화제', "assets/market/pills_s.png", 6),
  pillM('Clear Pill', '맑게 정화제', "assets/market/pills_m.png", 7),
  pillL('Clean&Clear Packet', '자신있게 정화제', "assets/market/pills_l.png", 8),
  drinkS('Vitamin Ade', '비타민 에이드', "assets/market/drink_s.png", 3),
  drinkM('Taurine Ade', '타우린 에이드', "assets/market/drink_m.png", 4),
  drinkL('Mixed Ade', '뿅뿅 에이드', "assets/market/drink_l.png", 5),
  purifierAir(
      'General Air Purifier', '일반 공기청정기', "assets/market/purifier_air.png", 9),
  purifierVita(
      'Fresh Air Purifier', '상쾌 공기청정기', "assets/market/purifier_vita.png", 10),
  purifierBoyang('Health Air Purifier', '건강 공기청정기',
      "assets/market/purifier_boyang.png", 11),
  purifierCureAll('Panacea Air Purifier', '만병통치 공기청정기',
      "assets/market/purifier_cure_all.png", 12),
  purifierImmortality('Immortal Air Purifier', '불로불사 공기청정기',
      "assets/market/purifier_immortality.png", 13),
  motor('White Motor', '화이트 모터', "assets/market/motor.png", 14),
  motorRemodel('Tuning Motor', '튜닝 모터', "assets/market/motor_remodel.png", 16),
  motorBlack('Black Motor', '블랙 모터', "assets/market/motor_black.png", 15),
  motorDash('Dash Motor', '대쉬 모터', "assets/market/motor_dash.png", 17),
  motorGoldBlack(
      'Alloy Motor', '합금 모터', "assets/market/motor_gold_black.png", 18),
  motorPlazmaDash(
      'Gold Motor', '순금 모터', "assets/market/motor_plazma_dash.png", 19),
  OCNZMint('OCNZ Mint', '올채니즈 입양', "assets/market/ocnz_mint.png", 20);

  final String key;
  final String name;
  final String imageUrl;
  final int tokenID;
  const ItemNames(this.key, this.name, this.imageUrl, this.tokenID);

  factory ItemNames.getById(int id) {
    return ItemNames.values.firstWhere((value) => value.tokenID == id);
  }
}

enum ItemBoxType {
  woodRandomBox('Wood Random Box', '나무상자', 'assets/wooden_box.png', 1),
  ironRandomBox('Iron Random Box', '철상자', 'assets/iron_box.png', 2);

  final String key;
  final String name;
  final String imageUrl;
  final int tokenID;
  const ItemBoxType(this.key, this.name, this.imageUrl, this.tokenID);

  factory ItemBoxType.getById(int id) {
    return ItemBoxType.values.firstWhere((element) => element.tokenID == id);
  }
}

enum EggType {
  egg('egg', '개구니알', 'assets/market/item_egg0.gif', 1),
  eggSpecial('eggSpecial', '특별한 개구니알', 'assets/market/item_egg1.gif', 2),
  eggPremium('eggPremium', '프리미엄 개구니알', 'assets/market/item_egg2.gif', 3);

  final String key;
  final String name;
  final String imageUrl;
  final int eggID;
  const EggType(this.key, this.name, this.imageUrl, this.eggID);

  factory EggType.getById(int id) {
    return EggType.values.firstWhere((element) => element.eggID == id);
  }
}

enum ItemTo { environment, health }

enum ItemAbilityType { count, percent, egg, itembox, mint }

enum EnvironmentState { bad, normal, good }

enum EggState { NORMAL, SPECIAL, PREMINUM }

enum BoxType { wooden, iron }
