import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live_line_charts_sample/log_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LiveChart extends StatefulWidget {
  const LiveChart({Key? key}) : super(key: key);

  @override
  _LiveChartState createState() => _LiveChartState();
}

class _LiveChartState extends State<LiveChart> {
  int _dtms_0010_tagValue = 0;
  int _dtms_0011_tagValue = 0;
  bool _isGraphStopped = true;
  // ignore: non_constant_identifier_names
  _LiveLineChartState() {
    timer = Timer.periodic(const Duration(seconds: 1), _updateDataSource);
  }

  Timer? timer;
  List<ChartData>? chart1Data;
  List<ChartData>? chart2Data;
  late int count;
  ChartSeriesController? _chart1SeriesController;
  ChartSeriesController? _chart2SeriesController;
  DateTime currentDatTime = DateTime.now();

  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;

  @override
  void dispose() {
    timer?.cancel();
    chart1Data!.clear();
    chart2Data!.clear();
    _chart1SeriesController = null;
    _chart2SeriesController = null;
    super.dispose();
  }

  @override
  void initState() {
    count = 19;
    chart1Data = <ChartData>[
      ChartData(DateTime.now(), 0),
    ];
    chart2Data = <ChartData>[
      ChartData(DateTime.now(), 0),
    ];

    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.x,
      enablePanning: true,
    );
    _trackballBehavior = TrackballBehavior(
      // Enables the trackball
      enable: true,
    );
    _LiveLineChartState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Icon(
            Icons.trending_up_rounded,
          ),
          title: Text("Live Data"),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    "Data sTrend",
                    style: TextStyle(color: Colors.red, fontSize: 19),
                  )),
              const SizedBox(
                height: 5,
              ),
              Card(
                color: Colors.black38,
                child: Column(
                  children: [
                    Container(height: 300, child: _buildLiveLineChart()),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                            onPressed: () {
                              if (_isGraphStopped) {
                                _LiveLineChartState();
                              } else {
                                _stopGraph();
                              }
                            },
                            icon: Icon(
                              _isGraphStopped
                                  ? Icons.play_circle_fill
                                  : Icons.pause_circle_filled,
                              size: 40,
                            )),
                      ),
                    ),
                    Text(_isGraphStopped ? "START" : "STOP")
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (currentDatTime != null)
                Container(
                  alignment: Alignment.topRight,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: DateFormat('dd MMM yyyy')
                                .format(currentDatTime)
                                .toString()),
                        const TextSpan(text: ' - '),
                        TextSpan(
                          text: DateFormat('KK:mm:ss a')
                              .format(currentDatTime)
                              .toString(),
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 19,
                              //    decoration: TextDecoration.underline,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),

              Container(
                  child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Data Table",
                        style: TextStyle(color: Colors.red, fontSize: 19),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    color: Colors.black54,
                    child: Table(
                        defaultColumnWidth: FixedColumnWidth(120.0),
                        border: TableBorder.all(
                            color: Colors.white,
                            style: BorderStyle.solid,
                            width: 0.5),
                        children: [
                          TableRow(
                              decoration:
                                  const BoxDecoration(color: Colors.grey),
                              children: [
                                Column(children: const [
                                  Text('Tag',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold))
                                ]),
                                Column(children: const [
                                  Text('Group',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold))
                                ]),
                                Column(children: const [
                                  Text('fValue',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold))
                                ]),
                              ]),
                          TableRow(children: [
                            Container(
                              height: 50,
                              child: const Center(
                                child: Text('DTms_0010',
                                    style: TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Container(
                              height: 50,
                              child: const Center(
                                child: Text('DAT',
                                    style: TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Container(
                              height: 50,
                              child: Center(
                                child: Text(_dtms_0010_tagValue.toString(),
                                    style: const TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ]),
                          TableRow(children: [
                            Container(
                              height: 50,
                              child: const Center(
                                child: Text('DTms_0011',
                                    style: TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Container(
                              height: 50,
                              child: const Center(
                                child: Text('DAT',
                                    style: TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Container(
                              height: 50,
                              child: Center(
                                child: Text(_dtms_0011_tagValue.toString(),
                                    style: const TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ]),
                        ]),
                  )
                ],
              )),
              // Container(
              //   width: MediaQuery.of(context).size.width,
              //   child: OutlinedButton(
              //     style: ButtonStyle(
              //       shape: MaterialStateProperty.all(RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(0.0))),
              //     ),

              //     ///   color: Colors.red,
              //     onPressed: () {
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => LogChart(
              //                     chartLogData: chartData!,
              //                   )));
              //     },
              //     child: const Text(
              //       "Show log",
              //       style: TextStyle(color: Colors.white),
              //     ),
              //   ),
              // ),
            ]),
          ),
        ));
  }

  /// Returns the realtime Cartesian line chart.
  SfCartesianChart _buildLiveLineChart() {
    return SfCartesianChart(
        zoomPanBehavior: _zoomPanBehavior,
        trackballBehavior: _trackballBehavior,

        // borderColor: Colors.red,
        // borderWidth: 2,
        // Sets 15 logical pixels as margin for all the 4 sides.
        // margin: EdgeInsets.all(15),
        enableSideBySideSeriesPlacement: false,
        // crosshairBehavior: CrosshairBehavior(
        //     shouldAlwaysShow: true,
        //     enable: true,
        //     activationMode: ActivationMode.singleTap),
        enableAxisAnimation: true,
        legend: Legend(
            isVisible: true,
            position: LegendPosition.bottom,
            title: LegendTitle(text: "3 MIN LIVE GRAPH")),

        //plotAreaBorderWidth: 0,
        //DateTime---
        primaryXAxis: DateTimeAxis(
          desiredIntervals: 5,
          // labelFormat: '{value}°S',
          // title: AxisTitle(
          //   text: 'TagPoint',
          // ),
          //interval: 3, majorGridLines: const MajorGridLines(width: 1)
        ),
        primaryYAxis: NumericAxis(
            // title: AxisTitle(
            //   text: 'TagPoint',
            // ),
            // opposedPosition: true,
            axisLine: const AxisLine(width: 1),
            majorTickLines: const MajorTickLines(size: 1)),
        series: <LineSeries<ChartData, DateTime>>[
          LineSeries<ChartData, DateTime>(
            onRendererCreated: (ChartSeriesController controller) {
              _chart1SeriesController = controller;
            },
            dataSource: chart1Data!,
            name: "DTms_0010",
            // xAxisName: "DateTime",
            legendItemText: "DTms_0010",
            color: Colors.redAccent,
            xValueMapper: (ChartData sales, _) => sales.country,
            yValueMapper: (ChartData sales, _) => sales.sales,
            // markerSettings: const MarkerSettings(
            //     isVisible: true,
            //     // Marker shape is set to diamond
            //     shape: DataMarkerType.circle),
            animationDuration: 0,
          ),
          LineSeries<ChartData, DateTime>(
            onRendererCreated: (ChartSeriesController controller) {
              _chart2SeriesController = controller;
            },
            dataSource: chart2Data!,
            name: "DTms_0011",
            // xAxisName: "DateTime",
            legendItemText: "DTms_0011",
            color: Colors.blueAccent,
            xValueMapper: (ChartData sales, _) => sales.country,
            yValueMapper: (ChartData sales, _) => sales.sales,
            // markerSettings: const MarkerSettings(
            //     isVisible: true,
            //     // Marker shape is set to diamond
            //     shape: DataMarkerType.circle),
            animationDuration: 0,
          ),
        ]);
  }

  ///Continously updating the data source based on timer
  void _updateDataSource(Timer timer) {
    setState(() {
      currentDatTime = DateTime.now();
      _isGraphStopped = false;
    });
    //generate random value
    int random1 = _getRandomInt(10, 100);
    int random2 = _getRandomInt(10, 100);
    setState(() {
      _dtms_0010_tagValue = random1;
      _dtms_0011_tagValue = random2;
    });
    //chart1
    chart1Data!.add(ChartData(DateTime.now(), random1));
    //chart2
    chart2Data!.add(ChartData(DateTime.now(), random2));
    //Chart1 Datt update------
    if (chart1Data!.length >= 180) {
      chart1Data!.removeAt(0);
      _chart1SeriesController?.updateDataSource(
        addedDataIndexes: <int>[chart1Data!.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _chart1SeriesController?.updateDataSource(
        addedDataIndexes: <int>[chart1Data!.length - 1],
      );
    }
    //Chart2 Datt update------
    if (chart2Data!.length >= 180) {
      chart2Data!.removeAt(0);
      _chart2SeriesController?.updateDataSource(
        addedDataIndexes: <int>[chart2Data!.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _chart2SeriesController?.updateDataSource(
        addedDataIndexes: <int>[chart2Data!.length - 1],
      );
    }
    count = count + 1;
  }

  ///Get the random data
  int _getRandomInt(int min, int max) {
    final math.Random _random = math.Random();
    return min + _random.nextInt(max - min);
  }

//Stop graph
  _stopGraph() {
    setState(() {
      _isGraphStopped = true;
    });
    timer!.cancel();
  }
}

/// Private calss for storing the chart series data points.
class ChartData {
  ChartData(this.country, this.sales);
  final DateTime country;
  final num sales;
}
