import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/conversation.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/friends.dart';
import 'package:go_together/usecase/message.dart';
import 'package:go_together/usecase/message.dart';
import 'package:go_together/widgets/components/buttons/header_tabs.dart';
import 'package:go_together/widgets/components/lists/list_view.dart';
import 'package:go_together/widgets/components/lists/tabs_element.dart';
import 'package:go_together/widgets/components/text_icon.dart';
import 'package:go_together/widgets/screens/tchat/tchat.dart';
import 'package:go_together/widgets/screens/users/user.dart';

import 'package:go_together/widgets/components/search_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _setConversationList();
    searchbarController.addListener(_updateKeywords);
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
      if((regExp.hasMatch(conversation.name)) ){
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

  _deleteConversation(Conversation conversation) async {
    //@todo : maybe a 'quitConv' function, to not delete it but just user not in it anymore
    // + update interface when quiting
    // @todo : could have a list of conversation where we are invited. then can accept or ignore it

    /*bool isDelete = await messageUseCase.delete(currentUser.id!, user.id!);
    if(isDelete){
      setState(() {
        currentUser.friendsList.remove(user.id!);
      });
    }*/
  }
  //endregion


  Widget _buildRowConversation(Conversation conversation) {
    return ListTile(
      title: Text(
        conversation.name,
        style: _biggerFont,
      ),
      leading: Icon(Icons.account_circle_rounded),
      trailing: ElevatedButton(
        onPressed:() {
          _deleteConversation(conversation);
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
