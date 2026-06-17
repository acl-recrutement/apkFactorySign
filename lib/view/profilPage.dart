import 'package:flutter/material.dart';

class Profilpage extends StatefulWidget {
  const Profilpage({Key? key}) : super(key: key);

  @override
  _ProfilpageState createState() => _ProfilpageState();
}

class _ProfilpageState extends State<Profilpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil Page')),
      body: Center(child: Text('')),
    );
  }
}
