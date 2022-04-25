import 'package:flutter/material.dart';

class LogData extends StatefulWidget {
  const LogData({Key? key}) : super(key: key);
  @override
  _LogDataState createState() => _LogDataState();
}

class _LogDataState extends State<LogData> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Log Data"),
          TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..removeCurrentMaterialBanner()
                  ..showMaterialBanner(_showMaterialBanner(context));
              },
              child: Text("Material Button"))
        ],
      )),
    ));
  }

  MaterialBanner _showMaterialBanner(BuildContext context) {
    return MaterialBanner(
        content: Text('Hello, I am a Material Banner'),
        leading: Icon(Icons.error),
        padding: EdgeInsets.all(15),
        backgroundColor: Colors.lightGreenAccent,
        contentTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Agree',
              style: TextStyle(color: Colors.purple),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ]);
  }
}
