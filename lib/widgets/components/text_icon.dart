import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  /// Create widget containing a [title] string as title,
  /// and [icon] at is right if exist
  const TextIcon({Key? key, required this.title, this.icon}) : super(key: key);
  final String title;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children : [
          Text(title),
          icon!
        ]
    );
  }
}
