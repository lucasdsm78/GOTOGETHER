import 'package:flutter/material.dart';
import 'package:go_together/widgets/components/text_icon.dart';

class ColumnList extends StatelessWidget {
  /// Create a column widget containing a title at top
  /// ([title] string + [icon]) and a [widget].
  ///
  /// In first instance [widget] is imagined as a listView, but could be another one.
  const ColumnList({Key? key, required this.title, this.icon, required this.child}) : super(key: key);
  final String title;
  final Icon? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex:1,
        child:Column(
          children: [
            TextIcon(title: title, icon: icon,),
            Expanded(flex:1, child:child),
          ],
        )
    );
  }
}
