import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/friends.dart';
import 'package:go_together/widgets/components/buttons/header_tabs.dart';
import 'package:go_together/widgets/components/lists/list_view.dart';
import 'package:go_together/widgets/components/lists/tabs_element.dart';
import 'package:go_together/widgets/components/text_icon.dart';
import 'package:go_together/widgets/screens/users/user.dart';

import 'package:go_together/widgets/components/search_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({Key? key}) : super(key: key);

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  final FriendsUseCase friendsUseCase = FriendsUseCase();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  late Future<List<User>> futureFriends2;
  late Future<List<User>> futureFriendsWaiting2;

  late User currentUser = MockUser.userGwen;
  final searchbarController = TextEditingController();
  String keywords = "";
  int colID = 0;
  final session = Session();

  @override
  void initState() {
    super.initState();
    currentUser = session.getData(SessionData.user);

    _setFriends();
    _setFiendsList();
    _setFriendsWaitingList();
    searchbarController.addListener(_updateKeywords);
  }

  //region set friends
  _setColID(int newId){
    setState(() {
      colID = newId;
    });
  }
  _setFiendsList() {
    setState(() {
      futureFriends2 = friendsUseCase.getById(currentUser.id!);
    });
  }
  _setFriendsWaitingList() {
    setState(() {
      futureFriendsWaiting2 = friendsUseCase.getWaitingById(currentUser.id!);
    });
  }

  //set friends for Mock reason (don't have the actual friend from bdd with mock)
  //Note that the user.friendList contain both confirmed and waiting friends.
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
      if(_fieldContains(user) && currentUser.friendsList.contains(user.id) ){
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
      if((regExp.hasMatch(user.username)) ){
        contains.add(true);
      }
      else{
        contains.add(false);
      }
    });
    return contains.where((item) => item == false).isEmpty;
  }
  //endregion



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopSearchBar(
          customSearchBar: const Text('Liste des amis'),
          searchbarController: searchbarController,
          placeholder: "username",
      ),
      body: Container(
        child:Column(
          children: [
            HeaderTabs(
              tabsWidget: const [
                TextIcon(title:"Amis", icon: Icon(MdiIcons.handshake)),
                TextIcon(title:"En attente", icon: Icon(Icons.access_time))
              ],
              onPress: _setColID
            ),

            TabsElement(
              children:[
                FutureBuilder<List<User>>(
                  future: futureFriends2,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<User> data = snapshot.data!;
                      List<User> res = _filterFriends(data);
                      return ListViewSeparated(data: res, buildListItem: _buildRowFriends);
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return const Center(
                        child: CircularProgressIndicator()
                    );
                  },
                ),
                FutureBuilder<List<User>>(
                  future: futureFriendsWaiting2,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<User> data = snapshot.data!;
                      List<User> res = _filterFriends(data);
                      return ListViewSeparated(data: res, buildListItem: _buildRowFriendsWaiting);
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return const Center(
                        child: CircularProgressIndicator()
                    );
                  },
                ),
              ],
              colID : colID
            ),
          ],
        )
      ),
    );
  }

  //region actions
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

  _deleteFriend(User user) async {
    bool isDelete = await friendsUseCase.delete(currentUser.id!, user.id!);
    if(isDelete){
      setState(() {
        currentUser.friendsList.remove(user.id!);
      });
    }
    _setFriends();
    _setFiendsList();

  }
  _acceptFriend(User user) async {
    bool isValidate = await friendsUseCase.validateFriendship(currentUser.id!, user.id!);
    if(isValidate){
      setState(() {
        currentUser.friendsList.add(user.id!);
      });
    }
    _setFriends();
    _setFiendsList();
    _setFriendsWaitingList();
  }
  //endregion


  Widget _buildRowFriends(User user) {
    return ListTile(
      title: Text(
        user.username,
        style: _biggerFont,
      ),
      leading: Icon(Icons.account_circle_rounded),
      trailing: ElevatedButton(
        onPressed:() {
          _deleteFriend(user);
        },
        child: Icon(Icons.delete_forever, color: Colors.red,),
        style: ElevatedButton.styleFrom(primary: Colors.white),
      ),
      onTap: () {
        _seeMore(user);
      },
    );
  }
  Widget _buildRowFriendsWaiting(User user) {
    return ListTile(
      title: Text(
        user.username,
        style: _biggerFont,
      ),
      leading: Icon(Icons.account_circle_rounded),
      trailing: ElevatedButton(
        onPressed:() {
          _acceptFriend(user);
        },
        child: Icon(Icons.download_done_sharp, color: Colors.green,),
        style: ElevatedButton.styleFrom(primary: Colors.white),
      ),
      onTap: () {
        _seeMore(user);
      },
    );
  }
}
