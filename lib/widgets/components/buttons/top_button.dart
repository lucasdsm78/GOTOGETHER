import 'package:flutter/material.dart';

/// this is button used on top of a list, like using browser tabs.
class TopButton extends StatefulWidget {
  const TopButton({Key? key, required this.child, required this.onPress, this.hasFocus = true}) : super(key: key);
  final Widget child;
  final Function onPress;
  final bool hasFocus;

  @override
  _TopButtonState createState() => _TopButtonState();
}

class _TopButtonState extends State<TopButton> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color _getColor(){
    if(widget.hasFocus){
     return Colors.blue;
    }
    else{
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: (){widget.onPress();},
        style: ElevatedButton.styleFrom(textStyle: TextStyle(color: _getColor()), primary: _getColor(),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(0.0),
              ),
            )
        ),
        child: widget.child
    );
  }
}



