import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_together/helper/asymetric_key.dart';
import 'package:go_together/helper/enum/custom_colors.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/conversation.dart';
import 'package:go_together/models/messages.dart';
import 'package:go_together/usecase/message.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


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
  late IO.Socket socket;

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

    connectToSocket();
  }

  @override
  void dispose() {
    messageTextController.dispose();
    socket.close();
    super.dispose();
  }

  //region init
  ///Connect to socket server to update tchat message in real time.
  ///
  ///Should have used namespace to avoid sending message for all existing users.
  ///But after many hours testing different lib for socket and search how
  ///to dispatch on severall namespace / room and nothing responding to our needs,
  ///we won't use namespaces.
  void connectToSocket() {
    try {

      // Configure socket transports must be sepecified
      socket = IO.io('http://51.255.51.106:5000', <String, dynamic>{
        //'transports': ['polling'],
        'transports': ['websocket'],
        'autoConnect': false,
      });


      // Connect to websocket
      socket.connect();

      //socket.nsp = "groupe1"; // looks like namespace, but when used can't connect to socket server.

      // Handle socket events
      socket.on('connect', (_) => print('connect: ${socket.id}'));
      socket.on('messageTchat', handleMessage);
      socket.on('disconnect', (_) => print('disconnect'));
      socket.on('fromServer', (_) => print(_));

    } catch (e) {
      print(e.toString());
    }
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

  void _updateKeywords() {
    setState(() {
      messageText = messageTextController.text;
    });
  }
  //endregion


  //region handle messages
  /// Encrypt message for all user in conversation, to send it to API
  /// and save it on DB.
  /// Then reset Text input value.
  sendMessage(String text) async {
    //region generate crypted message for all user in conversation
    List<Message> listMessage = [];
    conversationList.forEach((element) {
      Uint8List encryptData = encrypt(text, element.pubKey);
      Uint8List signature = rsaSignFromKeyString(privateKey1, encryptData);
      String cryptedMessageSigned = addSignature(encryptData.toString(), signature.toString());
      listMessage.add(Message(id: 0, bodyMessage: cryptedMessageSigned, idReceiver: element.userId, idSender: 0, createdAt: DateTime.now(), senderName: currentUser.username));
    });
    //endregion

    final messageSend = await messageUseCase.add(conversationId, listMessage);

    //reset text input content
    messageTextController.text = "";
  }

  /// Decrypt received message and add the result in messageList to display
  receiveMessage(Message message){
    Map<String,String> map = splitSignedAndCryptedMessage(message.bodyMessage);
    String messageBody = map["encryptedMsg"]!;
    String decryptedMsg = decryptFromString(messageBody, privateKey1);
    // check signature
    //rsaVerifyFromKeyStringAndStringBytes(pubKey1, messageBody, map["signature"]!);

    final Message finalMessage = Message(id: message.id, bodyMessage: decryptedMsg, idReceiver: message.idReceiver, idSender: message.idSender, createdAt: message.createdAt, senderName: message.senderName);
    setState(() {
      messages.add(finalMessage);
    });
  }

  /// Used by socket
  handleMessage(dynamic data){
    Map<String, dynamic> res = data;

    if(res["room"] == conversationId && res["receiver"] == currentUser.id){
      receiveMessage( Message.fromJson(json.decode(res["msg"])));
    }
  }
  //endregion

  amISender(Message message){
    return currentUser.id != null && message.idSender == currentUser.id;
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
              alignment: Alignment.topCenter,
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
                  alignment: (amISender(message)
                      ? Alignment.centerRight
                      : Alignment.centerLeft
                  ),
                  child:
                  Column(
                    crossAxisAlignment: (amISender(message) ? CrossAxisAlignment.end : CrossAxisAlignment.start  ),
                    children: [
                      //username if not the current user
                      (!amISender(message)
                        ? Card(
                    color: Colors.greenAccent,
                    elevation: 8,
                    child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text( message.senderName,
                              style: TextStyle(color: Colors.black ),
                        ),

                    ),
                  )
                        : Container()
                      ),

                    Card(
                      color: (amISender(message)
                          ? CustomColors.goTogetherMain
                          : Colors.white
                      ),
                      elevation: 8,
                      child: Padding(
                          padding: const EdgeInsets.only(top:12 , left:12, right:12, bottom:4),
                          child: Column(
                              crossAxisAlignment: (amISender(message) ? CrossAxisAlignment.end : CrossAxisAlignment.start  ),
                              children: [
                                Text(  message.bodyMessage,
                                  style: TextStyle(color: (amISender(message)  ? Colors.white : Colors.black)),
                                ),
                                Padding(
                                padding: const EdgeInsets.only(top:4),
                                child:Text(
                                  message.createdAt!.getHourTime(),
                                  style: TextStyle(color: Colors.black ),
                                  textScaleFactor: .7,
                                  )
                                )
                              ]
                          )
                      ),
                    ),
                  ],)

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
