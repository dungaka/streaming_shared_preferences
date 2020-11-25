import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String value = 'default';
  @override
  void initState() {
    super.initState();
    StreamingSharedPreferences sp = StreamingSharedPreferences();
    sp.setPrefsName('test');
    sp.addObserver('temp', (value) {
      print('UPDATEEEEEE');
      setState(() {
        this.value = value;
      });
    });

    sp.run();

    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      sp.setValue('temp', Random().nextInt(100).toString());
      print('SETTTTTTTTTT');

      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('$value'),
        ),
      ),
    );
  }
}
