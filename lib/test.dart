import 'package:flutter/material.dart';
import 'package:live_line_charts_sample/Provider/check_connectivity.dart';
import 'package:live_line_charts_sample/Provider/live_data_provider.dart';
import 'package:live_line_charts_sample/trends_page.dart';
import 'package:provider/provider.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  void initState() {
    initConnectvity();
    // TODO: implement initState
    super.initState();
  }

  initConnectvity() async {
    await Provider.of<CheckConnectivity>(context, listen: false)
        .initConnectivity(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => TrendsPage())));
                },
                icon: Icon(Icons.abc)),
          ],
        ),
        body:
            //  Consumer<CheckConnectivity>(
            //   builder: ((context, connection, child) {
            //     return Center(child: Text(connection.connectionStatus.toString()));
            Container(
                child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: GridView.builder(
              itemCount: 2,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Column(children: [
                    Expanded(
                        child: Container(
                      color: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          width: double.infinity,
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: <Widget>[
                                    new Icon(
                                      Icons.email,
                                      color: Colors.white,
                                    ),
                                    new Positioned(
                                      left: 10,
                                      // bottom: 15,
                                      child: new Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: new BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        constraints: BoxConstraints(
                                          minWidth: 15,
                                          minHeight: 15,
                                        ),
                                        child: new Text(
                                          '1',
                                          style: new TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                // Icon(
                                //   Icons.email,
                                //   color: Colors.white,
                                // ),
                                Text(
                                  "PATIENTS",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ]),
                        ),
                      ),
                    )),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "MESSAGES",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    )
                  ]),
                );
              }),
        )));
  }
}
