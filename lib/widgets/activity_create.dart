import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/user.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:go_together/usecase/sport.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:go_together/helper/session.dart';

class ActivityCreate extends StatefulWidget {
  const ActivityCreate({Key? key}) : super(key: key);

  @override
  _ActivityCreateState createState() => _ActivityCreateState();
}

class _ActivityCreateState extends State<ActivityCreate> {
  List<Sport> futureSports = [];
  final SportUseCase sportUseCase = SportUseCase();

  late Sport sport = Sport(id: 0, name: "");
  late User currentUser = Mock.userGwen;

  final _formKey = GlobalKey<FormState>();
  TextEditingController eventDescriptionInput = TextEditingController();
  TextEditingController nbManquantsInput = TextEditingController();
  TextEditingController titleEventInput = TextEditingController();
  TextEditingController nbTotalParticipantsInput = TextEditingController();

  String criterGender = 'Oui';
  String eventLevel = 'Débutant';
  String eventDescription = "";
  String titleEvent = "";
  int nbManquants = 0;
  int nbTotalParticipants = 0;
  Duration _duration = const Duration(hours: 0, minutes: 0);

  int yearNow = DateTime.now().year;
  int monthNow = DateTime.now().month;
  int dayNow = DateTime.now().day;
  bool? public = false;

  String dateTimeEvent = "";

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
    futureSports.add(sport);
    getSports();

    setCurrenUser() async {
      log("set current user here");
      await getSessionValue("user").then((res){
        log(res.toString());
        setState(() {
          currentUser = User.fromJson(res);
        });
      });
      log("current user should be set");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un évènement"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
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
                child: const Text(
                  "Choisir une date pour l'évènement",
                )
            ),

            Text("Date de l'évènement $dateTimeEvent "),

            // Event description
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

            // Event sport
            Text("Votre sport"),
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
                    child: Text(value.toString()),
                  );
                }).toList(),
            ),

            // Event nombre manquants
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

            // Nb total participants
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

            // Duration
            Text("Duration :"),
            Expanded(
                child: DurationPicker(
                  duration: _duration,
                  baseUnit: BaseUnit.minute,
                  onChange: (val) {
                    setState(() => _duration = val);
                  },
                  snapToMins: 5.0,
                )),

            // Public / Entre amis

            //Publique
            ListTile(
              title: Text("Publique"),
              leading: Radio(
                value: true,
                groupValue: public,
                onChanged: (bool? value) {
                  setState(() {
                    public = value;
                  });
                },
                activeColor: Colors.green,
              ),
            ),

            // Entre amis
            ListTile(
                title: Text("Entre amis"),
              leading: Radio(
                value: false,
                groupValue: public,
                onChanged: (bool? value) {
                  setState(() {
                    public = value;
                  });
                },
                activeColor: Colors.green,
              ),
            ),

            // Limité aux hommes ?
            Text("Limite aux hommes ?"),
            DropdownButton<String>(
                value: criterGender,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                onChanged: (String? newValue) {
                  setState(() {
                    criterGender = newValue!;
                  });
                },
                items: <String>['Oui', 'Uniquement les femmes', 'Homme et femme']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList()
            ),

            // Event level
            Text("Event level"),
            DropdownButton<String>(
                value: eventLevel,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                onChanged: (String? newValue) {
                  setState(() {
                    eventLevel = newValue!;
                  });
                },
                items: <String>['Débutant', 'Amateur', 'Confirmé']
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
                                  Text('Limité aux hommes ? : $criterGender ',
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text('Event level ? : $eventLevel ',
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
              child: const Text('Create event'),
            ),
          ],
        ),
      ),
    );
  }
}