import 'package:flutter/material.dart';

class CustomRadio extends StatefulWidget {
  const CustomRadio({Key? key, this.isRow=true, required this.onChange, required this.groupValue, required this.choices, required this.title}) : super(key: key);
  final bool isRow;
  final Function onChange;
  final dynamic groupValue;
  final List<dynamic> choices;
  final String title;

  @override
  _CustomRadioState createState() => _CustomRadioState();
}

class _CustomRadioState extends State<CustomRadio> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _buildRadio(String label, Object value, dynamic groupValue){
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: groupValue,
          onChanged: (value) {
            widget.onChange(value);
          },
        ),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [
    ];
    for (int i=0; i< widget.choices.length; i++){
      list.add(_buildRadio(widget.choices[i], (i), widget.groupValue));
    }

    return
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title),
          Expanded(child:
            Column(
              children: list,
            )
          )
        ]
      );
  }
}
