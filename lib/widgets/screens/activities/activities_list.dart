import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_together/helper/NotificationCenter.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/helper/storage.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/level.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/widgets/components/lists/custom_list.dart';
import 'package:go_together/widgets/components/text_icon.dart';
import 'package:go_together/widgets/screens/activities/activity_details.dart';
import 'package:go_together/widgets/screens/activities/activity_set.dart';
import 'package:go_together/widgets/components/custom_text.dart';
import 'package:go_together/widgets/components/dialog/filter_dialog.dart';
import 'package:go_together/widgets/components/lists/list_view.dart';

import 'package:go_together/widgets/components/search_bar.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// This is the activity list.
/// if we provide [idHost], it means the list should be only the activities
/// hosted by the currend user.
class ActivityList extends StatefulWidget {
  const ActivityList({Key? key,  this.idHost}) : super(key: key);
  static const tag = "activity_list";
  final int? idHost;

  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> with Observer{
  final ActivityUseCase activityUseCase = ActivityUseCase();
  late Future<List<Activity>> futureActivities;
  late User currentUser;

  //region data used to filter
  String keywords = "";
  Sport? sport;

  DateTime? selectedDate;
  String? gender;
  Level? level;
  //endregion

  final searchbarController = TextEditingController();
  CustomStorage store = CustomStorage();
  final Session session = Session();

  void getActivities(){
    setState(() {
      futureActivities = activityUseCase.getAll(map: criterionMap());
    });
  }

  @override
  void initState() {
    super.initState();
    getActivities();
    currentUser = session.getData(SessionData.user);
    searchbarController.addListener(_updateKeywords);
    Observable.instance.addObserver(this);
  }

  ///Clean up the controller when the widget is removed from the widget tree.
  ///This also removes the _updateKeywords listener.
  ///it's important to avoid memory leaks, thus improve performance
  @override
  void dispose() {
    searchbarController.dispose();
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  ///a function called when receiving Notification from [NotificationCenter].
  ///We used it to refresh the list, to see changes executed in another page
  ///instantly, especially when using back button
  @override
  update(Observable observable, String? notifyName, Map? map) {
    if(notifyName == NotificationCenter.userJoinActivity.name
        || notifyName == NotificationCenter.userCancelActivity.name){
      getActivities();
    }
    //throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: TopSearchBar(
          customSearchBar: const Text('Liste des Activités',
            style: TextStyle(color: Colors.white),
          ),
          searchbarController: searchbarController,
          leading:IconButton(onPressed: (){
            _dispDialog();
          }, icon: Icon(Icons.more_horiz, color:Colors.white))
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

  /// This function will push (redirect) to Activity details page
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
  slidableActionUpdateActivity(BuildContext context, Activity activity) {
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
            TextIcon(
                title: "${activity.location.address}, ${activity.location.city}",
                icon:Icon(MdiIcons.mapMarker, color: Colors.green,),
                mainAxisAlignment:MainAxisAlignment.start
            ),
            TextIcon(title: activity.dateStart.getFrenchDateTime(),
                icon:Icon(MdiIcons.calendar, color: Colors.green),
                mainAxisAlignment:MainAxisAlignment.start
            )
          ]
      ),
      trailing:
      CustomColumn(
        children: [
          ( activity.host.id! == currentUser.id!
              ? Icon(MdiIcons.crown, color: Colors.amberAccent,)
              : Container(
            width: 0,
            height: 0,
          )
          ),
          Icon(
            hasJoin ? Icons.favorite : Icons.favorite_border,
            color: hasJoin ? Colors.red : null,
            semanticLabel: hasJoin ? 'i have join' : 'i have not join',
          ),
          Text("${activity.nbCurrentParticipants}/${activity.attendeesNumber}")
        ],
      ),
      onTap: () {
          _seeMore(activity);
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
            slidableActionUpdateActivity(context, activity)
          ]
        ),
        child: tile
    );
  }

  /// Display a dialog containing some filters to apply on the list.
  Future<Null> _dispDialog() async{
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return FilterDialog(
            selectedDate: selectedDate, onSelectDate: _updateSelectedDate,
            sport: sport, onChangeSport: _updateSelectedSport,
            gender: gender, onChangeGender: _updateSelectedGender,
            level: level, onChangeLevel: _updateSelectedLevel);
        }
    );
  }

  /// Used to set params used in the getActivity API call.
  /// Since we want to avoid too many request for each filter changes, we only
  /// use it when we want to get current user's activities.
  Map <String, dynamic> criterionMap(){
    //Map <String, dynamic> map = {"sportId":null /*sport.id*/, "keywords":keywords};
    Map <String, dynamic> map = {};
    if(widget.idHost!=null){
      map["hostId"] = widget.idHost;
    }
    return map;
  }

  //region setters data used to filter
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

  /// Update [keywords], related to the search bar.
  void _updateKeywords() {
    setState(() {
      keywords = searchbarController.text;
    });
    //getActivities(); // (not optimized) do it if wanted to launch a new request at each keyword change
  }
  //endregion

  //region filtering list
  /// Filter activities depending on [keywords], [selectedDate],
  /// [sport], [gender], [level], and activity privacy (public).
  ///
  /// if the privacy is private, only the host and its friends can see it.
  _filterActivities(List<Activity> list){
    List<Activity> res = [];
    list.forEach((activity) {
      if(_fieldContains(activity)
          && (selectedDate ==null || activity.dateStart.getOnlyDate() == selectedDate!.getOnlyDate())
          && (sport == null || sport!.id == activity.sport.id)
          && (gender == null ||  gender == activity.criterionGender?.translate())
          && (level == null ||level!.id == activity.level.id)
          && (activity.host.id == currentUser.id
              || activity.public == null
              || (activity.public!
                  || (!activity.public! && activity.host.friendsList.contains(currentUser.id))
              )
          )
      ){
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
    List<bool> containsKeyword = [];

    /// foreach of keyword, we create a regex to check if one of
    /// activity's data has a match.
    keywordSplit.forEach((element) {
      element = element.trim();
      RegExp regExp = RegExp(element, caseSensitive: false, multiLine: false);
      if(
          (regExp.hasMatch(activity.description) || regExp.hasMatch(activity.sport.name)
          || regExp.hasMatch(activity.location.city) || regExp.hasMatch(activity.location.country)
          || regExp.hasMatch(activity.host.mail) || regExp.hasMatch(activity.host.username)) ){
        containsKeyword.add(true);
      }
      else{
        containsKeyword.add(false);
      }
    });

    /// if all keywords has a match, we return true
    return containsKeyword.where((item) => item == false).isEmpty;
  }
  //endregion

}
