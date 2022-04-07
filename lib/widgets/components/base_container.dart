import 'package:flutter/material.dart';

class BaseContainer extends StatelessWidget {
  BaseContainer({required this.child, this.useBorder = true , this.margin = const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0)});

  final Widget child;
  final bool useBorder;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return
      Container(
        child: child,
        width: 200,
        margin: margin,
        padding: const EdgeInsets.only(left: 5, right: 5),
        decoration: (useBorder
            ?  BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blueGrey,
                width: 1,
                style: BorderStyle.solid
              )
            )
            : BoxDecoration()
        ),
      );
  }
}
