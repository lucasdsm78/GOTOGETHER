import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_together/helper/NotificationCenter.dart';
import 'package:go_together/helper/date_extension.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/usecase/sport.dart';
import 'package:go_together/widgets/activity.dart';
import 'package:go_together/widgets/activity_set.dart';
import 'package:go_together/widgets/components/custom_text.dart';
import 'package:go_together/widgets/components/filter_dialog.dart';
import 'package:go_together/widgets/components/list_view.dart';
import 'package:localstorage/localstorage.dart';

import 'components/search_bar.dart';
import 'components/custom_datepicker.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';

//@todo : il faudrait un bouton qui affiche les filtres
class ActivityList extends StatefulWidget {
  const ActivityList({Key? key}) : super(key: key);
  static const tag = "activity_list";

  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> with Observer{
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final SportUseCase sportUseCase = SportUseCase();
  final LocalStorage storage = LocalStorage('go_together_app');

  late Future<List<Activity>> futureActivities;

  late User currentUser;
  String keywords = "";
  late Sport sport;
  List<Sport> futureSports = [];
  DateTime? selectedDate;//DateTime.now();

  final searchbarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getSports();
    getActivities();
    currentUser = User.fromJson(jsonDecode(storage.getItem("user")));
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
          customSearchBar: const Text('Activities List'),
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
  slidableActionCurrentUserActivity(BuildContext context, Activity activity) {
    return SlidableAction(
      onPressed: (BuildContext) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) {
              return  ActivityCreate(activity: activity);
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

  Widget _buildRow(Activity activity) {
    final hasJoin = activity.currentParticipants!.contains(currentUser.id.toString());
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

  /// Display a dialog containing a listView of all leasons for the day
  Future<Null> dialogue() async{
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return FilterDialog(selectedDate: selectedDate, onSelectDate: _updateSelectedDate,
            sport: sport, sportList: futureSports, onChangeSport: _updateSelectedSport,);
        }
    );
  }


  Map <String, dynamic> criterionMap(){
    return {"sportId":/*sport.id*/null, "keywords":keywords};
  }

  void getSports() async{
    String? storedSport = storage.getItem("sports");
    if(storedSport != null){
      setState(() {
        futureSports = parseSports(storedSport);
        sport = futureSports[0];
      });
    }
    else {
      List<Sport> res = await sportUseCase.getAll();
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

  /// Used in CustomDatePicker to update [selectedDate] with [date] value.
  /// Then filter lessons.
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

  /// Filter activities depending on [keywords], [selectedDate]
  _filterActivities(List<Activity> list){
    List<Activity> res = [];
    list.forEach((activity) {
      if(_fieldContains(activity)
          && (selectedDate ==null || activity.dateStart.getOnlyDate() == selectedDate!.getOnlyDate())
          && sport.id == activity.sport.id){
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
