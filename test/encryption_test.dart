import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_together/helper/asymetric_key.dart';

//use ==> debugPrint("your msg here"); if you want to print data for test
void main() {
  late AsymmetricKeyGenerator keyGenerator;
  const String MESSAGE = "this is test message from flutter";

  setUpAll(() async{
    keyGenerator = AsymmetricKeyGenerator();
    keyGenerator.generateKey();
  }) ;

  group("Encryption - key pair", (){
    test("Generate key pair - public key can't be greater than private key", () async{
      String pubKey = keyGenerator.getPubKeyFromStorage();
      String privateKey = keyGenerator.getPrivateKeyFromStorage();
      expect(privateKey.length, greaterThan(pubKey.length));
    });

    test("Crypt and decrypt message with key pair", () async{
      Uint8List encryptData = encrypt(MESSAGE, keyGenerator.getPubKeyFromStorage());
      String decryptedMsg = decrypt(encryptData, keyGenerator.getPrivateKeyFromStorage());
      expect(MESSAGE, isNot(equals(encryptData)));
      expect(MESSAGE, decryptedMsg);
    });

    /*test('try to crypt and sign a message, then decrypt and check signature of message with Good key', () async{
      String message = "this is test message from flutter";
      String privateKey = keyGenerator.getPrivateKeyFromStorage();
      String pubKey = keyGenerator.getPubKeyFromStorage();

      Uint8List encryptData = encrypt(MESSAGE, pubKey);
      Uint8List signature = rsaSignFromKeyString(privateKey, encryptData);
      String cryptedMessageSigned = addSignature(encryptData.toString(), signature.toString());
      //endregion

      Map<String,String> map = splitSignedAndCryptedMessage(cryptedMessageSigned);
      String decryptedMsg = decryptFromString(map["encryptedMsg"]!, privateKey);
      rsaVerifyFromKeyStringAndStringBytes(pubKey, map["encryptedMsg"]!, map["signature"]!);

      expect(MESSAGE, decryptedMsg);
      expect(signature.toString(), map["signature"]!);
    });
*/
    /*test('try to crypt and sign a message, then decrypt and check signature of message with bad key', () async{
      String message = "this is test message from flutter";
      String privateKey = keyGenerator.getPrivateKeyFromStorage();
      String pubKey = keyGenerator.getPubKeyFromStorage();

      Uint8List encryptData = encrypt(MESSAGE, pubKey);
      Uint8List signature = rsaSignFromKeyString(privateKey, encryptData);
      String cryptedMessageSigned = addSignature(encryptData.toString(), signature.toString());
      //endregion

      //region generate another key
      keyGenerator.setId("2"); // since id is changed, another key should be created
      String pubKey2 = keyGenerator.getPubKeyFromStorage();
      String privateKey2 = keyGenerator.getPrivateKeyFromStorage();
      //endregion

      Map<String,String> map = splitSignedAndCryptedMessage(cryptedMessageSigned);
      expect(() => decryptFromString(map["encryptedMsg"]!, privateKey2), throwsA(isA<EncryptionErr>()));
      //expect an error because trying to decrypt msg with a bad keys, causing error in rsaDecrypt
    });
*/
  });
}


