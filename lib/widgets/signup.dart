import 'package:flutter/material.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/user.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class SignUp extends StatefulWidget {

  @override
  State<SignUp> createState() => _SignUp();
}

class _SignUp extends State<SignUp> {
  int yearNow = DateTime.now().year;
  int monthNow = DateTime.now().month;
  int dayNow = DateTime.now().day;
  late DateTime dob;
  TextEditingController pseudo = TextEditingController();
  TextEditingController mail = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPdw = TextEditingController();
  UserUseCase activityUseCase = UserUseCase();
  final _formKey = GlobalKey<FormState>();
  late Gender _gender;
  bool error = false;
  int? val = 1;

  validForm(){
    if (_formKey.currentState!.validate()){
      if(val == 1){
        _gender = Gender.male;
      }else{
        _gender= Gender.female;
      }
      User user = User(username:pseudo.text,mail:mail.text, role:"USER", gender:_gender, birthday: dob);
      activityUseCase.add(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end:
              Alignment(0.0, 0.0), // 10% of the width, so there are ten blinds.
              colors: <Color>[
                Color(0xff50861d),
                Color(0xff60e00f)
              ],),),
          child: Center(
            child: SingleChildScrollView(
              child : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Column(
                      children:
                      [
                        Text('GO TOGETHER', style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),),
                        Container(height: 50),
                        TextFormField(
                            controller: pseudo,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'pseudo',

                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un pseudo';
                              }
                              return null;
                            }
                        ),
                        TextFormField(
                            controller: mail,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'mail',

                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un mail';
                              }
                              return null;
                            }
                        ),
                        TextFormField(
                            controller: password,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'mot de passe',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un mot de passe';
                              }
                              return null;
                            }
                        ),
                        Container(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sexe :'),
                            Row(
                              children: [
                                Text('homme'),
                                Radio(
                                  value: 1,
                                  groupValue: val,
                                  onChanged: (int? value) {
                                    setState(() {
                                      val = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('femme'),
                                Radio(
                                  value: 2,
                                  groupValue: val,
                                  onChanged: (int? value) {
                                    setState(() {
                                      val = value;
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                        Container(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Date de naissance :'),
                            ElevatedButton(
                                onPressed: () {
                                  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime(1800),
                                      maxTime: DateTime(yearNow, monthNow, dayNow),
                                      onConfirm: (date) {
                                        setState(() {
                                          dob = date;
                                        });
                                      }, currentTime: DateTime.now(), locale: LocaleType.fr);
                                },
                                child: const Icon(Icons.calendar_today_outlined)/*Text(
                  "Choisir une date pour l'évènement",
                )*/
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child:
                          TextFormField(
                              obscureText: true,
                              controller: confirmPdw,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Confirmation de mot de passe',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez confirmer le mot de passe';
                                } else if(confirmPdw.text!=password.text){
                                  return 'les mots de passes ne sont pas identiques';
                                }
                                return null;
                              }
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 30.0),
                          child:
                          ElevatedButton(
                            onPressed: (()=>validForm()),
                            child: const Text('Valider'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ),
        ),
      )
    );
  }
}
