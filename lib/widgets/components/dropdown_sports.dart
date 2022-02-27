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
    String? storedSport = storage.getItem("sports");
    if(storedSport != null){
      setState(() {
        futureSports = parseSports(storedSport);
        sport = futureSports[0];
      });
    }
    else {
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
