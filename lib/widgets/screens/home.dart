import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_together/helper/NotificationCenter.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/tournament.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/widgets/components/lists/custom_list.dart';
import 'package:go_together/widgets/components/text_icon.dart';
import 'package:go_together/widgets/screens/activities/activity_details.dart';
import 'package:go_together/widgets/screens/activities/activity_set.dart';
import 'package:go_together/widgets/components/custom_text.dart';
import 'package:go_together/widgets/components/lists/list_view.dart';

import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
  late User currentUser;

  void getActivities(){
    setState(() {
      futureActivities = activityUseCase.getAll(map: {"hostId":currentUser.id});
      futureActivitiesProposition = activityUseCase.getAllProposition(currentUser.id!);
    });
  }

  @override
  void initState() {
    super.initState();
    currentUser = session.getData(SessionData.user,defaultVal: MockUser.userGwen);
    getActivities();
    Observable.instance.addObserver(this);
  }

  @override
  void dispose() {
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
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body:
      Container(
        margin: const EdgeInsets.only(left: 5, right: 5),

        child: ListView(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 20.0),

              child : Image.asset(
                'assets/football.jpg',
                height: 160,
                width: screenWidth,
                fit:BoxFit.fitWidth
              ),
            ),

            TextIcon(title: 'Mes activités organisées'),
            FutureBuilder<List<Activity>>(
              future: futureActivities,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Activity> data = snapshot.data!;
                  if(data.isEmpty){
                    return const  Center(
                      child: Text("Vous n'avez pas créer d'événement récement"),
                    );
                  }
                  return Container(
                    width: screenWidth*85,
                    height: 120,
                    child:ListViewSeparated(data: data, buildListItem: _buildItemActivityUserHosted, axis: Axis.horizontal,)
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return const Center(
                    child: CircularProgressIndicator()
                );
              },
            ),

            const Divider(),
            TextIcon(title: 'Evènements proposés'),
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
                  return Container(
                      width: screenWidth*85,
                      height: 120,
                      child:ListViewSeparated(data: data, buildListItem: _buildItemActivityProposition, axis: Axis.horizontal,)
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return const Center(
                    child: CircularProgressIndicator()
                );
              },
            ),

          ],
        ),
      )
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
          Text("${activity.nbCurrentParticipants}/${activity.attendeesNumber}")
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
