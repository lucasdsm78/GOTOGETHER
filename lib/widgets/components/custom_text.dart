import 'package:flutter/material.dart';

class CustomText extends Text {

  CustomText(String text, {color=Colors.black, textAlign=TextAlign.left, factor=1.0}) :super (
      text,
      textAlign:textAlign,
      textScaleFactor:factor,
      style: TextStyle(color: color)
  );

}