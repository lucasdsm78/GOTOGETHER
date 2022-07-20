import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  const CustomInput({Key? key, required this.title,
    required this.notValidError, required this.controller,
    this.type = TextInputType.text,
    this.textColor = Colors.blueAccent,
  this.isPassword = false,
  this.border,
  this.margin,
  }) : super(key: key);
  final String title;
  final String notValidError;
  final TextEditingController controller;
  final TextInputType type;
  final Color textColor;
  final bool isPassword;
  final InputBorder? border;
  final EdgeInsetsGeometry? margin;

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
    Container(
      margin: ( widget.margin == null
          ?  const EdgeInsets.only(left: 15.0, right: 20.0, top: 15.0)
          : widget.margin!
      ),
      child: TextFormField(
        obscureText: widget.isPassword,
        cursorColor: widget.textColor,
        style: TextStyle(
          color: widget.textColor,
          decorationColor: widget.textColor
        ),
        decoration: InputDecoration(
          fillColor: widget.textColor,
          border: (widget.border == null
            ? OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(50)
            )
            : widget.border!
          ),
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
      ),
    );

  }
}
