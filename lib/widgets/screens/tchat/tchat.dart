import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_together/helper/asymetric_key.dart';
import 'package:go_together/helper/enum/custom_colors.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/conversation.dart';
import 'package:go_together/models/messages.dart';
import 'package:go_together/models/messages.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/usecase/message.dart';
import 'package:go_together/widgets/components/search_bar.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:go_together/models/user.dart';
import 'package:intl/intl.dart';


class Tchat extends StatefulWidget {
  //const Tchat({Key? key, conversation}) : super(key: key);
  const Tchat({Key? key}) : super(key: key);

  @override
  State<Tchat> createState() => _TchatState();
}

class _TchatState extends State<Tchat> {
  late User currentUser;
  final session = Session();
  final messageTextController = TextEditingController();
  String messageText = "";
  final MessageUseCase messageUseCase = MessageUseCase();

  final List<Message> messages = [];
  List<Conversation> conversationList = [];
  int conversationId = 1;

  late String pubKey1;
  late String privateKey1;

  @override
  void initState() {
    super.initState();
    currentUser = session.getData(SessionData.user,defaultVal: MockUser.userGwen);
    messageTextController.addListener(_updateKeywords);

    //region get key  pair for 3 user
    AsymmetricKeyGenerator keyGenerator = AsymmetricKeyGenerator();
    //keyGenerator.generateKey();
    pubKey1 = keyGenerator.getPubKeyFromStorage();
    privateKey1 = keyGenerator.getPrivateKeyFromStorage();
    //endregion

    getConversationList();
    getMessagesList();

  }

  getConversationList() async {
    List<Conversation> convList = await messageUseCase.getConversationById(conversationId);
    setState(() {
      conversationList = convList;
    });
  }

  getMessagesList() async {
    List<Message> convList = await messageUseCase.getById(conversationId);
    convList.forEach((element) {
      receiveMessage(element);
    });
  }

  @override
  void dispose() {
    messageTextController.dispose();
    super.dispose();
  }

  void _updateKeywords() {
    setState(() {
      messageText = messageTextController.text;
    });
  }


  sendMessage(String text) async {
    //region generate crypted message for all user in conversation
    List<Message> listMessage = [];
    conversationList.forEach((element) {
      Uint8List encryptData = encrypt(text, element.pubKey);
      Uint8List signature = rsaSignFromKeyString(privateKey1, encryptData);
      String cryptedMessageSigned = addSignature(encryptData.toString(), signature.toString());
      listMessage.add(Message(id: 0, bodyMessage: cryptedMessageSigned, idReceiver: element.userId, idSender: 0, createdAt: DateTime.now()));
    });
    //endregion

    final messageSend = await messageUseCase.add(conversationId, listMessage);

    //reset text input content
    messageTextController.text = "";
  }

  receiveMessage(Message message){
    // socket here

    Map<String,String> map = splitSignedAndCryptedMessage(message.bodyMessage);
    String messageBody = map["encryptedMsg"]!;
    String decryptedMsg = decryptFromString(messageBody, privateKey1);
    // check signature
    //rsaVerifyFromKeyStringAndStringBytes(pubKey1, messageBody, map["signature"]!);

    final Message finalMessage = Message(id: message.id, bodyMessage: decryptedMsg, idReceiver: message.idReceiver, idSender: message.idReceiver, createdAt: message.createdAt);
    setState(() {
      messages.add(finalMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tchat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: GroupedListView<Message, DateTime>(
                padding: const EdgeInsets.all(8),
                reverse: true,
                order: GroupedListOrder.DESC,
                useStickyGroupSeparators: true,
                floatingHeader: true,

                elements :  messages,
                groupBy: (message)=>DateTime(
                  message.createdAt!.year,
                  message.createdAt!.month,
                  message.createdAt!.day,

                ),
                groupHeaderBuilder: (Message message)=> SizedBox(
                  height: 40,
                  child: Center(
                    child:Card(
                      color: CustomColors.goTogetherMain,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          DateFormat.yMMMd().format(message.createdAt!),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  )
                ),
                itemBuilder: (context, Message message)=> Align(
                  alignment: (currentUser.id != null && message.idSender == currentUser.id 
                      ? Alignment.centerRight
                      : Alignment.centerLeft
                  ),
                  child: Card(
                    color: (currentUser.id != null && message.idSender == currentUser.id
                        ? CustomColors.goTogetherMain
                        : Colors.white
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(message.bodyMessage),
                    ),
                  ),
                )
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
      elevation: 10.0,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 43,
                decoration: BoxDecoration(
                  color: CustomColors.goTogetherMain,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child:  Container(
                  color: Colors.grey.shade300,
                  child: TextField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        hintText: "message ..."
                    ),
                    controller: messageTextController,
                    onSubmitted: (text) =>{
                      sendMessage(text)
                    },
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 25,
              ),
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: CustomColors.goTogetherMain,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send_outlined,
                  size: 25.0,
                  color: Colors.white,
                ),
                onPressed: () =>{
                  sendMessage(messageText)
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

}
