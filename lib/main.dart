import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_line_charts_sample/Provider/check_connectivity.dart';
import 'package:live_line_charts_sample/Provider/live_data_provider.dart';
import 'package:live_line_charts_sample/test.dart';
import 'package:live_line_charts_sample/trends_page.dart';
import 'package:provider/provider.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .whenComplete(() {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LiveDataProvider>(
            create: (_) => LiveDataProvider()),
        ChangeNotifierProvider<CheckConnectivity>(
            create: (_) => CheckConnectivity())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Live Charts Sample',
        // theme:
        //     ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
        theme: ThemeData(
          brightness: Brightness.light,
          textTheme: GoogleFonts.latoTextTheme(TextTheme()
              //   Theme.of(context).textTheme,
              // If this is not set, then ThemeData.light().textTheme is used.
              ),
        ),
        home: Test(),
      ),
    );
  }
}
