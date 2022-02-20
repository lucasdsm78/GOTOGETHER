import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/widgets/google_maps.dart';
import 'package:localstorage/localstorage.dart';
import 'package:go_together/widgets/activities_list.dart';
import 'package:go_together/widgets/activity_create.dart';

class Navigation extends StatefulWidget {
  static const tag = "navigation";
  @override
  State<StatefulWidget> createState() => NavigationState();
}

class NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  int _drawerSelectedIndex = 0;
  bool _isLastTappedDrawer = false;
  late User user;
  LocalStorage storage = LocalStorage('go_together_app');

  @override
  void initState() {
    super.initState();
    user = User.fromJson(jsonDecode(storage.getItem("user")));
  }

  static List<Map<String, dynamic>> drawerLinks = [
    // {"widget": ActivityList(), "title": "Liste des événements"},
  ];
  static List<Map<String, dynamic>> bottomBarLinks = [
    {
      "widget": ActivityList(),
      "title": "Liste des Activités",
      "icon": Icon(Icons.list)
    },
    {
      "widget": ActivityCreate(),
      "title": "Crée une activité",
      "icon": Icon(Icons.play_lesson)
    },
    {
      "widget": MapScreen(),
      "title": "Map",
      "icon": Icon(Icons.map_outlined)
    },
  ];

  Widget getBody() {
    if(_isLastTappedDrawer && drawerLinks.isNotEmpty){
      return drawerLinks[_drawerSelectedIndex]["widget"];
    }
    else{
      return bottomBarLinks[_selectedIndex]["widget"];
    }
  }

  List<Widget> getDrawerLinks(BuildContext context){
    List<Widget> links = [];
    for(int i=0; i<drawerLinks.length; i++) {
      links.add(_buildDrawerLinks(drawerLinks[i]["title"], ()=> _onDrawerTap(i, context)));
    }
    return links;
  }
  List<BottomNavigationBarItem> getBottomBarLinks(){
    List<BottomNavigationBarItem> links = [];
    for(int i=0; i<bottomBarLinks.length; i++) {
      links.add(_buildBottomBarButton(i));
    }
    return links;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isLastTappedDrawer = false;
    });
  }

  void _onDrawerTap(int index, BuildContext context){
    setState(() {
      _drawerSelectedIndex = index;
      _isLastTappedDrawer = true;
    });
    Navigator.pop(context);
  }

  _buildDrawerLinks(String title, Function onTap){
    return ListTile(
      title: Text(title),
      onTap: ()=>onTap(),
    );
  }
  BottomNavigationBarItem _buildBottomBarButton(int index){
    return BottomNavigationBarItem(
      icon: bottomBarLinks[index]["icon"],
      label: bottomBarLinks[index]["title"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      /*drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        user.profilePicture!)),
                color: Colors.blue,
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  user.userName,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0
                  ),
                ),
              ),
            ),
            ...getDrawerLinks(context)
          ] ,
        ),
      ),*/
      bottomNavigationBar: BottomNavigationBar(
        items: getBottomBarLinks(),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}
