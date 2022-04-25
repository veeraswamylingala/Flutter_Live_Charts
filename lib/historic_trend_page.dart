import 'package:date_field/date_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:live_line_charts_sample/Provider/live_data_provider.dart';
import 'package:provider/provider.dart';
import 'utils.dart';

// http://183.82.4.93:5887/ECScadaTrends/api/HistoricTrendsData?PointName=DTms_0013&FromDate=2021-03-25T12:02:34&ToDate=2021-03-25T15:53:03

class HistoricTrend extends StatefulWidget {
  const HistoricTrend({Key? key}) : super(key: key);

  @override
  _HistoricTrendState createState() => _HistoricTrendState();
}

class _HistoricTrendState extends State<HistoricTrend> {
  DateTime? startDateTime;
  DateTime? endDateTime;
  String selectedHistoricGroup = "";

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SingleChildScrollView(
        child: Consumer<LiveDataProvider>(builder: (context, livechart, child) {
      if (livechart.groupsData.isEmpty) {
        return Container(
            height: MediaQuery.of(context).size.width,
            child: Center(child: CircularProgressIndicator()));
      } else {
        return Form(
          key: _key,
          child: Container(
              padding: const EdgeInsets.all(5),
              //  color: Colors.white,
              child: Column(children: [
                //Selecet Group--------------------------------------
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: DropdownButton(
                    isExpanded: true,
                    // Initial Value
                    value: selectedHistoricGroup.isEmpty
                        ? livechart.listOfGroups[0]
                        : selectedHistoricGroup,
                    // Down Arrow Icon
                    icon: const Icon(Icons.keyboard_arrow_down),
                    // Array list of items
                    items: livechart.listOfGroups.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (newValue) {
                      setState(() {
                        selectedHistoricGroup = newValue.toString();
                      });
                    },
                  ),
                ),
                //     Row(
                //  children: [
                // Expanded(
                //   flex: 1,
                //   child: Container(
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(0.0),
                //         border: Border.all(
                //             color: Colors.grey,
                //             style: BorderStyle.solid,
                //             width: 0.80),
                //       ),
                //       alignment: Alignment.bottomRight,
                //       child: DropdownButton<String>(
                //           hint: Text(
                //               "Select Historic Group:${historicTrends.currentHistoricGroup ?? ""}"),
                //           elevation: 5,
                //           items: trendsData.groupNames.map((e) {
                //             return DropdownMenuItem(
                //               value: e.toString(),
                //               child: new Text(e),
                //             );
                //           }).toList(),
                //           onChanged: (val) {
                //             print("Selected Value ${val}");
                //             historicTrends.currentHistoricGroup = val;
                //             setState(() {
                //               selectedHistoricGroup = val;
                //             });
                //           })),
                // ),
                //   ],
                // ),

                const SizedBox(
                  height: 10,
                ),

                //Start DateTime-----
                DateTimeFormField(
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(color: Colors.black45),
                    errorStyle: TextStyle(color: Colors.redAccent),
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.event_note),
                    labelText: 'Start Date/Time',
                  ),
                  mode: DateTimeFieldPickerMode.dateAndTime,
                  //   autovalidateMode: AutovalidateMode.always,
                  validator: (e) {
                    if (startDateTime == null) {
                      return "Must Select Start DateTime";
                    } else if ("${e?.year}${e?.month}${e?.day}" ==
                        "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}") {
                      return "Please not the Current Date";
                    } else if (e?.isAfter(DateTime.now()) == true) {
                      return "Date must be is before current Date";
                    } else {
                      return null;
                    }
                  },
                  onDateSelected: (DateTime value) {
                    var formattedDate =
                        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(value);
                    setState(() {
                      startDateTime = value;
                    });
                    print("Start Date Time ${startDateTime}");
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                DateTimeFormField(
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(color: Colors.black45),
                    errorStyle: TextStyle(color: Colors.redAccent),
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.event_note),
                    labelText: 'End Date/Time ',
                  ),
                  mode: DateTimeFieldPickerMode.dateAndTime,
                  //autovalidateMode: AutovalidateMode.always,
                  validator: (e) {
                    if (endDateTime == null) {
                      return "Must Select End DateTime";
                    } else if ("${e?.year}${e?.month}${e?.day}" ==
                        "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}") {
                      return "Please not the Current Date";
                    } else if (e?.isAfter(DateTime.now()) == true) {
                      return "Date must be is before current Date";
                    } else {
                      return null;
                    }
                  },
                  onDateSelected: (DateTime value) {
                    var formattedDate =
                        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(value);
                    setState(() {
                      endDateTime = value;
                    });
                    print("endDateTime ${endDateTime}");
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [],
                ),
                const SizedBox(
                  height: 5,
                ),
                //Get Historic Trends----------------------
                // Text(
                //   error ? "Enter All Above Information" : "",
                //   style: TextStyle(color: Colors.red),
                // ),
                RaisedButton(
                  onPressed: () {
                    print("Button Clicked");
                    if (_key.currentState!.validate()) {
                      print(startDateTime);
                      print(endDateTime);
                      print(selectedHistoricGroup);

                      var PAST =
                          "http://${Utils.hostIP}/ScadaClient/api/HistoricTrendsData?PointName=DTms_0002&FromDate=${startDateTime}&ToDate=${endDateTime}";
                      print(PAST);
                    }

                    // if (startDateTime != null &&
                    //     endDateTime != null &&
                    //     selectedHistoricGroup.length > 0) {
                    //   if (startDateTime.isBefore(endDateTime) == true) {
                    //     print("true");
                    //     setState(() {
                    //       error = false;
                    //       _historicIsLoading = true;
                    //     });

                    //     var start = DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                    //         .format(startDateTime);
                    //     var end = DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                    //         .format(endDateTime);
                    //     historicTrends.getHistoricTrendsTagsData(
                    //         selectedHistoricGroup, start, end);
                    //     // startDateTime = null;
                    //     // endDateTime = null;
                    //     // selectedHistoricGroup = "";
                    //     // historicTrends.currentHistoricGroup ="";

                    //   } else {
                    //     print("false1");
                    //     setState(() {
                    //       error = true;
                    //     });
                    //   }
                    // } else {
                    //   print("false");
                    //   setState(() {
                    //     error = true;
                    //   });
                    // }
                  },
                  textColor: Colors.white,
                  padding: const EdgeInsets.all(0.0),
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color(0xFF0D47A1),
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: const Text('Get Historic Data'),
                  ),
                ),
                const SizedBox(
                  height: 10,
                )
              ])),
        );
      }
    })));
  }
}
