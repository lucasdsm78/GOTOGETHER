import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_together/helper/NotificationCenter.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/mock/sports.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/level.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/usecase/sport.dart';
import 'package:go_together/widgets/screens/activities/activity_details.dart';
import 'package:go_together/widgets/screens/activities/activity_set.dart';
import 'package:go_together/widgets/components/custom_text.dart';
import 'package:go_together/widgets/components/dialog/filter_dialog.dart';
import 'package:go_together/widgets/components/lists/list_view.dart';
import 'package:localstorage/localstorage.dart';

import 'package:go_together/widgets/components/search_bar.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';

class ActivitiesUser extends StatefulWidget {
  const ActivitiesUser({Key? key}) : super(key: key);
  static const tag = "user_list";

  @override
  _ActivitiesUserState createState() => _ActivitiesUserState();
}

class _ActivitiesUserState extends State<ActivitiesUser> with Observer{
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final SportUseCase sportUseCase = SportUseCase();
  final LocalStorage storage = LocalStorage('go_together_app');

  late Future<List<Activity>> futureActivities;

  late User currentUser;
  String keywords = "";
  late Sport sport = MockSport.sportList.first;

  List<Sport> futureSports = [];
  DateTime? selectedDate;//DateTime.now();

  final searchbarController = TextEditingController();
  String? gender;
  Level? level;

  //region getter
  /// Used to set params used in the getActivity API call.
  /// Since we want to avoid too many request for each filter changes, we only
  /// use it when we want to get current user's activities.
  Map <String, dynamic> criterionMap(){
    return {"sportId":/*sport.id*/null, "keywords":keywords};
  }

  void getSports() async{
    log("GET SPORT FROM ACTIVITIES LIST");
    String? storedSport = storage.getItem("sports");
    if(storedSport != null){
      log("ACTIVITIES LIST - GET DATA FROM STORAGE ");
      setState(() {
        futureSports = parseSports(storedSport);
        sport = futureSports[0];
      });
    }
    else {
      List<Sport> res = await sportUseCase.getAll();
      log("ACTIVITIES LIST - GET DATA FROM API ");

      log(res.toString());
      setState(() {
        futureSports = res;
        sport = futureSports[0];
      });
    }
  }

  void getActivities(){
    setState(() {
      futureActivities = activityUseCase.getAll(map: criterionMap());
    });
  }
  //endregion

  @override
  void initState() {
    super.initState();
    getSports();
    getActivities();

    currentUser = Session().getData(SessionData.user);
    print(currentUser.id);
    searchbarController.addListener(_updateKeywords);
    Observable.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _updateKeywords listener.
    searchbarController.dispose();
    Observable.instance.removeObserver(this);
    super.dispose();
  }
  @override
  update(Observable observable, String? notifyName, Map? map) {
    if(notifyName == NotificationCenter.userJoinActivity.name || notifyName == NotificationCenter.userCancelActivity.name){
      getActivities();
    }
    //throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> dropdownItems = futureSports.map((item) {
      //@todo maybe need a future builder
      return DropdownMenuItem<Sport>(
        child: Text(item.name),
        value: item,
      );
    }).toList();

    return Scaffold(
      appBar: TopSearchBar(
          customSearchBar: const Text('Mes participations'),
          searchbarController: searchbarController,
          leading:IconButton(onPressed: (){
            dialogue();
          }, icon: Icon(Icons.more_horiz))
      ),
      body: FutureBuilder<List<Activity>>(
        future: futureActivities,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Activity> data = snapshot.data!;
            List<Activity> res = _filterActivities(data);
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

  void _seeMore(Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return  ActivityDetailsScreen(activity: activity);
        },
      ),
    );
  }

  /// This function build a Slidable item used to update the activity.
  /// Slide to the right of a list item to see it appear.
  /// Only available for the activity's host
  slidableActionCurrentUserActivity(BuildContext context, Activity activity) {
    return SlidableAction(
      onPressed: (BuildContext) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) {
              return  ActivitySet(activity: activity);
            },
          ),
        );
      },
      backgroundColor: Color(0xFFFE4A49),
      foregroundColor: Colors.white,
      icon: Icons.edit,
      label: 'Modifier',
    );
  }

  /// build a listView item widget, taking an [activity] in parameters
  /// in order to display some valuable data like the host name, or the
  /// activity location.
  ///
  /// Everybody could see activity details when clicking this item.
  ///
  /// If the current user is the activity's host, he can access to a slidable
  /// action to update the activity.
  /// But he still can see what other user's see of his activity.
  Widget _buildRow(Activity activity) {
    final hasJoin = activity.currentAttendees!.contains(currentUser.id.toString());
    Widget tile = ListTile(
      title: CustomText(activity.description + " - " + activity.host.username),
      subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text("${activity.location.address}, ${activity.location.city}"),
            Text(activity.dateStart.getFrenchDateTime())
          ]
      ),
      trailing:Icon(
        hasJoin ? Icons.favorite : Icons.favorite_border,
        color: hasJoin ? Colors.red : null,
        semanticLabel: hasJoin ? 'i have join' : 'i have not join',
      ),
      onTap: () {
        setState(() {
          _seeMore(activity);
        });
      },
    );
    if(currentUser.id != activity.host.id){
      return tile;
    }
    return
      Slidable(
          key: Key(activity.id.toString()),
          endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children:[
                slidableActionCurrentUserActivity(context, activity)
              ]
          ),
          child: tile
      );
  }
  /// Display a dialog containing some filters to apply on the list.
  Future<Null> dialogue() async{
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return FilterDialog(selectedDate: selectedDate, onSelectDate: _updateSelectedDate,
              sport: sport, onChangeSport: _updateSelectedSport,
              gender: gender, onChangeGender: _updateSelectedGender,
              level: level, onChangeLevel: _updateSelectedLevel);
        }
    );
  }


  //region updates
  _updateSelectedDate(DateTime date){
    setState(() {
      selectedDate = date;
    });
  }

  _updateSelectedSport(Sport newSport){
    setState(() {
      sport = newSport;
    });
  }

  _updateSelectedGender(String newGender){
    setState(() {
      gender = newGender;
    });
  }

  _updateSelectedLevel(Level newLevel){
    setState(() {
      level = newLevel;
    });
  }

  /// Update [keywords], used in searchbar controller
  void _updateKeywords() {
    setState(() {
      keywords = searchbarController.text;
    });
    //getActivities(); //could filter on the total list, or make a call to api each time keywords change (not optimized)
  }
  //endregion


  //region filter
  /// Filter activities depending on [keywords], [selectedDate],
  /// [sport], and activity attendees.
  _filterActivities(List<Activity> list){
    List<Activity> res = [];
    list.forEach((activity) {
      if(_fieldContains(activity)
          && (selectedDate ==null || activity.dateStart.getOnlyDate() == selectedDate!.getOnlyDate())
          && sport.id == activity.sport.id && activity.currentAttendees!.contains(currentUser.id.toString()) ){
        res.add(activity);
      }
    });
    return res;
  }

  /// Check if some activity fields contain the keywords in searchbar.
  /// it could be the activity descrition, city, host name, or sport.
  ///
  /// we could use multi keywords using ',' to separate each keyword
  bool _fieldContains(Activity activity){
    List<String> keywordSplit = keywords.split(",");
    List<bool> contains = [];

    /// foreach of keyword, we create a regex to check if one of
    /// activity's data has a match.
    keywordSplit.forEach((element) {
      RegExp regExp = RegExp(element, caseSensitive: false, multiLine: false);
      if(
      (regExp.hasMatch(activity.description) || regExp.hasMatch(activity.sport.name)
          || regExp.hasMatch(activity.location.city) || regExp.hasMatch(activity.location.country)
          || regExp.hasMatch(activity.host.mail) || regExp.hasMatch(activity.host.username)) ){
        contains.add(true);
      }
      else{
        contains.add(false);
      }
    });
    return contains.where((item) => item == false).isEmpty;
  }
  //endregion



}
