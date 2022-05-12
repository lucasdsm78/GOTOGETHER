import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_together/helper/NotificationCenter.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:go_together/helper/storage.dart';
import 'package:go_together/mock/mock.dart';
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
import 'package:go_together/widgets/components/filter_dialog.dart';
import 'package:go_together/widgets/components/lists/list_view.dart';
import 'package:localstorage/localstorage.dart';

import 'package:go_together/widgets/components/search_bar.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

//@todo : il faudrait un bouton qui affiche les filtres
class ActivityList extends StatefulWidget {
  const ActivityList({Key? key,  this.idHost}) : super(key: key);
  static const tag = "activity_list";
  final int? idHost;

  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> with Observer{
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final LocalStorage storage = LocalStorage('go_together_app');

  late Future<List<Activity>> futureActivities;
  late User currentUser;

  String keywords = "";
  Sport? sport;

  DateTime? selectedDate;//DateTime.now();
  String? gender;
  Level? level;

  final searchbarController = TextEditingController();
  CustomStorage store = CustomStorage();

  @override
  void initState() {
    super.initState();
    getActivities();
    currentUser = Mock.userGwen;
    //getUser();
    searchbarController.addListener(_updateKeywords);
    Observable.instance.addObserver(this);
  }
  getUser() async {
    currentUser = User.fromJson(jsonDecode(await store.getUser())) ;
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

    return Scaffold(
      appBar: TopSearchBar(
          customSearchBar: const Text('Activities List',
            style: TextStyle(color: Colors.white),
          ),
          searchbarController: searchbarController,
          leading:IconButton(onPressed: (){
            dialogue();
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

  /// Cette feature permet d'afficher dans une
  /// nouvelle page le détail de l'activité

  void _seeMore(Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return  ActivityDetailsScreen(activity: activity);
        },
      ),
    );
  }

  /// Cette fonction permet d'afficher le bouton Modifier
  /// quand on slide vers la droite sur une activité
  /// Cette fonctionnalité n'est disponible que si l'utilisateur connecté
  /// est l'organisateur de l'activité

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

  /// A widget take in parameter an [activity] for generates as many  row as there is [aactivity]
  Widget _buildRow(Activity activity) {
    final hasJoin = activity.currentParticipants!.contains(currentUser.id.toString());
    Widget tile = ListTile(
      title: CustomText(activity.description + " - " + activity.host.username),
      subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            TextIcon(title: "${activity.location.address}, ${activity.location.city}", icon:Icon(MdiIcons.mapMarker, color: Colors.green,), mainAxisAlignment:MainAxisAlignment.start),
            TextIcon(title: activity.dateStart.getFrenchDateTime(), icon:Icon(MdiIcons.calendar, color: Colors.green), mainAxisAlignment:MainAxisAlignment.start)
          ]
      ),
      trailing:
      CustomColumn(
        children: [
          Icon(
            hasJoin ? Icons.favorite : Icons.favorite_border,
            color: hasJoin ? Colors.red : null,
            semanticLabel: hasJoin ? 'i have join' : 'i have not join',
          ),
          Text("${activity.nbCurrentParticipants}/${activity.attendeesNumber}")
        ],
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

  /// Display a dialog containing a listView of all leasons for the day
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

  Map <String, dynamic> criterionMap(){
    Map <String, dynamic> map = {"sportId":/*sport.id*/null, "keywords":keywords};
    if(widget.idHost!=null){
      map["hostId"] = widget.idHost;
    }
    return map;
  }

  void getActivities(){
    setState(() {
      futureActivities = activityUseCase.getAll(map: criterionMap());
    });
  }

  /// Used in CustomDatePicker to update [selectedDate] with [date] value.
  /// Then filter lessons.
  ///  Ces fonctions permettent de récupérer les values aux inputs du filtre

  _updateSelectedDate(DateTime date){
    setState(() {
      selectedDate = date;
    });
  }

  /// Used in a dropdown to update [sport] with [sport] value.
  /// Then filter lessons.
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

  /// Filter activities depending on [keywords], [selectedDate]
  _filterActivities(List<Activity> list){
    List<Activity> res = [];
    list.forEach((activity) {
      if(_fieldContains(activity)
          && (selectedDate ==null || activity.dateStart.getOnlyDate() == selectedDate!.getOnlyDate())
          && (sport == null || sport!.id == activity.sport.id)
          && (gender == null ||  gender == activity.criterionGender?.translate())
          && (level == null ||level!.id == activity.level.id)
          && (activity.host.id == currentUser.id || activity.public == null
              || (activity.public! || (!activity.public! && activity.host.friendsList.contains(currentUser.id)))
          )
      ){
        res.add(activity);
      }
    });
    return res;
  }

  /// Check if some activity fields contain the keywords in searchbar
  bool _fieldContains(Activity activity){
    List<String> keywordSplit = keywords.split(",");
    List<bool> contains = [];
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

  /// Update [keywords], used in searchbar controller
  void _updateKeywords() {
    setState(() {
      keywords = searchbarController.text;
    });
    //getActivities(); //could filter on the total list, or make a call to api each time keywords change (not optimized)
  }


}
