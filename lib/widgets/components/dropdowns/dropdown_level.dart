import 'package:flutter/material.dart';
import 'package:go_together/mock/levels.dart';
import 'package:go_together/models/level.dart';

class DropdownLevel extends StatefulWidget {
  const DropdownLevel({Key? key, required this.level, required this.onChange}) : super(key: key);
  final Level level;
  final Function onChange;

  @override
  _DropdownLevelState createState() => _DropdownLevelState();
}

class _DropdownLevelState extends State<DropdownLevel> {
  List<Level> levelList = MockLevel.levelList;
  late Level level = widget.level ;

  @override
  void initState() {
    super.initState();
    level = levelList[0];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      DropdownButton<Level>(
        value: level,
        elevation: 16,
        style: const TextStyle(color: Colors.deepPurple),
        onChanged: (newValue) {
          widget.onChange(newValue);
          setState(() {
            level = newValue as Level;
          });
        },
        items: levelList.map<DropdownMenuItem<Level>>((Level value) {
          return DropdownMenuItem<Level>(
            value: value,
            child: Text(value.name.toString()),
          );
        }).toList(),
      );
  }
}
