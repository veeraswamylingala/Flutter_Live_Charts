import 'package:flutter/material.dart';
import 'package:live_line_charts_sample/data_table.dart';
import 'package:live_line_charts_sample/live_charts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Charts Sample',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: LiveChart(),
    );
  }
}
