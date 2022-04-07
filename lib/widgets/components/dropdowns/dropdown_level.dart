import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/mock/levels.dart';
import 'package:go_together/models/level.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DropdownLevel extends StatefulWidget {
  const DropdownLevel({Key? key, this.level, required this.onChange, this.shouldAddNullValue = false}) : super(key: key);
  final Level? level;
  final Function onChange;
  final bool shouldAddNullValue;

  @override
  _DropdownLevelState createState() => _DropdownLevelState();
}

class _DropdownLevelState extends State<DropdownLevel> {
  List<Level?> levelList = MockLevel.levelList;
  late Level? level = widget.level ;

  @override
  void initState() {
    super.initState();
    if(widget.shouldAddNullValue && !levelList.contains(null)) {
      levelList.insert(0, null);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Level? theLevel = null;
    for(int i=0; i<levelList.length; i++){
      if(level != null && levelList[i] != null && levelList[i]!.id == level!.id){
        theLevel = levelList[i];
        break;
      }
    }
    return
      DropdownButtonHideUnderline(
        child:DropdownButton<Level?>(
        value: theLevel,
        icon : Icon(MdiIcons.podium),
        hint: Text("niveau"),
        iconEnabledColor: Colors.green,
        iconDisabledColor: Colors.red,
        isExpanded: true,
        elevation: 16,
        style: const TextStyle(color: Colors.deepPurple),
        onChanged: (newValue) {
          widget.onChange(newValue);
          setState(() {
            level = newValue as Level;
          });
        },
        items: levelList.map<DropdownMenuItem<Level>>((Level? value) {
          return DropdownMenuItem<Level>(
            value: value,
            child: Text((value == null ? "Tous" : value.name.toString())),
          );
        }).toList(),
        )
      );
  }
}
