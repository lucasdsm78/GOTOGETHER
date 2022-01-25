import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildListView(data, Function _buildRow) {
  return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: data.length * 2,
      itemBuilder: (context, i) {
        if (i.isOdd) return const Divider();
        final index = i ~/ 2;
        return _buildRow(data[index]);
      });
}

class ListViewSeparated extends StatelessWidget {
  /// Creates a ListView with each elements separated by Divider().
  /// [data] is a List of Object.
  /// [buildListItem] is a Function using one o this object to render a Widget.
  /// [axis] is the listView axis (vertical by default)
  const ListViewSeparated({Key? key, required this.data, required this.buildListItem, this.axis:Axis.vertical}) : super(key: key);
  final dynamic data;
  final Function buildListItem;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: data.length * 2,
        scrollDirection: axis,
        controller: ScrollController(),
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();
          final index = i ~/ 2;
          return buildListItem(data[index]);
        });
  }
}
