import 'package:flutter/material.dart';
import 'package:no_rest_api/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Rick and Morty Characters'),
          ),
          body: HomeScreen()),
    );
  }
}
