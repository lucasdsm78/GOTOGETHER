import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/commentary.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/usecase/commentary.dart';
import 'package:go_together/widgets/components/custom_text.dart';
import 'package:go_together/widgets/components/lists/list_view.dart';
import 'package:localstorage/localstorage.dart';

import 'package:go_together/widgets/components/search_bar.dart';

/// this class will display all attendees of an activity.
/// Shouldn't be available before the activity is finished.
class ActivitiesAttendeesCommentary extends StatefulWidget {
  const ActivitiesAttendeesCommentary({Key? key, required this.activity}) : super(key: key);
  static const tag = "activity_attendeesCommentary";
  final Activity activity;

  @override
  _ActivitiesAttendeesCommentaryState createState() => _ActivitiesAttendeesCommentaryState();
}

class _ActivitiesAttendeesCommentaryState extends State<ActivitiesAttendeesCommentary>{
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final commentaryUseCase = CommentaryUseCase();
  final LocalStorage storage = LocalStorage('go_together_app');
  late List<Commentary> _values;
  late Future<List<User>> futureUsers;
  late User currentUser;
  String keywords = "";
  final searchbarController = TextEditingController();
  final session = Session();

  @override
  void initState() {
    super.initState();
    getActivitiesAttendees();
    _values = [];
    currentUser = session.getData(SessionData.user);
    searchbarController.addListener(_updateKeywords);
  }

  @override
  void dispose() {
    searchbarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopSearchBar(
        customSearchBar: const Text('Les participants'),
        searchbarController: searchbarController,
      ),
      body: FutureBuilder<List<User>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<User> data = snapshot.data!;
            List<User> res = _filterActivities(data);
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

  Widget _buildRow(User user) {
    Widget tile = ListTile(
      title: CustomText(user.username),
      leading: Icon(Icons.account_circle_rounded),
      trailing: Container(
        width: 150.0,
        child: Form(
          key: Key("${user.id!}"),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child:
                      TextField(
                        decoration:
                        const InputDecoration.collapsed(hintText: 'Commentaire'),
                        onChanged: (value){
                          _onUpdate(user.id!,comment:value);
                        },
                      ),
                    ),
                    RatingBar.builder(itemBuilder: (context,_)=>
                    const Icon(Icons.star,color:Colors.amber),
                        itemSize: 20,
                        onRatingUpdate: (rating){
                          setState(() {
                            _onUpdate(user.id!,rating:rating.round());
                          });
                        }),
                  ],
                )
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: Colors.black,
                onPressed: () {
                  _addCommentary(user.id!);
                },
              ),
            ],
          ),
        ),
      )
    );

      return tile;

  }
  /// Add the current commentary in an array [_values] each time the form is updated
  void _onUpdate(int key, {int? rating, String? comment}){
    Commentary commentary = Commentary(userIdReceiver: key,userIdSender: currentUser.id!,mark: rating, commentary:comment);
    _values.add(commentary);
  }


  /// get the instance commentary of the current user in [_values] and get the last mark and commentary in array
  void _addCommentary(int userId) async {
    Commentary commentary = _values.lastWhere((i) => i.userIdReceiver == userId);
    if(commentary.mark == null){
      Commentary commentaryWithMark = _values.lastWhere((i) => i.mark != null && i.userIdReceiver == userId);
      commentary.mark = commentaryWithMark.mark;
    }else if(commentary.commentary == null){
      Commentary commentaryWithComment = _values.lastWhere((i) => i.commentary != null && i.userIdReceiver == userId);
      commentary.commentary = commentaryWithComment.commentary;
    }
    await commentaryUseCase.add(commentary);
  }


  void getActivitiesAttendees(){
    setState(() {
      futureUsers = activityUseCase.getAllAttendeesByIdActivity(widget.activity.id!);
    });
  }

  /// Filter activities depending on [keywords], [selectedDate]
  _filterActivities(List<User> list){
    List<User> res = [];
    list.forEach((user) {
      if(_fieldContains(user)){
        res.add(user);
      }
    });
    return res;
  }

  /// Check if some user contain the keywords in searchbar.
  /// it could be the username.
  ///
  /// we could use multi keywords using ',' to separate each keyword
  bool _fieldContains(User user){
    List<String> keywordSplit = keywords.split(",");
    List<bool> contains = [];
    keywordSplit.forEach((element) {
      element = element.trim();
      RegExp regExp = RegExp(element, caseSensitive: false, multiLine: false);
      if (regExp.hasMatch(user.username)){
        contains.add(true);
      }
      else{
        contains.add(false);
      }
    });
    return contains.where((item) => item == false).isEmpty;
  }

  /// Update [keywords], used in searchbar controller
  void _updateKeywords() {
    setState(() {
      keywords = searchbarController.text;
    });
    //getActivities(); //could filter on the total list, or make a call to api each time keywords change (not optimized)
  }


}
