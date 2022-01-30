import 'package:flutter/material.dart';
import 'package:go_together/models/sports.dart';

import 'custom_datepicker.dart';
import 'custom_text.dart';
import 'package:go_together/helper/date_extension.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({Key? key, required this.selectedDate, required this.onSelectDate,
    required this.sport, required this.sportList, required this.onChangeSport}) : super(key: key);
  final DateTime? selectedDate;
  final Function onSelectDate;

  final Sport sport;
  final List<Sport> sportList;
  final Function onChangeSport;

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  DateTime? selectedDate = DateTime.now();

  late Sport sport;
  List<Sport> sportList = [];

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    sport = widget.sport;
    sportList = widget.sportList;
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width * 0.6;
    double height = MediaQuery.of(context).size.height * 0.6;

    return SimpleDialog(
      title: CustomText("Filters", textAlign: TextAlign.center,),
      contentPadding: EdgeInsets.all(5.0),
      children: [
        Container(
            height: height,
            width: width,
            child:
            Column(
              children:[
                Expanded(
                  flex: 1,
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomDatePicker(
                        initialDate: selectedDate,
                        onSelected: (DateTime date){
                          widget.onSelectDate(date);
                          _updateSelectedDate(date);
                        }
                      ),
                      Container(width: 10,),
                      Expanded(
                        flex: 1,
                        child: Text(selectedDate == null ? "any date selected" : selectedDate!.getFrenchDateTime())
                      )
                    ],
                  )
                ),

                Expanded(
                  flex: 1,
                  child:DropdownButton<Sport>(
                    value: sport,
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    onChanged: (newValue) {
                      _updateSelectedSport(newValue as Sport);
                      widget.onChangeSport(newValue);
                    },
                    items: sportList.map<DropdownMenuItem<Sport>>((Sport value) {
                      return DropdownMenuItem<Sport>(
                        value: value,
                        child: Text(value.name.toString()),
                      );
                    }).toList(),
                  ),
                )
              ],
            )

        )
      ],
    );
  }
  _updateSelectedDate(DateTime date){
    setState(() {
      selectedDate = date;
    });
  }
  _updateSelectedSport(Sport newSport){
    setState(() {
      sport = newSport;
    });
  }
}
