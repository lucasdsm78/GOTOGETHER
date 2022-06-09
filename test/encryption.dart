import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_together/helper/asymetric_key.dart';

void main() {
  late AsymetricKeyGenerator keyGenerator;

  setUpAll(() async{
    keyGenerator = AsymetricKeyGenerator();
    keyGenerator.generateKey();
  }) ;

  group('Encryption - key pair', (){
    test('try Generate key pair', () async{
      String pubKey = keyGenerator.getPubKeyFromStorage();
      String privateKey = keyGenerator.getPrivateKeyFromStorage();
      expect(privateKey.length, greaterThan(pubKey.length));
    });

    test('try to crypt and decrypt message with key pair', () async{
      String message = "this is test message from flutter";
      Uint8List encryptData = encrypt(message, keyGenerator.getPubKeyFromStorage());
      String decryptedMsg = decrypt(encryptData, keyGenerator.getPrivateKeyFromStorage());
      expect(message, decryptedMsg);
    });

    test('try to crypt and sign a message, then decrypt and check signature of message with Good key', () async{
      String message = "this is test message from flutter";
      String privateKey = keyGenerator.getPrivateKeyFromStorage();
      String pubKey = keyGenerator.getPubKeyFromStorage();

      Uint8List encryptData = encrypt(message, pubKey);
      Uint8List signature = rsaSignFromKeyString(privateKey, encryptData);
      String cryptedMessageSigned = addSignature(encryptData.toString(), signature.toString());

      Map<String,String> map = splitSignedAndCryptedMessage(cryptedMessageSigned);
      String decryptedMsg = decryptFromString(map["encryptedMsg"]!, privateKey);
      rsaVerifyFromKeyStringAndStringBytes(pubKey, map["encryptedMsg"]!, map["signature"]!);

      expect(message, decryptedMsg);
      expect(signature.toString(), map["signature"]!);
    });

    /*test('try to crypt and sign a message, then decrypt and check signature of message with bad key', () async{
      String message = "this is test message from flutter";
      String privateKey = keyGenerator.getPrivateKeyFromStorage();
      String pubKey = keyGenerator.getPubKeyFromStorage();

      Uint8List encryptData = encrypt(message, pubKey);
      final signature = rsaSignFromKeyString(privateKey, encryptData);
      String cryptedMessageSigned = addSignature(encryptData.toString(), signature.toString());

      keyGenerator.setId("2");
      String pubKey2 = keyGenerator.getPubKeyFromStorage();
      String privateKey2 = keyGenerator.getPrivateKeyFromStorage();

      Map<String,String> map = splitSignedAndCryptedMessage(cryptedMessageSigned);
      String decryptedMsg = decryptFromString(map["encryptedMsg"]!, privateKey2);
      rsaVerifyFromKeyStringAndListInt(pubKey2, jsonDecode(map["encryptedMsg"]!).cast<int>(), jsonDecode(map["signature"]!).cast<int>());
      //@todo : expect a fail error, because bad private key. but should not crash application
    });
    */
  });
}


