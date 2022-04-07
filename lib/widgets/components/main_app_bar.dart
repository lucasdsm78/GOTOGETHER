
import 'package:flutter/material.dart';
import 'package:go_together/helper/enum/custom_colors.dart';

class MainAppBar extends StatefulWidget {
  const MainAppBar({Key? key, this.title = "", this.bgColor}) : super(key: key);
  final String title;
  final Color? bgColor;

  @override
  _MainAppBarState createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  @override
  AppBar build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      backgroundColor: (widget.bgColor ?? CustomColors.goTogetherMain),
    );
  }
}
