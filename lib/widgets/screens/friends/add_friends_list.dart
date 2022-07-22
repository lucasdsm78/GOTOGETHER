import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/api.dart';
import 'package:go_together/helper/error_helper.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/friends.dart';
import 'package:go_together/usecase/user.dart';
import 'package:go_together/widgets/components/lists/list_view.dart';
import 'package:go_together/widgets/screens/users/user.dart';

import 'package:go_together/widgets/components/search_bar.dart';
import 'package:toast/toast.dart';

class AddFriendsList extends StatefulWidget {
  const AddFriendsList({Key? key}) : super(key: key);
  static const tag = "add_friend_list";

  @override
  _AddFriendsListState createState() => _AddFriendsListState();
}

class _AddFriendsListState extends State<AddFriendsList> {
  final FriendsUseCase friendsUseCase = FriendsUseCase();
  final UserUseCase userUseCase = UserUseCase();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  late Future<List<User>> futureUsers;
  late User currentUser;
  final searchbarController = TextEditingController();
  String keywords = "";
  final session = Session();

  @override
  void initState(){
    super.initState();
    currentUser = session.getData(SessionData.user);
    _setFriends();
    futureUsers = userUseCase.getAll();

    searchbarController.addListener(_updateKeywords);
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

  /// Filter user depending on [keywords]
  List<User> _filterFriends(List<User> list){
    List<User> res = [];
    list.forEach((user) {
      if(_fieldContains(user) && !currentUser.friendsList.contains(user.id) ){
        res.add(user);
      }
    });
    return res;
  }

  /// Check if some users fields contain the keywords in searchbar
  bool _fieldContains(User user){
    List<String> keywordSplit = keywords.split(",");
    List<bool> contains = [];
    keywordSplit.forEach((element) {
      element = element.trim();
      RegExp regExp = RegExp(element, caseSensitive: false, multiLine: false);
      contains.add((regExp.hasMatch(user.username)));
    });
    return contains.where((item) => item == false).isEmpty;
  }


  void _setFriends() async{
    try{
      List<User> friendsList = await friendsUseCase.getWaitingAndValidateById(currentUser.id!);
      List<int> listId = [];
      friendsList.forEach((element) {
        if(element.id != null) {
          listId.add(element.id!);
        }
      });
      setState(() {
        currentUser.friendsList = listId;
      });
    } on ApiErr catch(err){
      Toast.show(err.message, gravity: Toast.bottom, duration: 3, backgroundColor: Colors.redAccent);
    }
  }

  //endregion


  /// build a listView item widget, taking an [User] in parameters
  /// in order to display some valuable data like the host name, or the
  /// activity location.
  Widget _buildRow(User user) {
    return ListTile(
      title: Text(
        user.username,
        style: _biggerFont,
      ),
      trailing:IconButton(
          onPressed: (){
            _addFriend(user);
          },
          icon: Icon(Icons.group_add)
      ),
      onTap: () {
        _seeMore(user);
      },
    );
  }

  void _seeMore(User user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          //@todo : display a user profile readonly (can't change user data)
          return  UserProfile(user: user);
        },
      ),
    );
  }

  void _addFriend(User user){
    try{
      friendsUseCase.add(currentUser.id!, user.id!);
      setState(() {
        currentUser.friendsList.add(user.id!);
      });
    } on ApiErr catch(err){
      Toast.show(err.message, gravity: Toast.bottom, duration: 3, backgroundColor: Colors.redAccent);
    }
  }



  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return Scaffold(
      appBar: TopSearchBar(
        customSearchBar: const Text('Ajouter des amis'),
        searchbarController: searchbarController,
        placeholder: "username",
      ),
      body: FutureBuilder<List<User>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<User> data = snapshot.data!;
            List<User> res = _filterFriends(data);

            return ListViewSeparated(data: res, buildListItem: _buildRow);
          } else if (snapshot.hasError) {
            return getSnapshotErrWidget(snapshot);
          }
          return const Center(
              child: CircularProgressIndicator()
          );
        },
      ),
    );
  }

}
