import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DropdownGender extends StatefulWidget {
  const DropdownGender({Key? key, required this.criterGender, required this.onChange}) : super(key: key);
  final String criterGender;
  final Function onChange;

  @override
  _DropdownGenderState createState() => _DropdownGenderState();
}

class _DropdownGenderState extends State<DropdownGender> {
  @override
  void initState() {
    super.initState();
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
        style: const TextStyle(color: Colors.deepPurple),
        onChanged: (String? newValue) {
          widget.onChange(newValue);
        },
        items: <String>['Tous', 'Hommes', 'Femmes']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList()
    );
  }
}
