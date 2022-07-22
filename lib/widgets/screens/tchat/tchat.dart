import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_together/helper/api.dart';
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
import 'package:toast/toast.dart';


class Tchat extends StatefulWidget {
  //const Tchat({Key? key, conversation}) : super(key: key);
  const Tchat({Key? key, required this.conversation}) : super(key: key);
  final Conversation conversation;

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

  late String pubKey1;
  late String privateKey1;
  late IO.Socket socket;
  bool hasErrorApiMessages = false;

  @override
  void initState() {
    super.initState();
    currentUser = session.getData(SessionData.user);
    messageTextController.addListener(_updateKeywords);

    handleKeys();
    getConversationList();
    getMessagesList();

    connectToSocket();
  }

  @override
  void dispose() {
    messageTextController.dispose();
    socket.close();
    socket.dispose();
    super.dispose();
  }

  /// get the private & public key stored on device
  void handleKeys () async {
    AsymmetricKeyGenerator asymKeys= AsymmetricKeyGenerator();

    pubKey1 = (await asymKeys.getPubKeyFromStorage()).toString();
    privateKey1 = (await asymKeys.getPrivateKeyFromStorage()).toString();
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

  void getConversationList() async {
    try {
      List<Conversation> convList = await messageUseCase.getConversationById(widget.conversation.id!);
      setState(() {
        conversationList = convList;
      });
    } on ApiErr catch(err){
    }
  }

  void getMessagesList() async {
    try {
      List<Message> convList = await messageUseCase.getById(
          widget.conversation.id!);
      convList.forEach((element) {
        receiveMessage(element);
      });
    } on ApiErr catch(err){
      setState(() {
        hasErrorApiMessages = true;
      });
    }
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
  void sendMessage(String text) async {
    if(text != null  && text != "") {
      if(conversationList.isEmpty){
        Toast.show("Impossible d'envoyer le message", gravity: Toast.bottom, duration: 3, backgroundColor: Colors.redAccent);
      }
      else {
        //region generate crypted message for all user in conversation
        List<Message> listMessage = [];
        log(conversationList.toString());
        conversationList.forEach((element) {
          log(element.toString());
          if (element.pubKey != null && element.pubKey != "") {
            Uint8List encryptData = encrypt(text, element.pubKey);
            Uint8List signature = rsaSignFromKeyString(
                privateKey1, encryptData);
            String cryptedMessageSigned = addSignature(
                encryptData.toString(), signature.toString());
            listMessage.add(Message(id: 0,
                bodyMessage: cryptedMessageSigned,
                idReceiver: element.userId,
                idSender: 0,
                createdAt: DateTime.now(),
                senderName: currentUser.username));
          }
        });
        //endregion

        final messageSend = await messageUseCase.add(
            widget.conversation.id!, listMessage);

        //reset text input content
        messageTextController.text = "";
      }
    }
  }

  /// Decrypt received message and add the result in messageList to display
  void receiveMessage(Message message){
    try {
      Map<String,String> map = splitSignedAndCryptedMessage(message.bodyMessage);
      String messageBody = map["encryptedMsg"]!;
      String decryptedMsg = decryptFromString(messageBody, privateKey1);
      // check signature
      //rsaVerifyFromKeyStringAndStringBytes(pubKey1, messageBody, map["signature"]!);

      final Message finalMessage = Message(id: message.id, bodyMessage: decryptedMsg, idReceiver: message.idReceiver, idSender: message.idSender, createdAt: message.createdAt, senderName: message.senderName);
      setState(() {
        messages.add(finalMessage);
      });
    } on EncryptionErr catch(err){
      log(err.message + ". " + (message.id == null ? "" : "id_message=" + message.id.toString() ));
    }
  }

  /// Used by socket
  void handleMessage(dynamic data){
    Map<String, dynamic> res = data;

    if(res["room"] == widget.conversation.id! && res["receiver"] == currentUser.id){
      receiveMessage( Message.fromJson(json.decode(res["msg"])));
    }
  }
  //endregion

  bool amISender(Message message){
    return currentUser.id != null && message.idSender == currentUser.id;
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.name),
        backgroundColor: CustomColors.goTogetherMain,
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child:
        Column(
          children: [
            Expanded(
              child: (hasErrorApiMessages
                ? Center(child: Text("Impossible de charger les messages"),)
                : GroupedListView<Message, DateTime>(
                  padding: const EdgeInsets.all(8),
                  reverse: true,
                  order: GroupedListOrder.DESC,
                  useStickyGroupSeparators: true,
                  floatingHeader: true,
                  shrinkWrap: true,
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
                        ],
                      )

                  )
              )
              )
            ),
            Container(
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
          ],
        ),

      ),
    );
  }

}
