import 'package:flutter/material.dart';
import 'package:go_together/widgets/components/lists/custom_list.dart';

class TabsElement extends StatefulWidget {
  const TabsElement({Key? key, required this.children, required this.colID}) : super(key: key);
  final List<Widget> children;
  final int colID;

  @override
  _TabsElementState createState() => _TabsElementState();
}

class _TabsElementState extends State<TabsElement> {

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (var i = 0; i < widget.children.length; i++) {
      if(i==widget.colID) {
        children.add(
          Flexible(
            child: widget.children[i]
          ),
        );
      }
    }

    return Expanded(
        flex: 1,
        child:Column(
        children: children
    )
    );
    //return Container(color:Colors.green);
  }
}



