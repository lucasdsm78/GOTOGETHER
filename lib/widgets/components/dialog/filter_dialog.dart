import 'package:flutter/material.dart';
import 'package:go_together/models/level.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/widgets/components/dropdowns/dropdown_gender.dart';
import 'package:go_together/widgets/components/dropdowns/dropdown_level.dart';

import '../custom_datepicker.dart';
import '../custom_text.dart';
import 'package:go_together/helper/extensions/date_extension.dart';

import '../dropdowns/dropdown_sports.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({Key? key, required this.selectedDate, required this.onSelectDate, 
    this.sport, required this.onChangeSport, this.gender, required this.onChangeGender,
    this.level, required this.onChangeLevel}) : super(key: key);
  final DateTime? selectedDate;
  final Function onSelectDate;

  final Sport? sport;
  final String? gender ;
  final Level? level;

  final Function onChangeSport;
  final Function onChangeGender;
  final Function onChangeLevel;

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  DateTime? selectedDate = DateTime.now();
  late Sport? sport = widget.sport;
  late String? gender = widget.gender;
  late Level? level = widget.level;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
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
                Container(
                  height: 30,
                    child: Row(
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
                DropdownSports(sport: sport, onChange: _updateSelectedSport, shouldAddNullValue: true,),
                DropdownLevel(level: level, onChange: _updateSelectedLevel, shouldAddNullValue: true,),
                DropdownGender(criterGender: gender, onChange: _updateSelectedGender),
              ],
            )

        )
      ],
    );
  }

  //region update data
  _updateSelectedDate(DateTime date){
    setState(() {
      selectedDate = date;
    });
  }
  _updateSelectedSport(Sport newSport){
    setState(() {
      sport = newSport;
    });
    widget.onChangeSport(newSport);
  }
  _updateSelectedLevel(Level newLevel){
    setState(() {
      level = newLevel;
    });
    widget.onChangeLevel(newLevel);
  }
  _updateSelectedGender(String? newGender){
    setState(() {
      gender = newGender;
    });
    widget.onChangeGender(newGender);
  }
  //endregion
}
