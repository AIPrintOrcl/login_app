import 'dart:isolate';

import 'package:ggnz/web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

Web3Client getClient(String mode) {
  final String rpcURL = mode == "abis"? "https://public-node-api.klaytnapi.com/v1/cypress":
  "https://api.baobab.klaytn.net:8651";
  final String wsUrl = mode == "abis"? "wss://public-node-api.klaytnapi.com/v1/cypress/ws":
  "wss://public-node-api.klaytnapi.com/v1/baobab/ws";
  final int chainID = getChainID(mode);

  return Web3Client(rpcURL, Client(), socketConnector: () {
    return IOWebSocketChannel.connect(wsUrl).cast<String>();
  });
}

int getChainID(String mode) {
  return mode == "abis"? 8217 : 1001;
}

String getUserCollectionName(String mode) {
  return mode == "abis"? "users": "users_test";
}

String getMagicWord(String mode) {
  return mode == "abis"? "neeznFirstDapp_Olchaeneez": "123";
}

Web3PrivateKey getCredentials(BigInt i) {
  return Web3PrivateKey.fromInt(i);
}

Future<bool> waitForResult(int millisec) async {
  await Future.delayed(Duration(milliseconds: millisec), () => {print("wait for result")});
  return true;
}

Future<DeployedContract> getContract(String filename) async {
  String jsonData = await rootBundle.loadString(filename);
  final jsonResponse = json.decode(jsonData);

  return DeployedContract(
      ContractAbi.fromJson(jsonData, "DAppController"),
      EthereumAddress.fromHex(jsonResponse["contractAddress"])
  );
}

void showSnackBar(s) {
  if (s != '') {
    Get.snackbar('${Get.arguments}', '',
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
        backgroundColor: HexColor('#2E0C0C').withOpacity(0.7),
        duration: const Duration(seconds: 2),
        titleText: Center(
            child: Text(s,
                style: TextStyle(
                  fontFamily: 'ONE_Mobile_POP_OTF',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ))));
  }
}