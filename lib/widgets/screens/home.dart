import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_together/helper/NotificationCenter.dart';
import 'package:go_together/helper/enum/custom_colors.dart';
import 'package:go_together/helper/error_helper.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/widgets/components/buttons/header_tabs.dart';
import 'package:go_together/widgets/components/lists/custom_list.dart';
import 'package:go_together/widgets/components/lists/tabs_element.dart';
import 'package:go_together/widgets/components/text_icon.dart';
import 'package:go_together/widgets/screens/activities/activity_details.dart';
import 'package:go_together/widgets/screens/activities/activity_set.dart';
import 'package:go_together/widgets/components/custom_text.dart';
import 'package:go_together/widgets/components/lists/list_view.dart';

import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:go_together/widgets/screens/users/profile.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  static const tag = "home";

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with Observer{
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final session = Session();
  late Future<List<Activity>> futureActivities;
  late Future<List<Activity>> futureActivitiesProposition;
  late Future<List<Activity>> futureActivitiesUser;
  late User currentUser;
  int colID = 0;


  void getActivities(){
    setState(() {
      futureActivities = activityUseCase.getAll(map: {"hostId":currentUser.id});
      futureActivitiesProposition = activityUseCase.getAllProposition(currentUser.id!);
      futureActivitiesUser = activityUseCase.getByUserId(currentUser.id!);
    });
  }

  @override
  void initState() {
    super.initState();
    currentUser = session.getData(SessionData.user);
    getActivities();
    Observable.instance.addObserver(this);
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void update(Observable observable, String? notifyName, Map? map) {
    if(notifyName == NotificationCenter.userJoinActivity.name
        || notifyName == NotificationCenter.userCancelActivity.name
        || notifyName == NotificationCenter.setActivityHost.name
    ){
      getActivities();
    }
    //throw UnimplementedError();
  }

  void _setColID(int newId){
    setState(() {
      colID = newId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        backgroundColor: CustomColors.goTogetherMain,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle_rounded),
            tooltip: 'Profile Icon',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Profile(),
                ),
              );            },
          ), //IconButton
        ],
      ),
      body: Column(
        children: [
          Container(
            child: Image(
              image: AssetImage("assets/football.jpg"),
              height: 110.0,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width
            ),
          ),
          HeaderTabs(
              tabsWidget: const [
                TextIcon(title:"Mes activités", icon: Icon(MdiIcons.crown)),
                TextIcon(title:"Propositions", icon: Icon(MdiIcons.calendarMultipleCheck)),
                TextIcon(title:"Participations", icon: Icon(MdiIcons.handBackRightOutline))
              ],
              onPress: _setColID
          ),
          /*Container(
            margin: const EdgeInsets.only(bottom: 20.0),

            child : Image.asset(
                'assets/football.jpg',
                height: 160,
                width: screenWidth,
                fit:BoxFit.fitWidth
            ),
          ),*/

          TabsElement(
            children:[
              FutureBuilder<List<Activity>>(
                future: futureActivities,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Activity> data = snapshot.data!;
                    if(data.isEmpty){
                      return const  Center(
                        child: Text("Vous n'avez pas créé d'événement récemment"),
                      );
                    }
                    return ListViewSeparated(data: data, buildListItem: _buildItemActivityUserHosted);
                  } else if (snapshot.hasError) {
                    return getSnapshotErrWidget(snapshot);
                  }
                  return const Center(
                      child: CircularProgressIndicator()
                  );
                },
              ),
              FutureBuilder<List<Activity>>(
                future: futureActivitiesProposition,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Activity> data = snapshot.data!;

                    if(data.isEmpty){
                      return const  Center(
                        child: Text("Aucune proposition actuellement"),
                      );
                    }
                    return ListViewSeparated(data: data, buildListItem: _buildItemActivityProposition);
                  } else if (snapshot.hasError) {
                    return getSnapshotErrWidget(snapshot);
                  }
                  return const Center(
                      child: CircularProgressIndicator()
                  );
                },
              ),
              FutureBuilder<List<Activity>>(
                future: futureActivitiesUser,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Activity> data = snapshot.data!;

                    if(data.isEmpty){
                      return const  Center(
                        child: Text("Vous ne participez à aucun événement actuellement"),
                      );
                    }
                    return ListViewSeparated(data: data, buildListItem: _buildItemActivityProposition);
                  } else if (snapshot.hasError) {
                    return getSnapshotErrWidget(snapshot);
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
      ),
    );
  }

  //region redirection
  void _seeMore(Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return  ActivityDetailsScreen(activity: activity);
        },
      ),
    );
  }

  void _goToUpdateActivity(Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return ActivitySet(activity: activity);
        },
      ),
    );
  }
  //endregion

  //region build items for list
  /// The item to add in list.
  /// We don't use it directly in listview because we need to define the action.
  /// For host activity we want to go to update activity, and for other to see
  /// activity details screen
  Widget _buildItemActivity(Activity activity, Function onTap) {
    final hasJoin = activity.currentAttendees!.contains(currentUser.id.toString());
    return ListTile(
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
          TextIcon(
              title: activity.dateStart.getFrenchDateTime(),
              icon:Icon(MdiIcons.calendar, color: Colors.green),
              mainAxisAlignment:MainAxisAlignment.start
          )
        ]
      ),
      trailing: CustomColumn(
        children: [
          Icon(
            hasJoin ? Icons.favorite : Icons.favorite_border,
            color: hasJoin ? Colors.red : null,
            semanticLabel: hasJoin ? 'i have join' : 'i have not join',
          ),
          Text("${activity.nbCurrentParticipants}/${activity.attendeesNumber}"),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              await Share.share(activity.description + "\n" + activity.location.address);
            },
          )
        ],
      ),
      onTap: () {
        onTap(activity);
      },
    );
  }

  Widget _buildItemActivityProposition(Activity activity) {
    return _buildItemActivity(activity, _seeMore);
  }
  Widget _buildItemActivityUserHosted(Activity activity) {
    return _buildItemActivity(activity, _goToUpdateActivity);
  }
  //endregion



}
