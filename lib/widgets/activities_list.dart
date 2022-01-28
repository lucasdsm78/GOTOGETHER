import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/usecase/sport.dart';
import 'package:go_together/widgets/activity.dart';
import 'package:go_together/widgets/components/list_view.dart';
import 'package:localstorage/localstorage.dart';

class ActivityList extends StatefulWidget {
  const ActivityList({Key? key}) : super(key: key);

  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final SportUseCase sportUseCase = SportUseCase();
  final LocalStorage storage = LocalStorage('go_together_app');

  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _saved = <Activity>{};
  late Future<List<Activity>> futureActivities;

  late User currentUser = Mock.userGwen;
  String keywords = "";
  late Sport sport;
  List<Sport> futureSports = [];

  final searchbarController = TextEditingController();

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Activities List');

  Map <String, dynamic> criterionMap(){
    return {"sportId":/*sport.id*/null, "keywords":keywords};
  }

  void getSports() async{
    List<Sport> res = await sportUseCase.getAll();
    setState(() {
      futureSports = res;
      sport = futureSports[0];
    });
  }

  @override
  void initState() {
    super.initState();
    //getSports();
    getActivities();

    String? storedSport = storage.getItem("sports");
    if(storedSport != null){
      futureSports = parseSports(storedSport);
    }
    currentUser = User.fromJson(jsonDecode(storage.getItem("user")));

    searchbarController.addListener(_printLatestValue);
  }
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    searchbarController.dispose();
    super.dispose();
  }

  void _printLatestValue() {
    keywords = searchbarController.text;
    getActivities();
  }

  void getActivities(){
    setState(() {
      futureActivities = activityUseCase.getAll(map: criterionMap());
    });
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
      appBar: AppBar(
        title: customSearchBar,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (customIcon.icon == Icons.search) {
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar = ListTile(
                    leading: Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 28,
                    ),
                    title: TextField(
                      autofocus: true,
                      controller: searchbarController,
                      decoration: InputDecoration(
                        hintText: 'description, city, adresse...',
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  );
                } else {
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('Activities List');
                }
              });
            },
            icon: const Icon(Icons.search),
          ),
            /*DropdownButton(
            value: sport,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (newValue) {
              setState(() {
                sport = newValue as Sport;
              });
            },
            items: dropdownItems,
          )*/
        ],
        /*actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
            tooltip: 'See more',
          ),
        ],*/
      ),
      body: FutureBuilder<List<Activity>>(
        future: futureActivities,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Activity> data = snapshot.data!;
            log(data[0].toJson().toString());
            return ListViewSeparated(data: data, buildListItem: _buildRow);
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

  void _pushDetails(int activityId) {
    Navigator.of(context).push(
      // Add lines from here...
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
                (activity) {
              return ListTile(
                title: Text(
                  activity.description,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
              : <Widget>[];
          //return ActivityDetailsScreen(activityId: activityId);
          return  ActivityDetailsScreen(activityId: activityId);//ListView(children: divided)

        },
      ), // ...to here.
    );
  }

  Widget _buildRow(Activity activity) {
    final alreadySaved = _saved.contains(activity);
    final hasJoin = activity.currentParticipants!.contains(currentUser.id.toString());
    return ListTile(
      title: Text(
        activity.description + " - " + activity.host.username,
        style: _biggerFont,
      ),
      subtitle: Text("${activity.location.address}, ${activity.location.city}"),
      trailing: Icon(   // NEW from here...
        hasJoin ? Icons.favorite : Icons.favorite_border,
        color: hasJoin ? Colors.red : null,
        semanticLabel: hasJoin ? 'i have join' : 'i have not join',
      ),                // ... to here.
      onTap: () {
        setState(() {
          /*if (alreadySaved) {
            _saved.remove(activity);
          } else {
            _saved.add(activity);
          }*/
          // !snapshot.data!.currentParticipants.contains(currentUser.id.toString())
          _pushDetails(activity.id!);
        });
      },
    );
  }
}
