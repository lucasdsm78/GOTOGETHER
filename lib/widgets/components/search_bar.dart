import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_together/helper/enum/custom_colors.dart';
import 'package:go_together/widgets/components/lists/custom_row.dart';

class TopSearchBar extends StatefulWidget implements PreferredSizeWidget {
  const TopSearchBar({Key? key, required this.customSearchBar, this.placeholder, required this.searchbarController, this.leading}) : super(key: key);
  final Widget customSearchBar;
  final TextEditingController searchbarController;
  final Widget? leading;
  final String? placeholder;

  @override
  _TopSearchBarState createState() => _TopSearchBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize =>  const Size.fromHeight(50.0);
}

class _TopSearchBarState extends State<TopSearchBar> {
  Widget customSearchBar = const Text('');
  Icon customIcon = const Icon(Icons.search, color: Colors.white,);

  @override
  void initState() {
    super.initState();
    customSearchBar = widget.customSearchBar;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: customSearchBar,
      /*theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),*/
      backgroundColor: CustomColors.goTogetherMain,
      leading: widget.leading,
      /*flexibleSpace: Container(
        child: const CustomRow(
            children: [
              Icon(Icons.arrow_back_ios),
              Image(image: AssetImage('assets/gotogether-textOnly.png')),
              Icon(Icons.account_circle)
            ]
        ) ,
        color: Colors.green,
        alignment: Alignment.center,
      ),*/

      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              if (customIcon.icon == Icons.search) {
                customIcon = const Icon(Icons.cancel, color: Colors.white,);
                customSearchBar = SearchBar( searchbarController: widget.searchbarController, placeholder: widget.placeholder,);
              } else {
                customIcon = const Icon(Icons.search, color: Colors.white,);
                customSearchBar = widget.customSearchBar;
              }
            });
          },
          icon: customIcon,
        ),
        IconButton(
          onPressed: (){
          },
          icon: Icon(Icons.account_circle, color: Colors.white,),
        ),
      ],
    );
  }
}


class SearchBar extends StatelessWidget {
  const SearchBar({Key? key, this.placeholder, required this.searchbarController}) : super(key: key);
  final String? placeholder;
  final TextEditingController searchbarController;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.search,
        color: Colors.white,
        size: 28,
      ),
      title: TextField(
        autofocus: true,
        controller: searchbarController,
        decoration: InputDecoration(
          hintText: (placeholder ?? 'description, city, adresse...'),
          hintStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
