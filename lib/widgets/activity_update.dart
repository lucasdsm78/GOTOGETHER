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
import 'package:localstorage/localstorage.dart';

import 'activities_list.dart';

class ActivityUpdate extends StatefulWidget {
  const ActivityUpdate({Key? key}) : super(key: key);
  static const tag = "activity_create";

  @override
  _ActivityUpdate createState() => _ActivityUpdate();
}

class _ActivityUpdate extends State<ActivityUpdate> {
  List<Sport> futureSports = [];
  List<Level> futureLevels = [Level(id: 1, name: "pro"), Level(id: 2, name: "semi-pro"), Level(id: 3, name: "amateur")];
  final SportUseCase sportUseCase = SportUseCase();
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final LocalStorage storage = LocalStorage('go_together_app');
  late Future<Activity> futureActivity;

  late Sport sport; // = Sport.fromJson({"id": 1, "name": "football"});
  late User currentUser = Mock.userGwen;
  late int idActivity;

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
  late Duration _duration = Duration(hours: 0, minutes: 0);

  int yearNow = DateTime.now().year;
  int monthNow = DateTime.now().month;
  int dayNow = DateTime.now().day;
  bool public = false;

  String dateTimeEvent = "";

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
    futureActivity = activityUseCase.getById(35);
    activityUseCase.getById(35).then((value) {
      eventDescriptionInput.text = value.description;
      dateTimeEvent = value.dateStart.toString();
      nbTotalParticipantsInput.text = value.attendeesNumber.toString();
      public = value.public!;
      for(int i=0; i< futureSports.length;i++){
        if(futureSports[i].name == value.sport.name){
          sport = futureSports[i];
        }
      }
      for(int i=0; i< futureLevels.length;i++){
        if(futureLevels[i].name == value.level.name){
          eventLevel = futureLevels[i];
        }
      }
      Duration diff = value.dateEnd.difference(value.dateStart);
      _duration = Duration(hours: diff.inHours, minutes: diff.inMinutes);
      idActivity = value.id!;
    }
    );
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier un évènement"),
      ),
      body:
      FutureBuilder<Activity>(
          future: futureActivity,
          builder: (context,snapshot){
            if(snapshot.hasData){
              return Form(
                key: _formKey,
                child: ListView( //@todo : use a ListView(children:[])
                  children: <Widget>[
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(yearNow, monthNow, dayNow),
                                  onConfirm: (date) {
                                    setState(() {
                                      dateTimeEvent = date.toString();
                                    });
                                  }, currentTime: DateTime.now(), locale: LocaleType.fr);
                            },
                            child: const Icon(Icons.calendar_today_outlined)/*Text(
                  "Choisir une date pour l'évènement",
                )*/
                        ),

                        Text("Date de l'évènement $dateTimeEvent "),
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

                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0)),
                                  child: Container(
                                    height: 250,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text('Description : $eventDescription',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('Title : $titleEvent ',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('Date event : $dateTimeEvent ',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('Nombre manquants : $nbManquants ',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('Nombre total de participants : $nbTotalParticipants ',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('Public : $public ',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('Duration : $_duration ',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('Accessible à ? : $criterGender ',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('Event level ? : ${eventLevel.name} ',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        }
                      },
                      child: const Text('Update event'),
                    ),
                  ],
                ),
              );
            }
            else{
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Awaiting result...'),
                    )
                  ]
                ),
              );
            }
          }),
    );
  }

  Activity _generateActivity(){
    Location location = Location(address: "place de la boule", city: "Nanterre", country: "France", lat:10.1, lon: 12.115);
    return  Activity(id: idActivity,location: location, host: currentUser, sport: sport, dateEnd: parseStringToDateTime(dateTimeEvent).add(_duration),
        dateStart: parseStringToDateTime(dateTimeEvent), isCanceled: 0, description: eventDescription,  level: eventLevel,
        attendeesNumber: nbTotalParticipants, public: public, criterionGender:  (criterGender == "Tous" ? null : getGenderByString(criterGender)) , limitByLevel: false);
  }

  _addEvent() async {
    Activity activity = _generateActivity();
    log(activity.toJson());
    Activity? activityAdded = await activityUseCase.update(activity);
    if(activityAdded != null){
      Navigator.of(context).pushNamed(ActivityList.tag);
    }
  }
}