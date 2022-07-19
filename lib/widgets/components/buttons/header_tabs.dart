import 'package:flutter/material.dart';
import 'package:go_together/widgets/components/buttons/top_button.dart';
import 'package:go_together/widgets/components/lists/custom_row.dart';

import '../text_icon.dart';

/// this is button used on top of a list, like using browser tabs.
class HeaderTabs extends StatefulWidget {
  const HeaderTabs({Key? key, required this.tabsWidget, required this.onPress, this.hasFocus = true}) : super(key: key);
  final List<Widget> tabsWidget;
  final Function onPress;
  final bool hasFocus;

  @override
  _HeaderTabsState createState() => _HeaderTabsState();
}

class _HeaderTabsState extends State<HeaderTabs> {
  int colID = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _setColID(int newId){
    setState(() {
      colID = newId;
    });
    widget.onPress(colID);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> allTabs = [];
    for (var i = 0; i < widget.tabsWidget.length; i++) {
      allTabs.add(TopButton(
        child: widget.tabsWidget[i],
        onPress: (){_setColID(i);},
        hasFocus: colID==i,
      ));
    }

    return CustomRow(
        children: allTabs
    );
  }
}



