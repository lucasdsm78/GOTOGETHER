import 'package:flutter/material.dart';

class RightButton extends StatelessWidget {
  RightButton({
  required this.textButton,
  required this.onPressed,
  required this.height,
  required this.width,
  this.isRight = true});

  final GestureTapCallback onPressed;
  final String textButton;
  final double width;
  final double height;
  final bool isRight;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: (isRight ? Colors.green : Colors.red),
      splashColor: (isRight ? Colors.greenAccent : Colors.redAccent),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: width,
              height: height,
            ),
            Text(textButton,
              maxLines: 1,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      onPressed: onPressed,
      shape: const StadiumBorder(),
    );
  }
}