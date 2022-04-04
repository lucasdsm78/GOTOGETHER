import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/storage.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/usecase/sport.dart';

class DropdownSports extends StatefulWidget {
  const DropdownSports({Key? key, required this.sport, required this.onChange}) : super(key: key);
  final Sport sport;
  final Function onChange;

  @override
  _DropdownSportsState createState() => _DropdownSportsState();
}

class _DropdownSportsState extends State<DropdownSports> {
  List<Sport> futureSports = [];
  final SportUseCase sportUseCase = SportUseCase();
  late Sport sport = widget.sport ;
  final store = Storage();

  _setSport(sportList){
    setState(() {
      futureSports = sportList as List<Sport>;
      sport = futureSports[0];
    });
  }

  @override
  void initState() {
    super.initState();
    log("DROPDOWN INIT HERE");
    store.getAndStoreSportsFuture(func: _setSport);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      DropdownButton<Sport>(
        value: sport,
        elevation: 16,
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
      );
  }
}
