import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

import 'package:go_together/helper/date_extension.dart';
import 'package:go_together/models/messages.dart';
import 'package:go_together/usecase/message.dart';
import 'package:go_together/usecase/user.dart';

void main() {

  final MessageUseCase messageUseCase = MessageUseCase();
  final UserUseCase userUseCase = UserUseCase();
  late String token1;
  late String token2;
  late String tokenExt;
  late List<Message> messagesList;

  final idMainConversation = 1;

  setUpAll(() async{
    token1 = await userUseCase.getJWTTokenByGoogleToken("someGoogleToken");
    token2 = await userUseCase.getJWTTokenByLogin({"mail":"gwenael.mw@orange.fr", "password":"somePa\$\$w0rd"}); //somePa$$w0rd
    tokenExt = await userUseCase.getJWTTokenByLogin({"mail":"someMail6@gmail.com", "password":"somePa\$\$w0rd"}); //somePa$$w0rd

    userUseCase.api.api.setToken(token1);
  }) ;

  group('API Tchat', (){
    test('get messages from api for conversation 1 with account inside main conversation', () async {
      messageUseCase.api.api.setToken(token1);
      final messagesUser1 = await messageUseCase.getById(idMainConversation);

      messageUseCase.api.api.setToken(token2);
      final messagesUser2 = await messageUseCase.getById(idMainConversation);

      //@todo check message signature, and try decrypt each message + add corresponding test
      if(messagesUser1.isNotEmpty){
        expect(messagesUser1[0].idReceiver, 1);
        expect(messagesUser2[0].idReceiver, 2);
      }
      expect(messagesUser1.length, messagesUser2.length);
    });

    test('get messages from api for conversation 1 with 1 account outside main conversation', () async {
      messageUseCase.api.api.setToken(token1);
      final messagesUser1 = await messageUseCase.getById(idMainConversation);

      messageUseCase.api.api.setToken(tokenExt);
      final messagesUser2 = await messageUseCase.getById(idMainConversation);
      
      //@todo check message signature, and try decrypt each message + add corresponding test
      if(messagesUser1.isNotEmpty){
        expect(messagesUser1[0].idReceiver, 1);
      }
      expect(messagesUser2.length, 0);
    });

    test('add message with user 1', () async{
      messageUseCase.api.api.setToken(token1);
      final conversation = await messageUseCase.getConversationById(idMainConversation);
      String message = "this is test message from flutter";
      List<Message> listMessage = [];
      conversation.forEach((element) {
        listMessage.add(Message(id: 0, bodyMessage: message, idReceiver: element.userId, idSender: 1, createdAt: DateTime.now()));
      });

      final messageSend = await messageUseCase.add(idMainConversation, listMessage);
      debugPrint(messageSend.toString());

      //@todo decrypte, check signature and add corresponding expectation
      expect(messageSend.idReceiver, 1);
      expect(messageSend.idSender, 1);
    });

  });
}


