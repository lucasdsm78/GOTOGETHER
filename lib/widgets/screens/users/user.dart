import 'package:flutter/material.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/models/signal.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/signal.dart';
import 'package:go_together/usecase/user.dart';
import 'package:go_together/widgets/screens/users/signal.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../helper/session.dart';
import '../../../mock/user.dart';
import '../../../models/activity.dart';
import '../../../usecase/activity.dart';
import '../../components/custom_text.dart';
import '../../components/lists/custom_list.dart';
import '../../components/lists/list_view.dart';
import '../../components/text_icon.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final UserUseCase userUseCase = UserUseCase();
  final SignalUseCase signalUseCase = SignalUseCase();
  late Future<List<Activity>> futureActivities;
  late Future<User> futureUser;
  late Future<List<Signal>> futureSignal;
  late User currentUser;
  late int userId;
  final session = Session();
  bool isReported = false;
  @override
  void initState() {
    super.initState();
    userId = widget.user.id!;
    futureUser = userUseCase.getById(userId!);
    currentUser = session.getData(SessionData.user,defaultVal: MockUser.userGwen);
    futureSignal = signalUseCase.getAll(id: currentUser.id);
    futureActivities = activityUseCase.getAll(map: {"hostId":userId});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      title: 'Profile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Column(
              children:[
                FutureBuilder<List<Signal>>(
                  future: futureSignal,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      for(int i=0; i< snapshot.data!.length;i++) {
                        if (snapshot.data![i].idReported == userId) {
                          isReported = true;
                        }
                      }
                      return  ElevatedButton(
                        child: Text('Signaler'),
                        onPressed: isReported ? null : (){
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) {
                                return SignalProfile(userId: userId);
                              },
                            ),
                          );
                        },
                      );


                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }

                    // By default, show a loading spinner.
                    return const CircularProgressIndicator();
                  },
                ),
                FutureBuilder<User>(
                  future: futureUser,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data!.username);
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }

                    // By default, show a loading spinner.
                    return const CircularProgressIndicator();
                  },
                ),
                FutureBuilder<List<Activity>>(
                  future: futureActivities,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Activity> data = snapshot.data!.where((element) => element.dateEnd.isBefore(DateTime.now())).toList();
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

              ]),

        ),
      ),
    );
  }
  Widget _buildItemActivityUserHosted(Activity activity) {
    return _buildItemActivity(activity);
  }

  Widget _buildItemActivity(Activity activity) {
    final hasJoin = activity.currentAttendees!.contains(userId.toString());
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
      );
    }
}