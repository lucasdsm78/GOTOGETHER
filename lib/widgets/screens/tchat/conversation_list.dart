import 'package:flutter/material.dart';
import 'package:go_together/helper/asymetric_key.dart';
import 'package:go_together/helper/extensions/string_extension.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/conversation.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/message.dart';
import 'package:go_together/widgets/components/lists/list_view.dart';
import 'package:go_together/widgets/screens/tchat/tchat.dart';

import 'package:go_together/widgets/components/search_bar.dart';
import 'package:go_together/helper/extensions/date_extension.dart';

class ConversationList extends StatefulWidget {
  const ConversationList({Key? key}) : super(key: key);

  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  final MessageUseCase messageUseCase = MessageUseCase();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  late Future<List<Conversation>> futureConversation;

  late User currentUser = MockUser.userGwen;
  final searchbarController = TextEditingController();
  String keywords = "";
  List<int> removedConversation = [];

  late String pubKey1;
  late String privateKey1;

  @override
  void initState() {
    super.initState();
    _setConversationList();
    searchbarController.addListener(_updateKeywords);

    //region get key  pair for 3 user
    AsymmetricKeyGenerator keyGenerator = AsymmetricKeyGenerator();
    //keyGenerator.generateKey();
    pubKey1 = keyGenerator.getPubKeyFromStorage();
    privateKey1 = keyGenerator.getPrivateKeyFromStorage();
    //endregion
  }

  //region set friends

  _setConversationList() {
    setState(() {
      futureConversation = messageUseCase.getAllConversationCurrentUser();
    });
  }

  @override
  void dispose() {
    searchbarController.dispose();
    super.dispose();
  }

  //region searchbar && filter
  /// Update [keywords], used in searchbar controller
  void _updateKeywords() {
    setState(() {
      keywords = searchbarController.text;
    });
    //getActivities(); //could filter on the total list, or make a call to api each time keywords change (not optimized)
  }

  /// Filter conversation depending on [keywords]
  _filterConversations(List<Conversation> list){
    List<Conversation> res = [];
    list.forEach((conversation) {
      if(_fieldContains(conversation)){
        res.add(conversation);
      }
    });
    return res;
  }

  /// Check if some conversations fields contain the keywords in searchbar
  bool _fieldContains(Conversation conversation){
    List<String> keywordSplit = keywords.split(",");
    List<bool> contains = [];
    keywordSplit.forEach((element) {
      element = element.trim();
      RegExp regExp = RegExp(element, caseSensitive: false, multiLine: false);
      if((regExp.hasMatch(conversation.name)) && !removedConversation.contains(conversation.id!)){
        contains.add(true);
      }
      else{
        contains.add(false);
      }
    });
    return contains.where((item) => item == false).isEmpty;
  }
  //endregion



  //@todo  : add a floatting  button to add a new conversation
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopSearchBar(
        customSearchBar: const Text('Liste des conversations'),
        searchbarController: searchbarController,
        placeholder: "nom de la conversation",
      ),
      body: Container(
          child: FutureBuilder<List<Conversation>>(
            future: futureConversation,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Conversation> data = snapshot.data!;
                List<Conversation> res = _filterConversations(data);
                return ListViewSeparated(data: res, buildListItem: _buildRowConversation);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return const Center(
                  child: CircularProgressIndicator()
              );
            },
          ),
      ),
    );
  }

  //region actions
  void _goTchat(Conversation conversation) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return  Tchat(conversation: conversation);
        },
      ),
    );
  }

  _quitConversation(Conversation conversation) async {
    // @todo : maybe a 'quitConv' function, to not delete it but just user not in it anymore
    // @todo : could have a list of conversation where we are invited. then can accept or ignore it

    bool isDelete = await messageUseCase.quitConversation(conversation.id!);
    if(isDelete){
      setState(() {
        removedConversation.add(conversation.id!);
      });
    }
  }
  //endregion


  Widget _buildRowConversation(Conversation conversation) {
    String decryptedMsg = "";
    String dateMsg = "";
    if(conversation.lastMessage != null){
      Map<String,String> map = splitSignedAndCryptedMessage(conversation.lastMessage!);
      String messageBody = map["encryptedMsg"]!;
      decryptedMsg = decryptFromString(messageBody, privateKey1);
      dateMsg = conversation.lastMessageDate!.getHourTime();
    }

    return ListTile(
      title: Text(
        conversation.name + "\n\n" + decryptedMsg.elipis() + "\n" + dateMsg,
        style: _biggerFont,
      ),
      leading: Icon(Icons.account_circle_rounded),
      trailing: ElevatedButton(
        onPressed:() {
          _quitConversation(conversation);
        },
        child: Icon(Icons.remove, color: Colors.red,),
        style: ElevatedButton.styleFrom(primary: Colors.white),
      ),
      onTap: () {
        _goTchat(conversation);
      },
    );
  }
}
