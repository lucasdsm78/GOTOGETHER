import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  const CustomInput({Key? key, required this.title,
    required this.notValidError, required this.controller,
    this.type=TextInputType.text }) : super(key: key);
  final String title;
  final String notValidError;
  final TextEditingController controller;
  final TextInputType type;

  @override
  _CustomInputState createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {

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
    return
      TextFormField(
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: widget.title,
        ),
        keyboardType: widget.type,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return widget.notValidError;
          }
          return null;
        },
        controller: widget.controller,
      );
  }
}
