import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/enum/custom_colors.dart';
import 'package:go_together/models/signal.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/signal.dart';
import 'package:go_together/usecase/user.dart';

class SignalProfile extends StatefulWidget {

  const SignalProfile({Key? key, required this.userId}) : super(key: key);
  final int userId;
  static const tag = "signal";

  @override
  _SignalProfileState createState() => _SignalProfileState();
}

class _SignalProfileState extends State<SignalProfile> {

  final SignalUseCase signalUseCase = SignalUseCase();
  TextEditingController reasonInput = TextEditingController();
  String reason = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signalement',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Signalement'),
          backgroundColor: CustomColors.goTogetherMain,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Entrez la raison',
                ),
                controller: reasonInput,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                child: Text('Valid'),
                onPressed: (){
                  setState(() {
                    reason = reasonInput.text;
                  });
                  _addSignal();
                },
              ),
            ),
          ],
        )
      ),
    );
  }

  Signal _generateSignal(){
    return  Signal(idReporter: 18,idReported: widget.userId,reason: reason);
  }

  _addSignal() async {
    Signal signal = _generateSignal();
    log(signal.toJson());
    await signalUseCase.add(signal);
    log(signal.reason!);
  }
}