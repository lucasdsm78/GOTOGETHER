import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/date_extension.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/mock/levels.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/level.dart';
import 'package:go_together/models/location.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:go_together/widgets/components/custom_input.dart';
import 'package:go_together/widgets/components/dropdown_gender.dart';
import 'package:go_together/widgets/components/dropdown_level.dart';
import 'package:go_together/widgets/components/dropdown_sports.dart';
import 'package:go_together/widgets/components/map_dialog.dart';
import 'package:go_together/widgets/navigation.dart';
import 'package:localstorage/localstorage.dart';

import 'activities_list.dart';
import 'components/datetime_fields.dart';

class ActivityCreate extends StatefulWidget {
  const ActivityCreate({Key? key}) : super(key: key);
  static const tag = "activity_create";

  @override
  _ActivityCreateState createState() => _ActivityCreateState();
}

class _ActivityCreateState extends State<ActivityCreate> {
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final LocalStorage storage = LocalStorage('go_together_app');

  late Sport sport = Sport.fromJson({"id": 1, "name": "football"});
  late User currentUser = Mock.userGwen;

  final _formKey = GlobalKey<FormState>();
  TextEditingController eventDescriptionInput = TextEditingController();
  TextEditingController nbManquantsInput = TextEditingController();
  TextEditingController nbTotalParticipantsInput = TextEditingController();

  String criterGender = 'Tous';
  late Level eventLevel = MockLevel.levelList[0];
  String eventDescription = "";
  int nbTotalParticipants = 0;
  Duration _duration = const Duration(hours: 0, minutes: 0);
  bool public = false;

  String dateTimeEvent = "";
  Location? location ;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //region setter
  _setEventDate(date){
      setState(() {
        dateTimeEvent = date.toString();
      });
  }
  _setEventSport(newSport) {
    setState(() {
      sport = newSport as Sport;
    });
  }
  _setEventLevel(newLevel) {
    setState(() {
      eventLevel = newLevel as Level;
    });
  }
  _setEventGender(newValue){
    setState(() {
      criterGender = newValue!;
    });
  }
  //endregion

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un évènement"),
      ),
      body: Form(
        key: _formKey,
        child: ListView( //@todo : use a ListView(children:[])
          children: <Widget>[
            CustomInput(
                title: "Description",
                notValidError: "Please enter some text for event description",
                controller: eventDescriptionInput
            ),


            Row(
              children: [
                DateTimePickerButton(
                    datetime: (dateTimeEvent !="" ? DateTime.parse(dateTimeEvent) : DateTime.now()),
                    onPressed: _setEventDate),
                Text("Date : $dateTimeEvent "),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      mapDialogue();
                    },
                    child: const Icon(Icons.map)
                ),
                Text("Lieu : " + (location != null ? "${location!.address}, ${location!.city}" : "")),
              ],
            ),

            Row(
              children: [
                Expanded(
                    flex:1,
                    child: DropdownSports(sport: sport,onChange:_setEventSport)
                ),
                Expanded(
                  flex:1,
                  child: DropdownLevel(level: eventLevel,onChange: _setEventLevel)
                ),
                Expanded(                   // Limité aux hommes ?
                flex:1,
                  child: Column(children: [
                    Text("Accessible à "),
                    DropdownGender(criterGender: criterGender, onChange: _setEventGender),
                  ],
                  )
                )
              ],
            ),
            // Event description

            Row(
              children: [
                Expanded(
                  flex:1,
                    child: // Nb total participants
                    CustomInput(
                      title: "Nombre total de participants",
                      notValidError: "Please enter a number of participant",
                      controller: nbTotalParticipantsInput,
                      type: TextInputType.number,
                    ),
                )
              ],
            ),


            // Duration
            // @todo : place it in a dialog maybe, like to select date
            Text("Duration :"),
             DurationPicker(
              duration: _duration,
              baseUnit: BaseUnit.minute,
              onChange: (val) {
                setState(() => _duration = val);
              },
              snapToMins: 5.0,
              height: 160,
            ),

            // Public / Entre amis
            Row(
              children: [
                Expanded(
                  flex:1,
                  child: ListTile(
                    title: Text("Publique"),
                    leading: Radio(
                      value: true,
                      groupValue: public,
                      onChanged: (value) {
                        setState(() {
                          public = true;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ),
                ),
                Expanded(
                    flex:1,
                    child:// Entre amis
                    ListTile(
                      title: Text("Entre amis"),
                      leading: Radio(
                        value: false,
                        groupValue: public,
                        onChanged: (value) {
                          setState(() {
                            public = false;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ),
                )
              ],
            ),


            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    eventDescription = eventDescriptionInput.text;
                    nbTotalParticipants = int.parse(nbTotalParticipantsInput.text);
                  });
                  _addEvent();
                }
              },
              child: const Text('Create event'),
            ),
          ],
        ),
      ),
    );
  }

  mapDialogue() async{
    dynamic res = await showDialog(
        context: context,
        builder: (BuildContext context){
          return MapDialog();
        }
    );
    setState(() {
      location = res as Location;
    });
    log("----- CLOSE MAP DIALOG");
    log(res.toString());
  }


  Activity _generateActivity(){
    //Location location = Location(address: "place de la boule", city: "Nanterre", country: "France", lat:10.1, lon: 12.115);
     return  Activity(location: location!, host: currentUser, sport: sport, dateEnd: parseStringToDateTime(dateTimeEvent).add(_duration),
         dateStart: parseStringToDateTime(dateTimeEvent), isCanceled: 0, description: eventDescription,  level: eventLevel,
         attendeesNumber: nbTotalParticipants, public: public, criterionGender:  (criterGender == "Tous" ? null : getGenderByString(criterGender)) , limitByLevel: false);
  }

  _addEvent() async {
    Activity activity = _generateActivity();
    log(activity.toJson());
    Activity? activityAdded = await activityUseCase.add(activity);
    if(activityAdded != null){
      Navigator.of(context).popAndPushNamed(Navigation.tag);
    }
  }
}