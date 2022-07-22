import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/NotificationCenter.dart';
import 'package:go_together/helper/api.dart';
import 'package:go_together/helper/enum/custom_colors.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/mock/levels.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/level.dart';
import 'package:go_together/models/location.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:go_together/widgets/components/base_container.dart';
import 'package:go_together/widgets/components/buttons/custom_button_right.dart';
import 'package:go_together/widgets/components/custom_input.dart';
import 'package:go_together/widgets/components/dropdowns/dropdown_gender.dart';
import 'package:go_together/widgets/components/dropdowns/dropdown_level.dart';
import 'package:go_together/widgets/components/dropdowns/dropdown_sports.dart';
import 'package:go_together/widgets/components/maps/map_dialog.dart';
import 'package:go_together/widgets/components/radio_privacy.dart';
import 'package:go_together/widgets/navigation.dart';
import 'package:go_together/widgets/screens/activities/activity_attendees.dart';

import 'package:go_together/widgets/components/datetime_fields.dart';
import 'package:toast/toast.dart';


/// This screen is the one to create an activity.
/// If [activity] is provided, then this page is used to update the activity
/// instead of create.
class ActivitySet extends StatefulWidget {
  const ActivitySet({Key? key, this.activity}) : super(key: key);
  static const tag = "activity_create";
  final Activity? activity;

  @override
  _ActivitySetState createState() => _ActivitySetState();
}

class _ActivitySetState extends State<ActivitySet> {
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final Session session = Session();

  late Sport? sport = null;
  late User currentUser = Session().getData(SessionData.user);

  final _formKey = GlobalKey<FormState>();
  TextEditingController eventDescriptionInput = TextEditingController();
  TextEditingController nbManquantsInput = TextEditingController();
  TextEditingController nbTotalParticipantsInput = TextEditingController();

  String? criterGender = null;
  late Level eventLevel = MockLevel.levelList[0];
  String eventDescription = "";
  bool formIsSet = false;
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
      Activity currentActivity = widget.activity!;

      sport = currentActivity.sport;
      criterGender = (currentActivity.criterionGender != null ? currentActivity.criterionGender!.translate() : null);
      eventLevel = currentActivity.level;
      eventDescriptionInput.text = currentActivity.description;
      nbTotalParticipantsInput.text = currentActivity.attendeesNumber.toString();
      nbTotalParticipants = currentActivity.attendeesNumber;
      _duration = currentActivity.dateEnd.difference(currentActivity.dateStart);
      public = currentActivity.public!;
      dateTimeEvent = currentActivity.dateStart;
      location = currentActivity.location;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  //region setter
  void _setEventDate(date){
      setState(() {
        dateTimeEvent = date as DateTime;
      });
  }
  void _setEventSport(newSport) {
    setState(() {
      sport = newSport as Sport;
    });
  }
  void _setEventLevel(newLevel) {
    setState(() {
      eventLevel = newLevel as Level;
    });
  }
  void _setEventGender(String? newValue){
    setState(() {
      criterGender = newValue;
    });
  }
  void _setEventPrivacy(newValue){
    setState(() {
      public = newValue!;
    });
  }
  //endregion

  /// Create a map dialog that is displayed on screen.
  /// then, we should select a position and confirm the location.
  /// location data should be displayed after we close the dialog.
  void mapDialogue() async{
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

  /// redirect to a page with all the attendees of this event displayed
  /// to select the next host.
  void _changeOrganiser(Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return  ActivitiesAttendees(activity: activity);
        },
      ),
    );
  }

  Activity? _generateActivity(){
    if(sport != null) { // check the data in Form
      //Location location = Location(address: "place de la boule", city: "Nanterre", country: "France", lat:10.1, lon: 12.115);
      return Activity(location: location!,
          host: currentUser,
          sport: sport!,
          dateEnd: dateTimeEvent.add(_duration),
          dateStart: dateTimeEvent,
          isCanceled: 0,
          description: eventDescription,
          level: eventLevel,
          attendeesNumber: nbTotalParticipants,
          public: public,
          criterionGender: (criterGender == null ? null : getGenderByString(
              criterGender!)),
          limitByLevel: false,
          id: (widget.activity == null ? null : widget.activity!.id!));
    }
  }

  void _addEvent() async {
    Activity? activity = _generateActivity();
    if(activity != null) {
      log(activity.toJson());
      try {
        Activity? activityAdded = (isUpdating ? await activityUseCase.update(
            activity) : await activityUseCase.add(activity));
        if (activityAdded != null) {
          Navigator.of(context).popAndPushNamed(Navigation.tag);
        }
      } on ApiErr catch(err){
        Toast.show(err.message, gravity: Toast.bottom, duration: 3, backgroundColor: Colors.redAccent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return Scaffold(
      appBar: AppBar(
        title:  isUpdating ? Text("Mis à jour de l'événement") : Text("Créer un évènement"),
        backgroundColor: CustomColors.goTogetherMain,
      ),
      body: Form(
        key: _formKey,
        onChanged: () =>{
          if(eventDescriptionInput.text != "" &&  nbTotalParticipantsInput.text != ""){
            formIsSet = true
          }
        },
        child: ListView( //@todo : use a ListView(children:[])
          children: <Widget>[
            CustomInput(
                title: "Description",
                notValidError: "Please enter some text for event description",
                controller: eventDescriptionInput
            ),

            BaseContainer(
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  children: [
                    DateTimePickerButton(
                        datetime: dateTimeEvent ,
                        onPressed: _setEventDate),
                    BaseContainer(
                      child:Text("Date : ${dateTimeEvent.getFrenchDateTime()} "),
                      margin: EdgeInsets.only(left:5, right:5),
                      useBorder: false,
                    ),
                  ],
                ),
              ),
              useBorder: false,
            ),
            BaseContainer(
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          mapDialogue();
                        },
                        child: const Icon(Icons.map)
                    ),
                    BaseContainer(
                      child:Text("Lieu : " + (location != null ? "${location!.address}, ${location!.city}" : "")),
                      margin: EdgeInsets.only(left:5, right:5),
                      useBorder: false,
                    ),
                  ],
                ),
              ),
              useBorder: false,
            ),

            //region dropdowns
            BaseContainer(
              child: DropdownSports(sport: sport,onChange:_setEventSport),
            ),
            BaseContainer(
              child: DropdownLevel(level: eventLevel,onChange: _setEventLevel),
            ),
            BaseContainer(
              child: DropdownGender(criterGender: criterGender, onChange: _setEventGender),
            ),
            //endregion

            CustomInput(
              title: "Nombre total de participants",
              notValidError: "Please enter a number of participant",
              controller: nbTotalParticipantsInput,
              type: TextInputType.number,
            ),


            // Duration
            // @todo : place it in a dialog maybe, like to select date
            BaseContainer(
              child: Text("Durée :"),
              useBorder: false,
            ),
            BaseContainer(
              child: DurationPicker(
                duration: _duration,
                baseUnit: BaseUnit.minute,
                onChange: (val) {
                  setState(() => _duration = val);
                },
                snapToMins: 5.0,
                height: 160,
              ),
              useBorder: false,
            ),

            // Public / Entre amis
            RadioPrivacy(onChange: _setEventPrivacy, groupValue: public),

            ElevatedButton(
              onPressed: formIsSet && location != null && sport != null && (_duration.inMinutes > 0 || _duration.inHours > 0) ?() {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    eventDescription = eventDescriptionInput.text;
                    nbTotalParticipants = int.parse(nbTotalParticipantsInput.text);
                  });
                  _addEvent();
                }
              } : null,
              child: isUpdating ? Text("METTRE A JOUR ") : Text("CREER L'EVENEMENT"),
            ),

            (isUpdating
                ? RightWrongButton(
                  onPressed: () {
                    _changeOrganiser(widget.activity!);
                  },
                  width: 5.0,
                  height: 5.0,
                  textButton: "CHANGER ORGANISATEUR",
                )
                : Container()
            )

          ],
        ),
      ),
    );
  }

}