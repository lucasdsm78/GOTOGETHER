import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_together/helper/enum/custom_colors.dart';
import 'package:go_together/helper/storage.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/widgets/screens/friends/friends_list.dart';
import 'package:localstorage/localstorage.dart';
import 'package:go_together/widgets/screens/activities/activities_list.dart';
import 'package:go_together/widgets/screens/activities/activity_set.dart';

import 'package:go_together/widgets/screens/friends/add_friends_list.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
  CustomStorage store = CustomStorage();

  @override
  void initState() {
    super.initState();
    user = Mock.userGwen;
  }
  getUser() async {
    user = User.fromJson(jsonDecode(await store.getUser())) ;
  }

  static List<Map<String, dynamic>> drawerLinks = [
    // {"widget": ActivityList(), "title": "Liste des événements"},
    {
      "widget": FriendsList(),
      "title": "Mes amis",
      "icon": Icon(Icons.favorite)
    },
    {
      "widget": AddFriendsList(),
      "title": "Ajouté des amis",
      "icon": Icon(Icons.favorite)
    },
  ];
  static List<Map<String, dynamic>> bottomBarLinks = [
    {
      "widget": ActivityList(),
      "title": "Liste des Activités",
      "icon": Icon(Icons.list)
    },
    {
      //"widget": ActivityCreate(idActivity: 42,),
      "widget": ActivitySet(),
      "title": "Crée une activité",
      "icon": Icon(Icons.play_lesson)
    },
    /*{
      "widget": MapScreen(),
      "title": "Map",
      "icon": Icon(Icons.map_outlined)
    },*/
    {
      "widget": FriendsList(),
      "title": "Friends",
      "icon": Icon(MdiIcons.handshake)
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
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            //should be some user data, ex: profile picture and name
            /*DrawerHeader(
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
            ),*/
            Container(),
            ...getDrawerLinks(context)
          ] ,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: getBottomBarLinks(),
        currentIndex: _selectedIndex,
        selectedItemColor: CustomColors.goTogetherMain,
        onTap: _onItemTapped,
      ),
    );
  }
}
