import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:go_together/helper/api.dart';
import 'package:go_together/helper/asymetric_key.dart';

import 'package:go_together/models/conversation.dart';
import 'package:go_together/models/messages.dart';
import 'package:go_together/usecase/message.dart';
import 'package:go_together/usecase/user.dart';

void main() {

  final MessageUseCase messageUseCase = MessageUseCase();
  final UserUseCase userUseCase = UserUseCase();
  late String token1;
  late String token2;
  late String tokenExt;

  late String pubKey1;
  late String pubKey2;
  late String pubKeyExt;
  late String privateKey1;
  late String privateKey2;
  late String privateKeyExt;

  final idMainConversation = 1;
  late List<Conversation> conversation ;

  setUpAll(() async{
    //region generate token for 3 different user
    token1 = await userUseCase.getJWTTokenByGoogleToken("someGoogleToken");
    token2 = await userUseCase.getJWTTokenByLogin({"mail":"gwenael.mw@orange.fr", "password":"somePa\$\$w0rd"}); //somePa$$w0rd
    tokenExt = await userUseCase.getJWTTokenByLogin({"mail":"someMail6@gmail.com", "password":"somePa\$\$w0rd"}); //somePa$$w0rd
    //endregion

    //region get key  pair for 3 user
    AsymetricKeyGenerator keyGenerator = AsymetricKeyGenerator();
    //keyGenerator.generateKey();
    pubKey1 = keyGenerator.getPubKeyFromStorage();
    privateKey1 = keyGenerator.getPrivateKeyFromStorage();

    keyGenerator.setId("2");
    pubKey2 = keyGenerator.getPubKeyFromStorage();
    privateKey2 = keyGenerator.getPrivateKeyFromStorage();

    keyGenerator.setId("ext");
    pubKeyExt = keyGenerator.getPubKeyFromStorage();
    privateKeyExt = keyGenerator.getPubKeyFromStorage();
    //endregion

    //region then set pubkey
    userUseCase.api.api.setToken(token1);
    await userUseCase.setPublicKey(pubKey1);
    userUseCase.api.api.setToken(token2);
    await userUseCase.setPublicKey(pubKey2);
    userUseCase.api.api.setToken(tokenExt);
    await userUseCase.setPublicKey(pubKeyExt);
    //endregion

    messageUseCase.api.api.setToken(token1); //@required user 1 to be in the conversation
    conversation = await messageUseCase.getConversationById(idMainConversation);
  }) ;


  String getUserPubKeyFromConversation(List<Conversation> conv, int idUser){
    String pubKey = "";
    conv.forEach((element) {
      if(element.userId == idUser){
        pubKey = element.pubKey;
      }
    });
    return pubKey;
  }

  group('API Tchat', (){
    test('get messages from api for conversation 1 with account inside main conversation', () async {
      messageUseCase.api.api.setToken(token1);
      final messagesUser1 = await messageUseCase.getById(idMainConversation);

      messageUseCase.api.api.setToken(token2);
      final messagesUser2 = await messageUseCase.getById(idMainConversation);

      if(messagesUser1.isNotEmpty){
        expect(messagesUser1[0].idReceiver, 1);
        String pubKeyUser1 = getUserPubKeyFromConversation(conversation, messagesUser1[0].idReceiver);
        expect(pubKeyUser1, pubKey1);
      }

      if(messagesUser2.isNotEmpty){
        expect(messagesUser2[0].idReceiver, 2);
      }
      expect(messagesUser1.length, messagesUser2.length);
    });

    test('get messages from api for conversation 1 with 1 account outside main conversation', () async {
      messageUseCase.api.api.setToken(token1);
      final messagesUser1 = await messageUseCase.getById(idMainConversation);

      //region try to get messages with user outside conversation
      messageUseCase.api.api.setToken(tokenExt);
      expect(() async => await messageUseCase.getById(idMainConversation), throwsA(
          predicate((e) => e is ApiErr && e.codeStatus == 403)
      ));
      //endregion

      if(messagesUser1.isNotEmpty){
        expect(messagesUser1[0].idReceiver, 1);
      }
    });

    test('add message with user 1, which is inside the conversation', () async{
      messageUseCase.api.api.setToken(token1);
      String message = "this is test message from flutter";

      //region generate crypted message for all user in conversation
      List<Message> listMessage = [];
      conversation.forEach((element) {
        Uint8List encryptData = encrypt(message, element.pubKey);
        listMessage.add(Message(id: 0, bodyMessage: encryptData.toString(), idReceiver: element.userId, idSender: 0, createdAt: DateTime.now()));
      });
      //endregion

      final messageSend = await messageUseCase.add(idMainConversation, listMessage);

      expect(messageSend.idReceiver, 1);
      expect(messageSend.idSender, 1);

      //region decrypt for user 1
      String decryptedMsg = decryptFromString(messageSend.bodyMessage, privateKey1);
      expect(decryptedMsg, message);
      expect(privateKey1, isNot(equals(privateKey2)));
      //endregion

      //@todo should test to decrypt with privateKey2 and should fail. need to handling error
      //String decryptedMsg2 = decryptFromString( messageSend.bodyMessage, privateKey2);
      //debugPrint(decryptedMsg2);
      //expect(decryptedMsg2, isNot(equals(message)));

      //@todo check signature
    });

  });

  test('try add message with a user out of the conversation', () async{
    messageUseCase.api.api.setToken(tokenExt);
    String message = "this is a message from a user out of conversation";

    List<Message> listMessage = [];
    conversation.forEach((element) {
      Uint8List encryptData = encrypt(message, element.pubKey);
      listMessage.add(Message(id: 0, bodyMessage: encryptData.toString(), idReceiver: element.userId, idSender: 0, createdAt: DateTime.now()));
    });

    expect(() async => await messageUseCase.add(idMainConversation, listMessage), throwsA(
        predicate((e) => e is ApiErr && e.codeStatus == 403) // because only user in conversation can add new message
    ));
  });

/*
  test('read message with user 1 encrypted for user 1', () async{
      messageUseCase.api.api.setToken(token1);
      final messagesUser1 = await messageUseCase.getById(idMainConversation);

  });

  test('read message with user 1 encrypted for user 2', () async{

  });*/
}


