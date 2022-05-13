import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/widgets/components/dialog/yes_no_dialog.dart';
import 'package:go_together/widgets/components/custom_text.dart';
import 'package:go_together/widgets/components/lists/list_view.dart';
import 'package:localstorage/localstorage.dart';

import 'package:go_together/widgets/components/search_bar.dart';

/// This screen is used to see all attendes related to the provided activity
class ActivitiesAttendees extends StatefulWidget {
  const ActivitiesAttendees({Key? key, required this.activity}) : super(key: key);
  static const tag = "activity_attendees";
  final Activity activity;

  @override
  _ActivitiesAttendeesState createState() => _ActivitiesAttendeesState();
}

class _ActivitiesAttendeesState extends State<ActivitiesAttendees>{
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final LocalStorage storage = LocalStorage('go_together_app');

  late Future<List<User>> futureUsers;
  late User currentUser;
  bool canDoAction = false;
  String keywords = "";

  final searchbarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getActivitiesAttendees();
    currentUser = MockUser.userGwen;// User.fromJson(jsonDecode(storage.getItem("user")));
    searchbarController.addListener(_updateKeywords);
    canDoAction = currentUser.id == widget.activity.host.id;
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
      onTap: () {
        //setState(() {
        //  _seeMore(activity);
        //});
        if(canDoAction) {
          dialogue(user);
        }
        //@todo : go to activityList
      },
    );
    if(!canDoAction){
      return tile;
    }
    return
      Slidable(
          key: Key(user.id.toString()),
          endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children:[
                slidableActionRemoveUserFromAttendees(context, user)
              ]
          ),
          child: tile
      );
  }

  _changeHostUser(User user){
    return activityUseCase.changeHost(
        {"hostId": user.id, "activityId": widget.activity.id});
  }

  /// Display a dialog to delete the [user].
  Future<Null> dialogue(User user) async{
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return YesNoDialog(
            title: "Désigner comme nouvel organisateur?",
            children: [
              Text("${user.username} deviendras l'organisateur de l'événement. Vous ne pourrez plus modifier cette activité."),
              Text("Etes-vous sûr de vouloir changer l'organisateur?"),
            ],
            trueFunction: ()=>_changeHostUser(user),
          );
        }
    );
  }

  slidableActionRemoveUserFromAttendees(BuildContext context, User user) {
    return SlidableAction(
      onPressed: (BuildContext) {
        activityUseCase.joinActivityUser(widget.activity, user.id!, true);
      },
      backgroundColor: Color(0xFFFE4A49),
      foregroundColor: Colors.white,
      icon: Icons.delete_forever,
      label: 'Supprimer',
    );
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
