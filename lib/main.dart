import 'package:flutter/material.dart';
import 'package:flutter_camera/camera/CameraScreen.dart';
import 'package:flutter_camera/ui/document.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CameraScreen(self: false)
    );
  }
}
