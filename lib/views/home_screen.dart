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
        title: Text("Tela Inicial Coqueteis"),
      ),
      drawer: DrawerNavigation(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("./assets/images/coquetel.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
