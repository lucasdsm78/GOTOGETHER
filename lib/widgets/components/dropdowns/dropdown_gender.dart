import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/enum/gender.dart';

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
    String? theGender = null;
    for(int i=0; i<genderList.length; i++){
      if(widget.criterGender != null && genderList[i] != null && genderList[i] == widget.criterGender!){
        theGender = genderList[i];
        break;
      }
    }
    return
      DropdownButtonHideUnderline(
        child: DropdownButton<String>(
        value: theGender,
        hint: Text("Réservé à"),
        icon : Icon(Icons.transgender),
        iconEnabledColor: Colors.green,
        iconDisabledColor: Colors.red,
        isExpanded: true,
        elevation: 16,
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
      )
    );
  }
}
