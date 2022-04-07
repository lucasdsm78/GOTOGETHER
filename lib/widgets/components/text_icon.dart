import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  /// Create widget containing a [title] string as title,
  /// and [icon] at is right if exist
  const TextIcon({Key? key, required this.title, this.icon,
    this.mainAxisAlignment = MainAxisAlignment.center, this.iconFirst = true}) : super(key: key);
  final String title;
  final Icon? icon;
  final MainAxisAlignment mainAxisAlignment;
  final bool iconFirst;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add( Expanded(
        child: Text(title, overflow: TextOverflow.ellipsis,)
    ) );
    children.insert((iconFirst ? 0 : 1 ), icon!);

    return Row(
        mainAxisAlignment: mainAxisAlignment,
        children : children
    );
  }
}
