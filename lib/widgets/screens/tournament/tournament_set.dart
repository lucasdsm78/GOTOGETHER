import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/enum/custom_colors.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/mock/levels.dart';
import 'package:go_together/models/level.dart';
import 'package:go_together/models/location.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/user.dart';
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
import 'package:localstorage/localstorage.dart';

import 'package:go_together/widgets/components/datetime_fields.dart';

import '../../../models/tournament.dart';
import '../../../usecase/tournament.dart';

//@todo refactor file into activity_set.dart
class TournamentSet extends StatefulWidget {
  const TournamentSet({Key? key, this.tournament}) : super(key: key);
  static const tag = "tournament_create";
  final Tournament? tournament;

  @override
  _TournamentSetState createState() => _TournamentSetState();
}

class _TournamentSetState extends State<TournamentSet> {
  final TournamentUseCase tournamentUseCase = TournamentUseCase();
  final LocalStorage storage = LocalStorage('go_together_app');

  late Sport? sport = null;
  late User currentUser;

  final _formKey = GlobalKey<FormState>();
  TextEditingController eventDescriptionInput = TextEditingController();
  TextEditingController nbManquantsInput = TextEditingController();
  TextEditingController nbTotalParticipantsInput = TextEditingController();
  TextEditingController nbEquipInput = TextEditingController();

  String? criterGender = null;
  late Level eventLevel = MockLevel.levelList[0];
  String eventDescription = "";
  int nbTotalParticipants = 0;
  int nbEquip= 0;
  Duration _duration = Duration(hours: 0, minutes: 0);
  bool public = false;

//  String dateTimeEvent = "";
  DateTime dateTimeEvent = DateTime.now();
  Location? location ;
  bool isUpdating = false;
  final session = Session();

  @override
  void initState() {
    super.initState();
    currentUser = session.getData(SessionData.user);

    isUpdating = widget.tournament !=null;
    if(isUpdating){
      Tournament currentTournament = widget.tournament!;

      sport = currentTournament.sport;
      criterGender = (currentTournament.criterionGender != null ? currentTournament.criterionGender!.translate() : null);
      eventLevel = currentTournament.level;
      eventDescriptionInput.text = currentTournament.description;
      nbTotalParticipantsInput.text = currentTournament.attendeesNumber.toString();
      nbTotalParticipants = currentTournament.attendeesNumber;
      nbEquipInput.text= currentTournament.nbEquip.toString();
      nbEquip= currentTournament.nbEquip;
      _duration = currentTournament.dateEnd.difference(currentTournament.dateStart);
      public = currentTournament.public!;
      dateTimeEvent = currentTournament.dateStart;
      location = currentTournament.location;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  //region setter
  ///_set... function
  /// infor the API on required value for create or update an Tournament
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
  //end setter region

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un tournoi"),
        backgroundColor: CustomColors.goTogetherMain,
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

            /// A form field for tap the limit number team can participate an tournament
            CustomInput(
              title: "Nombre d'équipe",
              notValidError: "Please enter a number of participant",
              controller: nbEquipInput,
              type: TextInputType.number,
            ),

            ///form field for total particpant number
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
            ///Radio button for inform if a tournament is privacy or not
            RadioPrivacy(onChange: _setEventPrivacy, groupValue: public),

            ///generate a button for submit the form if completed correctly for Update or Create a new Tournament.
            RightWrongButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    eventDescription = eventDescriptionInput.text;
                    nbTotalParticipants = int.parse(nbTotalParticipantsInput.text);
                  });
                  _updateOrAddEvent();
                }
              },
              width: 5.0,
              height: 5.0,
              textButton: isUpdating ? "METTRE A JOUR " : "CREER L'EVENEMENT",
            ),
          ],
        ),
      ),
    );
  }
  ///For choose th tournament place,
  ///This function open a popUp screen containing a map for select the location of tournament.
  ///After pick a place, return the location in text text format
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

  ///For update an tournament This function check the data in form.
  ///If the form is filled  return a new tournament Object with the current data
  ///_generateTournament() .
  Tournament? _generateTournament(){
    if(sport != null) { // check the data in Form
      //Location location = Location(address: "place de la boule", city: "Nanterre", country: "France", lat:10.1, lon: 12.115);
      return Tournament(
          id: (widget.tournament == null ? null : widget.tournament!.id!),
          location: location!,
          host: currentUser,
          sport: sport!,
          dateEnd: dateTimeEvent.add(_duration),
          dateStart: dateTimeEvent,
          isCanceled: 0,
          description: eventDescription,
          level: eventLevel,
          attendeesNumber: nbTotalParticipants,
          public: public,
          criterionGender: (criterGender == null ? null : getGenderByString(criterGender!)),
          limitByLevel: false,
          nbEquip: nbEquip,
          );
    }
  }

  /// Add an event in DB, calling _generateTournament() function.
  /// if all form fields are filled , then the tournament can be created.
  /// if the tournament already exist, we update it
  ///_updateOrAddEvent() :
  _updateOrAddEvent() async {
    Tournament? tournament = _generateTournament();
    if(tournament != null) {
      log(tournament.toJson());
      Tournament? tournamentAdded = (isUpdating ? await tournamentUseCase.update(tournament) : await tournamentUseCase.add(tournament));
      if (tournamentAdded != null) {
        Navigator.of(context).popAndPushNamed(Navigation.tag);
      }
    }
  }
}