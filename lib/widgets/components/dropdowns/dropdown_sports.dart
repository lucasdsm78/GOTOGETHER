import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/usecase/sport.dart';
import 'package:localstorage/localstorage.dart';

class DropdownSports extends StatefulWidget {
  const DropdownSports({Key? key, required this.sport, required this.onChange}) : super(key: key);
  final Sport sport;
  final Function onChange;

  @override
  _DropdownSportsState createState() => _DropdownSportsState();
}

class _DropdownSportsState extends State<DropdownSports> {
  List<Sport> futureSports = [];
  final LocalStorage storage = LocalStorage('go_together_app');
  final SportUseCase sportUseCase = SportUseCase();
  late Sport sport = widget.sport ;

  void getSports() async{
    String? storedSport = await storage.getItem("sports");
    if(storedSport != null){
      log("GET DATA SPORT FROM STORAGE");
      setState(() {
        futureSports = parseSports(storedSport);
        sport = futureSports[0];
      });
    }
    else {
      log("GET DATA SPORT FROM API");
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      DropdownButtonHideUnderline(
          child: DropdownButton<Sport>(
            value: sport,
            icon: Icon(Icons.arrow_drop_down_circle),
            iconDisabledColor: Colors.red,
            iconEnabledColor: Colors.green,
            isExpanded: true,
            hint:Text("Sports"),
            elevation: 8,
            style: const TextStyle(color: Colors.deepPurple),
            onChanged: (newValue) {
              widget.onChange(newValue);
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
      );

  }
}
