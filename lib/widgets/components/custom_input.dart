import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  const CustomInput({Key? key, required this.title,
    required this.notValidError, required this.controller,
    this.type = TextInputType.text,
    this.textColor = Colors.blueAccent,
    this.isPassword = false, this.border, this.margin,
    this.validator, this.textStyle
  }) : super(key: key);
  final String title;
  final String notValidError;
  final TextEditingController controller;
  final TextInputType type;
  final Color textColor;
  final bool isPassword;
  final InputBorder? border;
  final EdgeInsetsGeometry? margin;
  final Function? validator;
  final TextStyle? textStyle;

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

  String? defaultValidator(String? value) {
    if(widget.validator != null){
      return widget.validator!(value);
    }
    if (value == null || value.isEmpty) {
      return widget.notValidError;
    }
    return null;
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
        style: (widget.textStyle == null
            ? TextStyle(
              color: widget.textColor,
              decorationColor: widget.textColor
            )
            : widget.textStyle
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
        validator: defaultValidator,
        controller: widget.controller,
      ),
    );

  }
}
