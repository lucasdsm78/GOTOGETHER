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
      children.add(
        Flexible(
          child : Container(height: widget.colID == i ? MediaQuery.of(context).size.height : 0 ,
            child:  Visibility(
              child: widget.children[i],
              visible: widget.colID == i,
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        children: children
      )
    );
  }
}



