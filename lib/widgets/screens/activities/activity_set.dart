import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/NotificationCenter.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
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
import 'package:go_together/widgets/components/lists/custom_row.dart';
import 'package:go_together/widgets/components/dropdowns/dropdown_gender.dart';
import 'package:go_together/widgets/components/dropdowns/dropdown_level.dart';
import 'package:go_together/widgets/components/dropdowns/dropdown_sports.dart';
import 'package:go_together/widgets/components/maps/map_dialog.dart';
import 'package:go_together/widgets/components/radio_privacy.dart';
import 'package:go_together/widgets/navigation.dart';
import 'package:localstorage/localstorage.dart';

import 'package:go_together/widgets/components/datetime_fields.dart';

//@todo refactor file into activity_set.dart
class ActivitySet extends StatefulWidget {
  const ActivitySet({Key? key, this.activity}) : super(key: key);
  static const tag = "activity_create";
  final Activity? activity;

  @override
  _ActivitySetState createState() => _ActivitySetState();
}

class _ActivitySetState extends State<ActivitySet> {
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final LocalStorage storage = LocalStorage('go_together_app');

  late Sport sport = Sport.fromJson({"id":1,"name":"football"});
  late User currentUser = Mock.userGwen;

  final _formKey = GlobalKey<FormState>();
  TextEditingController eventDescriptionInput = TextEditingController();
  TextEditingController nbManquantsInput = TextEditingController();
  TextEditingController nbTotalParticipantsInput = TextEditingController();

  String criterGender = 'Tous';
  late Level eventLevel = MockLevel.levelList[0];
  String eventDescription = "";
  int nbTotalParticipants = 0;
  Duration _duration = Duration(hours: 0, minutes: 0);
  bool public = false;

//  String dateTimeEvent = "";
  DateTime dateTimeEvent = DateTime.now();
  Location? location ;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    isUpdating = widget.activity !=null;
    if(isUpdating){
      activityUseCase.getById(widget.activity!.id!).then((value) {
        sport = value.sport;
        criterGender = (value.criterionGender != null ? value.criterionGender!.translate() : "Tous");
        eventLevel = value.level;
        eventDescriptionInput.text = value.description;
        nbTotalParticipantsInput.text = value.attendeesNumber.toString();
        nbTotalParticipants = value.attendeesNumber;
        setState(() {
          _duration = value.dateEnd.difference(value.dateStart);
        });
        public = value.public!;
        dateTimeEvent = value.dateStart;
        location = value.location;

      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  //region setter
  _setEventDate(date){
      setState(() {
        dateTimeEvent = date as DateTime;
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
  _setEventPrivacy(newValue){
    setState(() {
      public = newValue!;
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
                    datetime: dateTimeEvent ,
                    onPressed: _setEventDate),
                Text("Date : ${dateTimeEvent.getFrenchDateTime()} "),
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

            CustomRow(children: [
              DropdownSports(sport: sport,onChange:_setEventSport),
              DropdownLevel(level: eventLevel,onChange: _setEventLevel),
              Column(children: [
                Text("Accessible à "),
                DropdownGender(criterGender: criterGender, onChange: _setEventGender),
              ],
              )
            ]),

            CustomRow(
              children: [
                CustomInput(
                  title: "Nombre total de participants",
                  notValidError: "Please enter a number of participant",
                  controller: nbTotalParticipantsInput,
                  type: TextInputType.number,
                ),
              ]
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
            RadioPrivacy(onChange: _setEventPrivacy, groupValue: public),

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
              child: Text((isUpdating ? "Mettre à jour " : "Créer l'événement")),
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
          return MapDialog(location: location,);
        }
    );
    if(res != null){
      setState(() {
        location = res as Location;
      });
      log("----- CLOSE MAP DIALOG");
      log(res.toString());
    }
  }


  Activity _generateActivity(){
    //Location location = Location(address: "place de la boule", city: "Nanterre", country: "France", lat:10.1, lon: 12.115);
     return  Activity(location: location!, host: currentUser, sport: sport, dateEnd: dateTimeEvent.add(_duration),
         dateStart: dateTimeEvent, isCanceled: 0, description: eventDescription,  level: eventLevel,
         attendeesNumber: nbTotalParticipants, public: public, criterionGender:  (criterGender == "Tous" ? null : getGenderByString(criterGender)),
       limitByLevel: false, id: widget.activity!.id!);
  }

  _addEvent() async {
    Activity activity = _generateActivity();
    log(activity.toJson());
    Activity? activityAdded =(isUpdating ? await activityUseCase.update(activity) :await activityUseCase.add(activity) );
    if(activityAdded != null){
      Navigator.of(context).popAndPushNamed(Navigation.tag);
    }
  }
}