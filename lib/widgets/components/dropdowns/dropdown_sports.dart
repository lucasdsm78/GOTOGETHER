import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/storage.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/usecase/sport.dart';

class DropdownSports extends StatefulWidget {
  const DropdownSports({Key? key, this.sport, required this.onChange, this.shouldAddNullValue = false,}) : super(key: key);
  final Sport? sport;
  final Function onChange;
  final bool shouldAddNullValue;

  @override
  _DropdownSportsState createState() => _DropdownSportsState();
}

class _DropdownSportsState extends State<DropdownSports> {
  List<Sport?> sportList = [];
  final SportUseCase sportUseCase = SportUseCase();
  late Sport? sport = widget.sport ;
  final store = CustomStorage();

  _initSport(newSportList){
    if(widget.shouldAddNullValue && !sportList.contains(null)) {
      newSportList.insert(0, null);
    }

    setState(() {
      sportList = newSportList as List<Sport>;
    });
  }

  @override
  void initState() {
    super.initState();
    store.getAndStoreSportsFuture(func: _initSport);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      DropdownButtonHideUnderline(
        DropdownButton<Sport?>(
          icon: Icon(Icons.sports_soccer),
          //isExpanded: true,
          value: sport,
          hint: Text("Sports"),
          iconEnabledColor: Colors.green,
          iconDisabledColor: Colors.red,
          isExpanded: true,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          onChanged: (newValue) {
            widget.onChange(newValue);
            setState(() {
              sport = newValue as Sport;
            });
          },
          items: sportList.map<DropdownMenuItem<Sport>>((Sport? value) {
            return DropdownMenuItem<Sport>(
              value: value,
              child: Text((value == null ? "Tous" : value.name.toString())),
            );
          }).toList(),
        ),
      );

  }
}
