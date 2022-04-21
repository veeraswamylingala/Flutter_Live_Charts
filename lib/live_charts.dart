import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:live_line_charts_sample/DataModel/groupModel.dart';
import 'package:live_line_charts_sample/Provider/live_data_provider.dart';
import 'package:live_line_charts_sample/utils.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LiveChart extends StatefulWidget {
  const LiveChart({Key? key}) : super(key: key);
  @override
  _LiveChartState createState() => _LiveChartState();
}

class _LiveChartState extends State<LiveChart> {
  //SELECTED GROUP-------
  String? seletedGroup;
  //SELECTED WINDOW SPAN------
  int selectedWindowSpan = 1;
  //Window Span items -------
  List<int> windowSpanItems = [1, 3, 5];

  //ChartSerirs
  List<LineSeries<ChartData, DateTime>> chartSeries = [];

  ///Chart DataSouce
  List<List<ChartData>> chartDatasource = [];
  List _selectedGroupData = [];
  final List<ChartSeriesController> _controllers = [];

  List<String> _listOfGroups = [];
  List<GroupsModel> groupsData = [];

  late int count;
  DateTime currentDatTime = DateTime.now();

  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;

  @override
  void dispose() {
    super.dispose();
  }

  late Timer _tagTimer;
  @override
  void initState() {
    //Zoomming---------------------------------
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.x,
      enablePanning: true,
    );
    //Panning-------------------------------
    _trackballBehavior = TrackballBehavior(
      // Enables the trackball
      enable: true,
    );
    if (seletedGroup == null) {
      getGroupsInfo();
    }
    super.initState();
  }

  ///timer
  void startTimer(String selectedValue) {
    _tagTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getSelectedGroupData(selectedValue);
    });
  }

  //Cancel TImer
  void cancelTimer() {
    _tagTimer.cancel();
  }

  //Fetching Groups Names API CAll--------------------------------------------------------------------------
  Future getSelectedGroupData(String selectedGroup) async {
    print(selectedGroup);
    var response = await http.get(Uri.parse(
        Utils.fetchSelectedGroupData + selectedGroup.replaceAll('"', '')));
    if (response.statusCode == 200) {
      print(response);

      //Work on Graph
      //if  series was not added

      if (chartDatasource.isEmpty) {
        //_selectedGroupData.length
        for (var i = 0; i < 1; i++) {
          // DateTime tempDate = DateFormat("2002-02-27T14:00:00")
          //     .parse(_selectedGroupData[i]['timestamp']);
          ///_selectedGroupData[i]['fvalue']
          setState(() {
            _selectedGroupData = jsonDecode(response.body);
            chartDatasource
                .add([ChartData(DateTime.now(), _getRandomInt(10, 100))]);
          });
        }
      } else {
        //_selectedGroupData.length
        for (var i = 0; i < 1; i++) {
          // DateTime tempDate = DateFormat("2002-02-27T14:00:00")
          //     .parse(_selectedGroupData[i]['timestamp']);
          ///_selectedGroupData[i]['fvalue']

          chartDatasource[i]
              .add(ChartData(DateTime.now(), _getRandomInt(10, 100)));
          setState(() {});
          //Chart1 Datt update------
          if (chartDatasource[i].length >= selectedWindowSpan * 60) {
            //   chartDatasource[i].removeAt(0);
            _controllers[i].updateDataSource(
              addedDataIndexes: <int>[chartDatasource[i].length - 1],
              // removedDataIndexes: <int>[0],
            );
          } else {
            _controllers[i].updateDataSource(
              addedDataIndexes: <int>[chartDatasource[i].length - 1],
            );
          }
        }
      }

      if (chartSeries.isEmpty) {
        //_selectedGroupData.length
        for (var i = 0; i < 1; i++) {
          chartSeries.add(
            LineSeries<ChartData, DateTime>(
              onRendererCreated: (ChartSeriesController controller) {
                _controllers.add(controller);
              },
              dataSource: chartDatasource[i],
              name: _selectedGroupData[i]['POINTNAME'],
              // xAxisName: "DateTime",
              legendItemText: _selectedGroupData[i]['POINTNAME'],
              color: Colors.redAccent,
              xValueMapper: (ChartData sales, _) => sales.country,
              yValueMapper: (ChartData sales, _) => sales.sales,
              // markerSettings: const MarkerSettings(
              //     isVisible: true,
              //     // Marker shape is set to diamond
              //     shape: DataMarkerType.circle),
              animationDuration: 0,
            ),
          );
        }
      }
    } else {}
    // notifyListeners();
  }

  ///Get the random data
  double _getRandomInt(int min, int max) {
    final math.Random _random = math.Random();
    return min + _random.nextInt(max - min).toDouble();
  }

  //Fetching Groups Names API CAll--------------------------------------------------------------------------
  Future<List<GroupsModel>> getGroupsInfo() async {
    var response = await http.get(Uri.parse(Utils.fecthGroupNames));

    if (response.statusCode == 200) {
      List groups = jsonDecode(response.body);
      // convert each item to a string by using JSON encoding
      final jsonList =
          groups.map((item) => jsonEncode(item['CURTRENDTITLE'])).toList();
      // using toSet - toList strategy
      final uniqueJsonList = jsonList.toSet().toList();
      // convert each item back to the original form using JSON decoding
      //GroupNames array which has group names
      setState(() {
        _listOfGroups = uniqueJsonList;
        if (seletedGroup == null) {
          seletedGroup = _listOfGroups[0];
        }
        // uniqueJsonList.map((item) => jsonDecode(item)).toList();
        groupsData = List<GroupsModel>.from(
            groups.map((e) => GroupsModel.fromJson(e)).toList());
      });

      // if (returnLength == false) {
      //   setUpTimedFetch();
      // }
    } else {}
    return groupsData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const Icon(
            Icons.trending_up_rounded,
          ),
          title: const Text("Live Data"),
        ),
        body: Container(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: _listOfGroups.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                          Card(
                              color: Colors.black38,
                              child: Column(children: [
                                //Graph Section-------------
                                Container(child: _buildLiveLineChart()),
                                Card(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      //Selecet Window Span--------------------------------------
                                      const Text("Window Span(S) :"),
                                      DropdownButton(
                                        // Initial Value
                                        value: selectedWindowSpan,
                                        // Down Arrow Icon
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        // Array list of items
                                        items: windowSpanItems.map((int items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(items.toString()),
                                          );
                                        }).toList(),
                                        // After selecting the desired option,it will
                                        // change button value to selected value
                                        onChanged: (newValue) {
                                          selectedWindowSpan =
                                              (newValue! as int?)!;
                                        },
                                      ),
                                      Text(" Group :"),
                                      //Selecet Group--------------------------------------
                                      DropdownButton(
                                        // Initial Value
                                        value: seletedGroup,
                                        // Down Arrow Icon
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        // Array list of items
                                        items:
                                            _listOfGroups.map((String items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(items),
                                          );
                                        }).toList(),
                                        // After selecting the desired option,it will
                                        // change button value to selected value
                                        onChanged: (newValue) {
                                          cancelTimer();
                                          _selectedGroupData = [];
                                          chartSeries = [];
                                          chartDatasource = [];
                                          // setState(() {});
                                          setState(() {
                                            seletedGroup = newValue! as String;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ])),
                          const SizedBox(
                            height: 10,
                          ),
                          // if (currentDatTime != null)
                          //   Container(
                          //     alignment: Alignment.topRight,
                          //     child: Text.rich(
                          //       TextSpan(
                          //         children: [
                          //           TextSpan(
                          //               text: DateFormat('dd MMM yyyy')
                          //                   .format(currentDatTime)
                          //                   .toString()),
                          //           const TextSpan(text: ' - '),
                          //           TextSpan(
                          //             text: DateFormat('KK:mm:ss a')
                          //                 .format(currentDatTime)
                          //                 .toString(),
                          //             style: const TextStyle(
                          //                 color: Colors.redAccent,
                          //                 fontSize: 19,
                          //                 //    decoration: TextDecoration.underline,
                          //                 fontWeight: FontWeight.normal),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          const SizedBox(
                            height: 10,
                          ),

                          //Data Table--------------------
                          // Container(
                          //     child: Column(
                          //   children: [
                          //     SizedBox(
                          //       height: 10,
                          //     ),
                          //     Container(
                          //         alignment: Alignment.topLeft,
                          //         child: Text(
                          //           "Data Table",
                          //           style: TextStyle(color: Colors.red, fontSize: 19),
                          //         )),
                          //     SizedBox(
                          //       height: 10,
                          //     ),
                          //     Card(
                          //       color: Colors.black54,
                          //       child: Table(
                          //           defaultColumnWidth: FixedColumnWidth(120.0),
                          //           border: TableBorder.all(
                          //               color: Colors.white,
                          //               style: BorderStyle.solid,
                          //               width: 0.5),
                          //           children: [
                          //             TableRow(
                          //                 decoration:
                          //                     const BoxDecoration(color: Colors.grey),
                          //                 children: [
                          //                   Column(children: const [
                          //                     Text('Tag',
                          //                         style: TextStyle(
                          //                             fontSize: 18.0,
                          //                             fontWeight: FontWeight.bold))
                          //                   ]),
                          //                   Column(children: const [
                          //                     Text('Group',
                          //                         style: TextStyle(
                          //                             fontSize: 18.0,
                          //                             fontWeight: FontWeight.bold))
                          //                   ]),
                          //                   Column(children: const [
                          //                     Text('fValue',
                          //                         style: TextStyle(
                          //                             fontSize: 18.0,
                          //                             fontWeight: FontWeight.bold))
                          //                   ]),
                          //                 ]),
                          //             TableRow(children: [
                          //               Container(
                          //                 height: 50,
                          //                 child: const Center(
                          //                   child: Text('DTms_0010',
                          //                       style: TextStyle(
                          //                           fontSize: 13.0,
                          //                           fontWeight: FontWeight.bold)),
                          //                 ),
                          //               ),
                          //               Container(
                          //                 height: 50,
                          //                 child: const Center(
                          //                   child: Text('DAT',
                          //                       style: TextStyle(
                          //                           fontSize: 13.0,
                          //                           fontWeight: FontWeight.bold)),
                          //                 ),
                          //               ),
                          //               Container(
                          //                 height: 50,
                          //                 child: Center(
                          //                   child: Text(_dtms_0010_tagValue.toString(),
                          //                       style: const TextStyle(
                          //                           fontSize: 18.0,
                          //                           color: Colors.redAccent,
                          //                           fontWeight: FontWeight.bold)),
                          //                 ),
                          //               ),
                          //             ]),
                          //             TableRow(children: [
                          //               Container(
                          //                 height: 50,
                          //                 child: const Center(
                          //                   child: Text('DTms_0011',
                          //                       style: TextStyle(
                          //                           fontSize: 13.0,
                          //                           fontWeight: FontWeight.bold)),
                          //                 ),
                          //               ),
                          //               Container(
                          //                 height: 50,
                          //                 child: const Center(
                          //                   child: Text('DAT',
                          //                       style: TextStyle(
                          //                           fontSize: 13.0,
                          //                           fontWeight: FontWeight.bold)),
                          //                 ),
                          //               ),
                          //               Container(
                          //                 height: 50,
                          //                 child: Center(
                          //                   child: Text(_dtms_0011_tagValue.toString(),
                          //                       style: const TextStyle(
                          //                           fontSize: 18.0,
                          //                           color: Colors.blueAccent,
                          //                           fontWeight: FontWeight.bold)),
                          //                 ),
                          //               ),
                          //             ]),
                          //           ]),
                          //     )
                          //   ],
                          // )),
                        ])),
        ));
  }

  /// Returns the realtime Cartesian line chart.
  Widget _buildLiveLineChart() {
    if (_selectedGroupData.isEmpty) {
      startTimer(seletedGroup!);
      return Container(
          height: 300, child: Center(child: CircularProgressIndicator()));
    } else {
      return Column(
        children: [
          SfCartesianChart(
            //ZOOMs
            zoomPanBehavior: _zoomPanBehavior,
            //PAN
            trackballBehavior: _trackballBehavior,

            // borderColor: Colors.red,
            // borderWidth: 2,
            // Sets 15 logical pixels as margin for all the 4 sides.
            // margin: EdgeInsets.all(15),
            //enableSideBySideSeriesPlacement: false,
            // crosshairBehavior: CrosshairBehavior(
            //     shouldAlwaysShow: true,
            //     enable: true,
            //     activationMode: ActivationMode.singleTap),
            ///  enableAxisAnimation: false,
            //LEGEND INFOS
            legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                title: LegendTitle(
                    text: "${selectedWindowSpan.toString()} MIN LIVE GRAPH")),

            //plotAreaBorderWidth: 0,
            //DateTime---
            primaryXAxis: DateTimeAxis(
                autoScrollingMode: AutoScrollingMode.end,
                desiredIntervals: 5,
                minimum: DateTime.now().subtract(Duration(minutes: 1)),

                // labelFormat: '{value}°S',
                // title: AxisTitle(
                //   text: 'TagPoint',
                // ),
                //
                maximum: DateTime.now()
                // majorGridLines: const MajorGridLines(width: 3)
                ),
            primaryYAxis: NumericAxis(
                // title: AxisTitle(
                //   text: 'TagPoint',
                // ),
                // opposedPosition: true,
                axisLine: const AxisLine(width: 1),
                majorTickLines: const MajorTickLines(size: 1)),

            series: chartSeries,
          ),

          // <LineSeries<ChartData, DateTime>>[
          //   LineSeries<ChartData, DateTime>(
          //     onRendererCreated: (ChartSeriesController controller) {
          //       _chart1SeriesController = controller;
          //     },
          //     dataSource: chart1Data!,
          //     name: "DTms_0010",
          //     // xAxisName: "DateTime",
          //     legendItemText: "DTms_0010",
          //     color: Colors.redAccent,
          //     xValueMapper: (ChartData sales, _) => sales.country,
          //     yValueMapper: (ChartData sales, _) => sales.sales,
          //     // markerSettings: const MarkerSettings(
          //     //     isVisible: true,
          //     //     // Marker shape is set to diamond
          //     //     shape: DataMarkerType.circle),
          //     animationDuration: 0,
          //   ),
          //   LineSeries<ChartData, DateTime>(
          //     onRendererCreated: (ChartSeriesController controller) {
          //       _chart2SeriesController = controller;
          //     },
          //     dataSource: chart2Data!,
          //     name: "DTms_0011",
          //     // xAxisName: "DateTime",
          //     legendItemText: "DTms_0011",
          //     color: Colors.blueAccent,
          //     xValueMapper: (ChartData sales, _) => sales.country,
          //     yValueMapper: (ChartData sales, _) => sales.sales,
          //     // markerSettings: const MarkerSettings(
          //     //     isVisible: true,
          //     //     // Marker shape is set to diamond
          //     //     shape: DataMarkerType.circle),
          //     animationDuration: 0,

          // Center(
          //   child: IconButton(
          //       onPressed: () {
          //         ///If grpah is  Resumed-----------------
          //         if (_isGraphStopped) {
          //           //Start Timer------
          //           data.startTimer(selectedGroup!);
          //           // _LiveLineChartState();
          //         }
          //         //if Graph is Stopped-------------------
          //         else {
          //           //Stop Grapph--------------
          //           ///   _stopGraph();
          //           data.cancelTimer();
          //         }
          //       },
          //       icon: Icon(
          //         _isGraphStopped
          //             ? Icons.play_circle_fill
          //             : Icons.pause_circle_filled,
          //         size: 40,
          //       )),
          // ),
          //Text(_isGraphStopped ? "START" : "STOP"),
        ],
      );
    }
  }

  ///Continously updating the data source based on timer
  // void _updateDataSource(Timer timer) {
  //   setState(() {
  //     currentDatTime = DateTime.now();
  //     _isGraphStopped = false;
  //   });
  //   //generate random value
  //   int random1 = _getRandomInt(10, 100);
  //   int random2 = _getRandomInt(10, 100);
  //   setState(() {
  //     _dtms_0010_tagValue = random1;
  //     _dtms_0011_tagValue = random2;
  //   });
  //   //chart1
  //   chart1Data!.add(ChartData(DateTime.now(), random1.toDouble()));
  //   //chart2
  //   chart2Data!.add(ChartData(DateTime.now(), random2.toDouble()));
  //   //Chart1 Datt update------
  //   if (chart1Data!.length >= selectedWindowSpan! * 60) {
  //     chart1Data!.removeAt(0);
  //     _chart1SeriesController?.updateDataSource(
  //       addedDataIndexes: <int>[chart1Data!.length - 1],
  //       removedDataIndexes: <int>[0],
  //     );
  //   } else {
  //     _chart1SeriesController?.updateDataSource(
  //       addedDataIndexes: <int>[chart1Data!.length - 1],
  //     );
  //   }
  //   //Chart2 Datt update------
  //   if (chart2Data!.length >= selectedWindowSpan! * 60) {
  //     chart2Data!.removeAt(0);
  //     _chart2SeriesController?.updateDataSource(
  //       addedDataIndexes: <int>[chart2Data!.length - 1],
  //       removedDataIndexes: <int>[0],
  //     );
  //   } else {
  //     _chart2SeriesController?.updateDataSource(
  //       addedDataIndexes: <int>[chart2Data!.length - 1],
  //     );
  //   }
  //   count = count + 1;
  // }

  ///Get the random data
  // int _getRandomInt(int min, int max) {
  //   final math.Random _random = math.Random();
  //   return min + _random.nextInt(max - min);
  // }

//Stop graph
  // _stopGraph() {
  //   setState(() {
  //     _isGraphStopped = true;
  //   });
  //   timer!.cancel();
  // }
}

/// Private calss for storing the chart series data points.
class ChartData {
  ChartData(this.country, this.sales);
  final DateTime country;
  final double sales;
}
