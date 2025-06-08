import 'package:flutter/material.dart';
import 'package:mentally/page/welcome.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mentally',
      home: WelcomePage(),
    );
  }
}
