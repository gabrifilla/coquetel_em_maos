import 'package:flutter/material.dart';
import 'package:coquetel_em_maos/helpers/drawer_navigation.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Coquetel em Mãos"),
      ),
      drawer: DrawerNavigation(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("./assets/images/background/coquetelbg.jpg"),
            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
          ),
        ),
      ),
    );
  }
}
