import 'package:flutter/material.dart';
import 'package:go_together/helper/enum/privacy.dart';
import 'custom_row.dart';

class RadioPrivacy extends StatefulWidget {
  const RadioPrivacy({Key? key, this.isRow=true, required this.onChange, required this.groupValue}) : super(key: key);
  final bool isRow;
  final Function onChange;
  final dynamic groupValue;

  @override
  _RadioPrivacyState createState() => _RadioPrivacyState();
}

class _RadioPrivacyState extends State<RadioPrivacy> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _buildRadio(String label, Object value, dynamic groupValue){
    return ListTile(
      title: Text(label),
      leading: Radio(
        value: value,
        groupValue: groupValue,
        onChanged: (value) {
          widget.onChange(value);
        },
        activeColor: Colors.green,
      ),
      onTap: (){
        widget.onChange(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [
      _buildRadio(Privacy.public.translate(), Privacy.public.isPublic(), widget.groupValue),
      _buildRadio(Privacy.private.translate(), Privacy.private.isPublic(), widget.groupValue),
    ];
    return
      CustomRow(
          children: list
      );
  }
}
