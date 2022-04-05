import 'package:flutter/material.dart';

class CustomRow extends StatelessWidget {
  const CustomRow({Key? key,  required this.children,
    this.mainAlignementAxis = MainAxisAlignment.center, this.crossAlignementAxis = CrossAxisAlignment.center}) : super(key: key);
  final List<Widget> children;
  final MainAxisAlignment mainAlignementAxis;
  final CrossAxisAlignment crossAlignementAxis;

  List<Widget> _buildWidgetList(){
    List<Widget> list = [];
    children.forEach((element) {

      list.add(Expanded(
          flex:1,
          child: Container(
              child: element,
              alignment: (
                  element == children.first
                  ? Alignment.centerLeft
                  : (element == children.last
                    ? Alignment.centerRight
                    : Alignment.center
                  )
              ),
          ),
      ));
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {

    return Row(
      children: _buildWidgetList(),
      mainAxisAlignment: mainAlignementAxis,
      crossAxisAlignment: crossAlignementAxis,
    );
  }
}
