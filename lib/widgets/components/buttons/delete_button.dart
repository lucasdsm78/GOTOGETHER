import 'package:flutter/material.dart';

/// This button is used when wanted to delete an item.
class DeleteButton extends StatelessWidget {
  const DeleteButton({Key? key, this.onPressed, required this.display}) : super(key: key);
  final Function? onPressed;
  final bool display;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [display
            ? ElevatedButton(
          onPressed:() {
            onPressed!();
          }
          ,
          child: Icon(Icons.delete_forever, color: Colors.red,),
          style: ElevatedButton.styleFrom(primary: Colors.white),
        )
            : Container(width: 0,)
        ]
    );
  }
}
