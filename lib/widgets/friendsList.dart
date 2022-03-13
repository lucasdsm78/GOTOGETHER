import 'package:flutter/material.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/friends.dart';
import 'package:go_together/widgets/components/list_view.dart';

import 'components/search_bar.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({Key? key}) : super(key: key);

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  final FriendsUseCase friendsUseCase = FriendsUseCase();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  late Future<List<User>> futureUsers;
  late User currentUser = Mock.userGwen;
  final searchbarController = TextEditingController();
  String keywords = "";

  @override
  void initState() {
    super.initState();
    futureUsers = friendsUseCase.getById(currentUser.id!);
    searchbarController.addListener(_updateKeywords);
  }

  @override
  void dispose() {
    searchbarController.dispose();
    super.dispose();
  }

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
      if(_fieldContains(user)){
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
      if(
      (regExp.hasMatch(user.username)) ){
        contains.add(true);
      }
      else{
        contains.add(false);
      }
    });
    return contains.where((item) => item == false).isEmpty;
  }

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

  /*void _seeMore(User user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return  UserInfoScreen(user: user);
        },
      ),
    );
  }*/

  Widget _buildRow(User user) {
    return ListTile(
      title: Text(
        user.username,
        style: _biggerFont,
      ),
      onTap: () {
       // _seeMore(user);
      },
    );
  }
}
