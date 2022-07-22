import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/api.dart';
import 'package:go_together/helper/enum/custom_colors.dart';
import 'package:go_together/helper/google_authentication.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/user.dart';
import 'package:go_together/widgets/components/buttons/google_sign_in_button.dart';
import 'package:go_together/widgets/components/custom_input.dart';
import 'package:go_together/helper/storage.dart';

import 'package:go_together/widgets/navigation.dart';
import 'package:go_together/widgets/screens/login/signup.dart';
import 'package:toast/toast.dart';

class SignInClassic extends StatefulWidget {
  static const tag = "signin_classic";

  @override
  State<SignInClassic> createState() => _SignInClassicState();
}

class _SignInClassicState extends State<SignInClassic> {
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  UserUseCase userUseCase = UserUseCase();
  final _formKey = GlobalKey<FormState>();
  bool error = false;
  final session = Session();
  final store = CustomStorage();

  validForm () async
  {
    if (_formKey.currentState!.validate()){
      try{
        String token = await userUseCase.getJWTTokenByLogin({"mail":mailController.text, "password":passwordController.text});
        log(token);

        if(token != null) {
          Api().setToken(token);
          User currentUser = await userUseCase.getByToken();
          session.setData(SessionData.user, currentUser);
          store.storeUser(currentUser);

          Navigator.of(context).popAndPushNamed(Navigation.tag);
        }
      } on ApiErr catch(err){
        Toast.show(err.message, gravity: Toast.bottom, duration: 3, backgroundColor: Colors.redAccent);
      }
    }
  }
  goToSignup(){
    Navigator.of(context).popAndPushNamed(SignUp.tag);
  }

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

                          Container(height: 40),
                          CustomInput(title: "pseudo/mail", notValidError: 'Veuillez saisir un mail ou un pseudo', controller: mailController,
                            border: UnderlineInputBorder(), margin: const EdgeInsets.only(),
                          ),
                          CustomInput(title: "password", notValidError: 'Veuillez saisir un mot de passe', controller: passwordController,
                            isPassword: true, border: UnderlineInputBorder(), margin: const EdgeInsets.only(),),

                          Container(height: 20),

                          Container(
                            margin: EdgeInsets.only(top: 30.0),
                            child:
                            ElevatedButton(
                              onPressed: (()=>validForm()),
                              child: const Text('Valider'),
                            ),
                          ),

                          FutureBuilder(
                            future: GoogleAuthentication.initializeFirebase(context: context),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error initializing Firebase');
                              } else if (snapshot.connectionState == ConnectionState.done) {
                                return GoogleSignInButton();
                              }
                              return CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  CustomColors.firebaseOrange,
                                ),
                              );
                            },
                          ),


                          Container(
                            margin: EdgeInsets.only(top: 30.0),
                            child:
                            ElevatedButton(
                              onPressed: (()=>goToSignup()),
                              child: const Text('Pas de compte? Inscrivez-vous.', textAlign: TextAlign.center),
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
