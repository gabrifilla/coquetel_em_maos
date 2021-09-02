import 'package:flutter/material.dart';
import 'package:coquetel_em_maos/views/categories_screen.dart';
import 'package:coquetel_em_maos/views/home_screen.dart';

class DrawerNavigation extends StatefulWidget {
  const DrawerNavigation({Key key}) : super(key: key);

  @override
  _DrawerNavigationState createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends State<DrawerNavigation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage('Profile Image'),
                ),
                accountName: Text("Gabriel Filla Camargo"),
                accountEmail: Text("gabrifillac@gmail.com"),
                decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: Icon(Icons.view_list),
              title: Text("Home"),
              onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomeScreen())),
            ),
            ListTile(
              leading: Icon(Icons.view_list),
              title: Text("Category"),
              onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Categories())),
            )
          ],
        ),
      )
    );
  }
}
