import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/friends.dart';
import 'package:go_together/usecase/user.dart';
import 'package:go_together/widgets/components/lists/list_view.dart';
import 'package:go_together/widgets/screens/users/user.dart';

import 'package:go_together/widgets/components/search_bar.dart';

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
  late User currentUser = Mock.userGwen;
  final searchbarController = TextEditingController();
  String keywords = "";

  @override
  void initState(){
    super.initState();
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
  _filterFriends(List<User> list){
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
      RegExp regExp = RegExp(element, caseSensitive: false, multiLine: false);
      contains.add((regExp.hasMatch(user.username)));
    });
    return contains.where((item) => item == false).isEmpty;
  }


  _setFriends() async{
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
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopSearchBar(
        customSearchBar: const Text('Friends List'),
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
            return Text("${snapshot.error}");
          }
          return const Center(
              child: CircularProgressIndicator()
          );
        },
      ),
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

  _addFriend(User user){
    friendsUseCase.add(currentUser.id!, user.id!);
    currentUser.friendsList.add(user.id!);
  }

  Widget _buildRow(User user) {
    return ListTile(
      title: Text(
        user.username,
        style: _biggerFont,
      ),
      trailing:IconButton(onPressed: (){
        _addFriend(user);
      }, icon: Icon(Icons.group_add)),
      onTap: () {
        _seeMore(user);
      },
    );
  }
}
