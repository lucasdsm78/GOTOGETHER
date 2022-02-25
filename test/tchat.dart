import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:go_together/helper/api.dart';

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

  final idMainConversation = 1;
  late List<Conversation> conversation ;

  setUpAll(() async{
    token1 = await userUseCase.getJWTTokenByGoogleToken("someGoogleToken");
    token2 = await userUseCase.getJWTTokenByLogin({"mail":"gwenael.mw@orange.fr", "password":"somePa\$\$w0rd"}); //somePa$$w0rd
    tokenExt = await userUseCase.getJWTTokenByLogin({"mail":"someMail6@gmail.com", "password":"somePa\$\$w0rd"}); //somePa$$w0rd


    // generate 3 keypair, one for each user.
    //then set pubkey --> bool isUpdate = await userUseCase.setPublicKey("publicKeyHere");
    userUseCase.api.api.setToken(token1);
    bool isUpdate = await userUseCase.setPublicKey("publicKeyHere");

    messageUseCase.api.api.setToken(token1); //@required user 1 to be in the conversation
    conversation = await messageUseCase.getConversationById(idMainConversation);
  }) ;

  group('API Tchat', (){
    test('get messages from api for conversation 1 with account inside main conversation', () async {
      messageUseCase.api.api.setToken(token1);
      final messagesUser1 = await messageUseCase.getById(idMainConversation);

      messageUseCase.api.api.setToken(token2);
      final messagesUser2 = await messageUseCase.getById(idMainConversation);

      //@todo check message signature, and try decrypt each message + add corresponding test
      //expect user 1 can read messagesUser1, but not messagesUser2.
      //expect user 2 can read messagesUser2, but not messagesUser1.

      if(messagesUser1.isNotEmpty){
        expect(messagesUser1[0].idReceiver, 1);
      }
      if(messagesUser2.isNotEmpty){
        expect(messagesUser2[0].idReceiver, 2);
      }
      expect(messagesUser1.length, messagesUser2.length);
    });

    test('get messages from api for conversation 1 with 1 account outside main conversation', () async {
      messageUseCase.api.api.setToken(token1);
      final messagesUser1 = await messageUseCase.getById(idMainConversation);

      messageUseCase.api.api.setToken(tokenExt);
      // final messagesUser2 = await messageUseCase.getById(idMainConversation); //@todo maybe could return the error when failed to get data with 200 status
      expect(() async => await messageUseCase.getById(idMainConversation), throwsA(
          predicate((e) => e is ApiErr && e.codeStatus == 403)
      ));

      //@todo check message signature, and try decrypt each message + add corresponding test
      //expect user 1 can read messagesUser1, but not messagesUser2.
      //expect user 2 can read messagesUser2, but not messagesUser1.

      if(messagesUser1.isNotEmpty){
        expect(messagesUser1[0].idReceiver, 1);
      }
    });

    test('add message with user 1', () async{
      messageUseCase.api.api.setToken(token1);

      String message = "this is test message from flutter";
      //@todo encrypt message and sign it with user 1 keypair

      List<Message> listMessage = [];
      conversation.forEach((element) {
        //element.pubKey
        listMessage.add(Message(id: 0, bodyMessage: message, idReceiver: element.userId, idSender: 0, createdAt: DateTime.now()));
      });

      final messageSend = await messageUseCase.add(idMainConversation, listMessage);
      debugPrint(messageSend.toString());

      //@todo decrypte, check signature and add corresponding expectation
      expect(messageSend.idReceiver, 1);
      expect(messageSend.idSender, 1);
    });

  });

  test('add message with a user out of the conversation', () async{
    messageUseCase.api.api.setToken(tokenExt);

    String message = "this is a message from a user out of conversation";
    //@todo encrypt message and sign it with outside user keypair

    List<Message> listMessage = [];
    conversation.forEach((element) {
      //element.pubKey
      listMessage.add(Message(id: 0, bodyMessage: message, idReceiver: element.userId, idSender: 0, createdAt: DateTime.now()));
    });

    expect(() async => await messageUseCase.add(idMainConversation, listMessage), throwsA(
        predicate((e) => e is ApiErr && e.codeStatus == 403)
    ));

    //expect a refusal
  });

/*
  test('read message with user 1 encrypted for user 1', () async{
      messageUseCase.api.api.setToken(token1);
      final messagesUser1 = await messageUseCase.getById(idMainConversation);

  });

  test('read message with user 1 encrypted for user 2', () async{

  });*/
}


