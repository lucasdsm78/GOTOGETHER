import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DropdownGender extends StatefulWidget {
  const DropdownGender({Key? key, this.criterGender, required this.onChange, this.shouldAddNullValue = true}) : super(key: key);
  final String? criterGender;
  final Function onChange;
  final bool shouldAddNullValue;

  @override
  _DropdownGenderState createState() => _DropdownGenderState();
}

class _DropdownGenderState extends State<DropdownGender> {
  List<String?> genderList = getAllGenderTranslate();
  @override
  void initState() {
    super.initState();
    if(widget.shouldAddNullValue && !genderList.contains(null)) {
      genderList.insert(0, null);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
        value: widget.criterGender,
        elevation: 16,
        hint: Text("Réservé à"),
        icon : Icon(Icons.transgender),
        style: const TextStyle(color: Colors.deepPurple),
        onChanged: (String? newValue) {
          widget.onChange(newValue);
        },
        items: genderList.map<DropdownMenuItem<String>>((String? value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text((value == null ? "Tous" : value.toString())),
          );
        }).toList(),
    );
  }
}
