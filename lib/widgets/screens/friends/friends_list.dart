import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/friends.dart';
import 'package:go_together/widgets/components/buttons/top_button.dart';
import 'package:go_together/widgets/components/delete_button.dart';
import 'package:go_together/widgets/components/lists/column_list.dart';
import 'package:go_together/widgets/components/lists/custom_list.dart';
import 'package:go_together/widgets/components/lists/custom_row.dart';
import 'package:go_together/widgets/components/lists/list_view.dart';
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
  List<User>? futureFriends;
  List<User>? futureFriendsWaiting;
  late User currentUser = Mock.userGwen;
  final searchbarController = TextEditingController();
  String keywords = "";
  int colID = 0;

  @override
  void initState() {
    super.initState();
    _setFriends();
    _setFiendsList();
    _setFriendsWaitingList();
    searchbarController.addListener(_updateKeywords);
  }
  //region set friends
  _setFiendsList() async {
    List<User> friends = await friendsUseCase.getById(currentUser.id!);
    setState(() {
      futureFriends = friends;
    });
  }
  _setFriendsWaitingList() async {
    List<User> friends = await friendsUseCase.getWaitingById(currentUser.id!);
    setState(() {
      futureFriendsWaiting = friends;
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

  getFriends(){
    if(colID==0){
      return futureFriends;
    }
    else{
      return futureFriendsWaiting;
    }
  }

  _setColID(int newId){
    setState(() {
      colID = newId;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<User> displayedFriends = (getFriends() != null ? _filterFriends(getFriends()!) : []);
    return Scaffold(
      appBar: TopSearchBar(
          customSearchBar: const Text('Friends List'),
          searchbarController: searchbarController,
          placeholder: "username",
      ),
      body: Container(
        child:Column(
          children: [
            CustomRow(
                children: [
                  TopButton(
                      child: TextIcon(title:"Friends", icon: Icon(MdiIcons.handshake)),
                      onPress: (){_setColID(0);},
                      hasFocus: colID==0,
                  ),
                  TopButton(
                    child: TextIcon(title:"Waiting", icon: Icon(Icons.access_time)),
                    onPress: (){_setColID(1);},
                    hasFocus: colID==1,
                  ),
                ]
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: (futureFriends!= null
                  ?  ListViewSeparated(data: displayedFriends, buildListItem: (colID == 0 ? _buildRowFriends : _buildRowFriendsWaiting))
                  : Center(
                      child:CircularProgressIndicator()
                    )
                )
              )
            )
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
  }
  _acceptFriend(User user) async {
    bool isValidate = await friendsUseCase.validateFriendship(currentUser.id!, user.id!);
    if(isValidate){
      setState(() {
        currentUser.friendsList.add(user.id!);
        futureFriends!.add(user);
        futureFriendsWaiting!.remove(user);
      });
    }
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
