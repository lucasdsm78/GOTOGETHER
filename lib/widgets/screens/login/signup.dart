import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/api.dart';
import 'package:go_together/helper/asymetric_key.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/user.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:go_together/widgets/components/custom_input.dart';
import 'package:go_together/widgets/components/custom_radio.dart';

import 'package:go_together/widgets/navigation.dart';
import 'package:go_together/helper/storage.dart';
import 'package:go_together/widgets/screens/login/signin_classic.dart';

class SignUp extends StatefulWidget {
  static const tag = "signup";

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController pseudoController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPdwController = TextEditingController();

  UserUseCase userUseCase = UserUseCase();
  final _formKey = GlobalKey<FormState>();
  late Gender _gender;
  bool error = false;
  int? isMale = 0;
  DateTime? dob = null;
  final session = Session();
  final store = CustomStorage();

  handleKeys () async {
    log("######## sign in classic");
    AsymmetricKeyGenerator asymKeys= AsymmetricKeyGenerator();

    String pubkey = (await asymKeys.getPubKeyFromStorage()).toString();
    (await asymKeys.getPrivateKeyFromStorage()).toString();
    userUseCase.setPublicKey(pubkey);
  }
  validForm()async
  {
    if (_formKey.currentState!.validate()){
      if(isMale == 0){
        _gender = Gender.male;
      }else{
        _gender= Gender.female;
      }
      User user = User(username:pseudoController.text, password:passwordController.text , mail:mailController.text, role:"USER", gender:_gender, birthday: dob!);
      log(user.toMap().toString());
      User? insertedUser = await userUseCase.add(user);

      if(insertedUser != null) {
        session.setData(SessionData.user, insertedUser);
        store.storeUser(insertedUser);

        String token = await userUseCase.getJWTTokenByLogin({"mail":insertedUser.mail, "password":passwordController.text});
        Api().setToken(token);
        await handleKeys();
        Navigator.of(context).popAndPushNamed(Navigation.tag);
      }
    }
  }

  goToSignin(){
    Navigator.of(context).popAndPushNamed(SignInClassic.tag);
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
                Color(0xffa5fd6d),
                //Color(0xff50861d),
                Color(0xffe6fed7)
                // Color(0xff60e00f)
              ],),
          ),
          child: Center(
            child: SingleChildScrollView(
              child : Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Column(
                      children:
                      [
                        const Image(
                          image: AssetImage("assets/gotogether-textOnly.png"),
                          height: 70.0,
                        ),
                        const Image(
                          image: AssetImage("assets/logo-gotogether-vert.png"),
                          height: 30.0,
                        ),

                        Container(height: 40),
                        CustomInput(title: "pseudo", notValidError: 'Veuillez saisir un pseudo', controller: pseudoController,
                          border: UnderlineInputBorder(), margin: const EdgeInsets.only(),
                        ),
                        CustomInput(title: "mail", notValidError: 'Veuillez saisir un mail', controller: mailController,
                            border: UnderlineInputBorder(), margin: const EdgeInsets.only(),),
                        CustomInput(title: "password", notValidError: 'Veuillez saisir un mot de passe', controller: passwordController,
                           isPassword: true, border: UnderlineInputBorder(), margin: const EdgeInsets.only(),),
                        Container(
                          child: TextFormField(
                            obscureText: true,
                            controller: confirmPdwController,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Confirmation de mot de passe',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez confirmer le mot de passe';
                              } else if(confirmPdwController.text != passwordController.text){
                                return 'les mots de passes ne sont pas identiques';
                              }
                              return null;
                            }
                          ),
                        ),

                        Container(height: 20),
                        CustomRadio(
                            onChange: (int? value) {
                              setState(() {
                                isMale = value;
                              });
                              log(value.toString());
                            },
                            groupValue: isMale, choices: ["homme", "femme"], title: "Sexe :"
                        ),
                        Container(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Née le : ' + (dob == null ? "" : dob!.getFrenchDate())),
                            ElevatedButton(
                                onPressed: () {
                                  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime(1800),
                                      maxTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
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
                          margin: EdgeInsets.only(top: 30.0),
                          child:
                          ElevatedButton(
                            onPressed: (()=>validForm()),
                            child: const Text('Valider'),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 30.0),
                          child:
                          ElevatedButton(
                            onPressed: (()=>goToSignin()),
                            child: const Text('Déjà un compte? connectez-vous.', textAlign: TextAlign.center,),
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
            )
          ),
        ),
      )
    );
  }
}
