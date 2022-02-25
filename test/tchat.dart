import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
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
    token1 = await userUseCase.getJWTTokenByGoogleToken("eyJhbGciOiJSUzI1NiIsImtpZCI6ImNmNWQ4ZTc0ZjNjNDg2ZWU1MDNkNWVlYzkzYTEwMWM2NGJhY2Y3ZGEiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiTHVjYXMgREEgU0lMVkEgTUFSUVVFUyIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BQVRYQUp5UHdBRUFoSzNNWnJsSkR5dUhwOGxJZ2t5bllOR2dyMnpJM2g3Sz1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9nby10b2dldGhlci00ODc5ZiIsImF1ZCI6ImdvLXRvZ2V0aGVyLTQ4NzlmIiwiYXV0aF90aW1lIjoxNjQ1NzE0OTQwLCJ1c2VyX2lkIjoiY3BGV0xpb0MwUGJGcWo0WU5yVTA3UkFBR1d5MSIsInN1YiI6ImNwRldMaW9DMFBiRnFqNFlOclUwN1JBQUdXeTEiLCJpYXQiOjE2NDU3MTQ5NDAsImV4cCI6MTY0NTcxODU0MCwiZW1haWwiOiJsdWNhcy5kYS1zaWx2YS1tYXJxdWVzQGVkdS5lc2llZS1pdC5mciIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7Imdvb2dsZS5jb20iOlsiMTEzNzQ5NjYzODQ4NjgxMzEwNjEzIl0sImVtYWlsIjpbImx1Y2FzLmRhLXNpbHZhLW1hcnF1ZXNAZWR1LmVzaWVlLWl0LmZyIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.YQhwgl90YzTkd5XO27wdYayq7sp6pZZAm3jJk12moBHK7XOomdqIop9GGDnCFHcebdNOa06s5HrJyFiwXryR06yhhsc6EY5AzRFAGI2UBGfrVrfXNq9HtQE_sjAZvb3pe4-XT3RrYrWMaonxv80F");
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

  group('get messages from api for conversation 1', () {
    test('with 1 account inside main conversation', () async {
      messageUseCase.api.api.setToken(token1);
      final messagesUser1 = await messageUseCase.getById(idMainConversation);

      if (messagesUser1.isNotEmpty) {
        expect(messagesUser1[0].idReceiver, 1);
        String pubKeyUser1 = getUserPubKeyFromConversation(
            conversation, messagesUser1[0].idReceiver);
        expect(pubKeyUser1, pubKey1);
      }
    });

    test('with 1 account outside main conversation', () async {
      messageUseCase.api.api.setToken(tokenExt);
      expect(() async => await messageUseCase.getById(idMainConversation),
          throwsA(
              predicate((e) => e is ApiErr && e.codeStatus == 403)
          ));
    });

    test('with 2 accounts inside main conversation', () async {
      messageUseCase.api.api.setToken(token1);
      final messagesUser1 = await messageUseCase.getById(idMainConversation);

      messageUseCase.api.api.setToken(token2);
      final messagesUser2 = await messageUseCase.getById(idMainConversation);

      if (messagesUser1.isNotEmpty) {
        expect(messagesUser1[0].idReceiver, 1);
        String pubKeyUser1 = getUserPubKeyFromConversation(
            conversation, messagesUser1[0].idReceiver);
        expect(pubKeyUser1, pubKey1);
      }

      if (messagesUser2.isNotEmpty) {
        expect(messagesUser2[0].idReceiver, 2);
      }
      expect(messagesUser1.length, messagesUser2.length);
    });
  });

  group('add message in api for conversation 1 Tchat', (){
    //@todo : api should check if message is encrypted before add in DB, that will required one more test then
    test('with user 1, which is inside the conversation', () async{
      //get number of message before inserting a new one
      messageUseCase.api.api.setToken(token1);
      final messagesUser1 = await messageUseCase.getById(idMainConversation);

      String message = "this is test message from flutter";

      //region generate crypted message for all user in conversation
      List<Message> listMessage = [];
      conversation.forEach((element) {
        Uint8List encryptData = encrypt(message, element.pubKey);
        Uint8List signature = rsaSignFromKeyString(privateKey1, encryptData);
        String cryptedMessageSigned = addSignature(encryptData.toString(), signature.toString());
        listMessage.add(Message(id: 0, bodyMessage: cryptedMessageSigned, idReceiver: element.userId, idSender: 0, createdAt: DateTime.now()));
      });
      //endregion

      final messageSend = await messageUseCase.add(idMainConversation, listMessage);
      Map<String,String> map = splitSignedAndCryptedMessage(messageSend.bodyMessage);
      String messageBody = map["encryptedMsg"]!;
      expect(messageSend.idReceiver, 1);
      expect(messageSend.idSender, 1);

      //region decrypt for user 1
      String decryptedMsg = decryptFromString(messageBody, privateKey1);
      expect(decryptedMsg, message);
      expect(privateKey1, isNot(equals(privateKey2)));
      //endregion

      //@todo should test to decrypt with privateKey2 and should fail. need to handling error
      //String decryptedMsg2 = decryptFromString( messageSend.bodyMessage, privateKey2);
      //debugPrint(decryptedMsg2);
      //expect(decryptedMsg2, isNot(equals(message)));

      rsaVerifyFromKeyStringAndStringBytes(pubKey1, messageBody, map["signature"]!);

      //check if there is one message more in DB now
      final messagesUser1After = await messageUseCase.getById(idMainConversation);
      expect(messagesUser1.length +1 , equals(messagesUser1After.length));
    });

    test('try add message with a user out of the conversation', () async{
      //get number of message before inserting a new one
      messageUseCase.api.api.setToken(token1);
      final messagesUser1 = await messageUseCase.getById(idMainConversation);

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

      //check if there is same number of message in DB than before trying to add
      messageUseCase.api.api.setToken(token1);
      final messagesUser1After = await messageUseCase.getById(idMainConversation);
      expect(messagesUser1.length, equals(messagesUser1After.length));
    });
  });
}


