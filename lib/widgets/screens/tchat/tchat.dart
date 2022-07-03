import 'package:flutter/material.dart';
import 'package:go_together/helper/enum/custom_colors.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/messages.dart';
import 'package:go_together/models/messages.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/widgets/components/search_bar.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:go_together/models/user.dart';
import 'package:intl/intl.dart';


class Tchat extends StatefulWidget {
  const Tchat({Key? key}) : super(key: key);

  @override
  State<Tchat> createState() => _TchatState();
}

class _TchatState extends State<Tchat> {
  late User currentUser;
  final session = Session();
  final messageTextController = TextEditingController();
  String messageText = "";

  List<Message> messages = [
    Message(id: 1, bodyMessage: "hello", idReceiver: 1, idSender: 2, createdAt:DateTime.now()),
    Message(id: 2, bodyMessage: "yo ^^", idReceiver: 2, idSender: 1, createdAt: DateTime.now().add(Duration(minutes: 5))),
    Message(id: 2, bodyMessage: "ready for today?", idReceiver: 1, idSender: 2, createdAt: DateTime.now().add(Duration(minutes: 7))),
    Message(id: 4, bodyMessage: "a new day today", idReceiver: 1, idSender: 2, createdAt: DateTime.now().add(Duration(days: 2))),
  ].reversed.toList();


  @override
  void initState() {
    super.initState();
    currentUser = session.getData(SessionData.user,defaultVal: MockUser.userGwen);
    messageTextController.addListener(_updateKeywords);
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
    //getActivities(); // (not optimized) do it if wanted to launch a new request at each keyword change
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

  sendMessage(text){
    final Message message = Message(id: -1, bodyMessage: text, idReceiver: -1, idSender: currentUser.id!, createdAt: DateTime.now());
    setState(() {
      messages.add(message);
    });
    messageTextController.text = "";
  }
}
