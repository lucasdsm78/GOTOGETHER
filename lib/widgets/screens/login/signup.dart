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
import 'package:toast/toast.dart';

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


  @override
  void initState() {
    super.initState();
    mailController.addListener(_mailOnKeyPressed);
  }
  @override
  void dispose() {
    pseudoController.dispose();
    mailController.dispose();
    passwordController.dispose();
    confirmPdwController.dispose();
    super.dispose();
  }


  void validForm() async {
    if (_formKey.currentState!.validate()){
      if(isMale == 0){
        _gender = Gender.male;
      }else{
        _gender= Gender.female;
      }

      try {
        User user = User(username: pseudoController.text,
            password: passwordController.text,
            mail: mailController.text,
            role: "USER",
            gender: _gender,
            birthday: dob!);
        log(user.toMap().toString());
        User? insertedUser = await userUseCase.add(user);

        if (insertedUser != null) {
          session.setData(SessionData.user, insertedUser);
          store.storeUser(insertedUser);

          String token = await userUseCase.getJWTTokenByLogin(
              {"mail": insertedUser.mail, "password": passwordController.text});
          Api().setToken(token);
          await handleKeys();
          Navigator.of(context).popAndPushNamed(Navigation.tag);
        }
      } on ApiErr catch(err){
        Toast.show(err.message, gravity: Toast.bottom, duration: 3, backgroundColor: Colors.redAccent);
      }
    }
  }

  Future<bool> handleKeys () async {
    log("######## sign in classic");
    AsymmetricKeyGenerator asymKeys= AsymmetricKeyGenerator();

    String pubkey = (await asymKeys.getPubKeyFromStorage()).toString();
    (await asymKeys.getPrivateKeyFromStorage()).toString();
    userUseCase.setPublicKey(pubkey);
    return true;
  }

  void goToSignin(){
    Navigator.of(context).popAndPushNamed(SignInClassic.tag);
  }

  void _mailOnKeyPressed() {
    validateEmail(mailController.text);
  }

  //region validators
  String? validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value))
      return 'Veuillez saisir un mail valide';
    else
      return null;
  }
  String? validatePasswordCheck(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer le mot de passe';
    } else if(confirmPdwController.text != passwordController.text){
      return 'Les mots de passes ne sont pas identiques';
    }
    return null;
  }
  //endregion

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

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

                        Container(height: 30),
                        CustomInput(title: "Pseudo", notValidError: 'Veuillez saisir un pseudo', controller: pseudoController,
                          border: UnderlineInputBorder(), margin: const EdgeInsets.only(),
                        ),
                        CustomInput(title: "Mail", notValidError: 'Veuillez saisir un mail', controller: mailController,
                            border: UnderlineInputBorder(), margin: const EdgeInsets.only(),
                            validator: validateEmail
                        ),
                        CustomInput(title: "Mot de passe", notValidError: 'Veuillez saisir un mot de passe', controller: passwordController,
                           isPassword: true, border: UnderlineInputBorder(), margin: const EdgeInsets.only(),),

                        CustomInput(title: "Confirmer mot de passe", notValidError: 'Veuillez saisir un mot de passe', controller: confirmPdwController,
                           isPassword: true, border: UnderlineInputBorder(), margin: const EdgeInsets.only(),
                            validator: validatePasswordCheck
                        ),

                        Container(height: 10),
                        CustomRadio(
                            onChange: (int? value) {
                              setState(() {
                                isMale = value;
                              });
                              log(value.toString());
                            },
                            groupValue: isMale, choices: ["homme", "femme"], title: "Sexe :"
                        ),
                        Container(height: 10),

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
                          margin: EdgeInsets.only(top: 20.0),
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
