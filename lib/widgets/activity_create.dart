import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/date_extension.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/level.dart';
import 'package:go_together/models/location.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/user.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/usecase/sport.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:duration_picker/duration_picker.dart';
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
  List<Sport> futureSports = [];
  List<Level> futureLevels = [Level(id: 1, name: "pro"), Level(id: 2, name: "semi-pro"), Level(id: 3, name: "amateur")];
  final SportUseCase sportUseCase = SportUseCase();
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final LocalStorage storage = LocalStorage('go_together_app');

  late Sport sport = Sport.fromJson({"id": 1, "name": "football"});
  late User currentUser = Mock.userGwen;

  final _formKey = GlobalKey<FormState>();
  TextEditingController eventDescriptionInput = TextEditingController();
  TextEditingController nbManquantsInput = TextEditingController();
  TextEditingController titleEventInput = TextEditingController();
  TextEditingController nbTotalParticipantsInput = TextEditingController();

  String criterGender = 'Tous';
  late Level eventLevel;
  String eventDescription = "";
  String titleEvent = "";
  int nbManquants = 0;
  int nbTotalParticipants = 0;
  Duration _duration = const Duration(hours: 0, minutes: 0);

  int yearNow = DateTime.now().year;
  int monthNow = DateTime.now().month;
  int dayNow = DateTime.now().day;
  bool public = false;

  String dateTimeEvent = "";
  Location? location ;

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

  @override
  void initState() {
    super.initState();
    getSports();
    eventLevel = futureLevels[0];
  }

  @override
  void dispose() {
    super.dispose();
  }

  _setEventDate(date){
      setState(() {
        dateTimeEvent = date.toString();
      });
  }

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

            // Event title
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Title',
              ),
              // Check if event description are not empty
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text for event title';
                }
                return null;
              },
              controller: titleEventInput,
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

            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Description',
              ),
              // Check if event description are not empty
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text for event description';
                }
                return null;
              },
              controller: eventDescriptionInput,
            ),

            Row(
              children: [
                Expanded(
                    flex:1,
                    child:
                    // Event sport
                    //Text("Votre sport"),
                  DropdownButton<Sport>(
                    value: sport,
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    onChanged: (newValue) {
                      setState(() {
                        sport = newValue as Sport;
                      });
                    },
                    items: futureSports.map<DropdownMenuItem<Sport>>((Sport value) {
                      return DropdownMenuItem<Sport>(
                        value: value,
                        child: Text(value.name.toString()),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  flex:1,
                  child:
                  // Event level
                  //Text("Event level"),
                    DropdownButton<Level>(
                      value: eventLevel,
                      elevation: 16,
                      style: const TextStyle(color: Colors.deepPurple),
                      onChanged: (newValue) {
                        setState(() {
                          eventLevel = newValue as Level;
                        });
                      },
                      items: futureLevels.map<DropdownMenuItem<Level>>((Level value) {
                        return DropdownMenuItem<Level>(
                          value: value,
                          child: Text(value.name.toString()),
                        );
                      }).toList(),
                    ),
                )
              ],
            ),
            // Event description

            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: // Event nombre manquants
                    //@todo : nb manquant surement pas utiles, et aucun champs prévu en BDD
                    TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Nombre manquants',
                      ),
                      keyboardType: TextInputType.number,
                      // Check if event description are not empty
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text for this input';
                        }
                        return null;
                      },
                      controller: nbManquantsInput,
                    ),
                ),
                Expanded(
                  flex:1,
                    child: // Nb total participants
                    TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Nombre total de participants',
                      ),
                      keyboardType: TextInputType.number,
                      // Check if event description are not empty
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text for this input';
                        }
                        return null;
                      },
                      controller: nbTotalParticipantsInput,
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
            //Publique
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
                          public = value as bool;
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
                            public = value as bool;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ),
                )
              ],
            ),




            // Limité aux hommes ?
            Text("Accessible à "),
            DropdownButton<String>(
              value: criterGender,
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              onChanged: (String? newValue) {
                setState(() {
                  criterGender = newValue!;
                });
              },
              items: <String>['Tous', 'Hommes', 'Femmes']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList()
          ),


            ElevatedButton(
              onPressed: () {
                // Check the form and return true if it's valid, false otherwise
                if (_formKey.currentState!.validate()) {
                  // We display a snack bar if the form is valid
                  // And then, we insert into database data form

                  setState(() {
                    eventDescription = eventDescriptionInput.text;
                    titleEvent = titleEventInput.text;
                    nbManquants = int.parse(nbManquantsInput.text);
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