import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:live_line_charts_sample/Model/groupModel.dart';
import 'package:live_line_charts_sample/Provider/live_data_provider.dart';
import 'package:live_line_charts_sample/utils.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LiveTrend extends StatefulWidget {
  const LiveTrend({Key? key}) : super(key: key);
  @override
  _LiveTrendState createState() => _LiveTrendState();
}

class _LiveTrendState extends State<LiveTrend> {
  //SELECTED WINDOW SPAN------
  int selectedWindowSpan = 3;
  //Window Span items -------
  List<int> windowSpanItems = [1, 3, 5];
//SELECTED GROUP-------
  String? seletedGroup;
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
  bool isGraphStopped = false;

  @override
  void dispose() {
    // Provider.of<LiveDataProvider>(context, listen: false).cancelTimer();

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

    getGroups();
    super.initState();
  }

  //Calling Provider groups Api------
  Future<void> getGroups() async {
    await Provider.of<LiveDataProvider>(context, listen: false)
        .getGroupsInfo(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SingleChildScrollView(
      child: Container(
        child: Consumer<LiveDataProvider>(builder: (context, livechart, child) {
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: livechart.listOfGroups.isEmpty
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
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                livechart.graphStopped =
                                                    !livechart.isGraphStopped;
                                              },
                                              icon: Icon(
                                                livechart.isGraphStopped
                                                    ? Icons.play_circle_fill
                                                    : Icons.pause_circle_filled,
                                                size: 40,
                                              )),
                                          Text(livechart.isGraphStopped
                                              ? "START"
                                              : "STOP"),
                                        ],
                                      ),

                                      //Selecet Window Span--------------------------------------
                                      const Text("Window Span :"),
                                      DropdownButton(
                                        // Initial Value
                                        value: livechart.selectedwindowSpan,
                                        // Down Arrow Icon
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        // Array list of items
                                        items: livechart.windowSpanItems
                                            .map((int items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(items.toString()),
                                          );
                                        }).toList(),
                                        // After selecting the desired option,it will
                                        // change button value to selected value
                                        onChanged: (newValue) {
                                          livechart.graphStopped = false;
                                          livechart.setSelectedWidnowSpan =
                                              (newValue! as int?)!;
                                        },
                                      ),
                                      const Text(" Group :"),
                                      //Selecet Group--------------------------------------
                                      DropdownButton(
                                        // Initial Value
                                        value: livechart.seletedGroup,
                                        // Down Arrow Icon
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        // Array list of items
                                        items: livechart.listOfGroups
                                            .map((String items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(items),
                                          );
                                        }).toList(),
                                        // After selecting the desired option,it will
                                        // change button value to selected value
                                        onChanged: (newValue) {
                                          livechart.graphStopped = false;
                                          livechart.cancelTimer();
                                          livechart.selctedGroupDataSet = [];
                                          livechart.chartSeries = [];
                                          livechart.chartDatasource = [];
                                          // setState(() {});
                                          livechart.setSelectedGroup =
                                              newValue! as String;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ])),
                          Card(
                            color: Colors.black38,
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        child: Text(
                                            " ${livechart.seletedGroup}  Values -")),
                                    Container(
                                        child: Text(
                                      DateFormat('yyyy-MM-dd : kk:mm:ss ')
                                          .format(DateTime.now()),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ],
                                ),
                              ),
                              //Data Table--------------------
                              Container(
                                // decoration: BoxDecoration(
                                //     border: Border.all(color: Colors.grey)),
                                child: Theme(
                                  data: ThemeData.light(),
                                  child: HorizontalDataTable(
                                    leftHandSideColumnWidth: 100,
                                    rightHandSideColumnWidth: 350,
                                    isFixedHeader: true,
                                    headerWidgets: _getTitleWidget(),
                                    leftSideItemBuilder:
                                        _generateFirstColumnRow,
                                    rightSideItemBuilder: _right,
                                    itemCount:
                                        livechart.selctedGroupData.length,
                                    rowSeparatorWidget: const Divider(
                                      color: Colors.black54,
                                      height: 1.0,
                                      thickness: 0.0,
                                    ),
                                    leftHandSideColBackgroundColor:
                                        Color(0xFFFFFFFF),
                                    rightHandSideColBackgroundColor:
                                        Color(0xFFFFFFFF),
                                  ),
                                ),
                                height: 50 +
                                    (livechart.selctedGroupData.length) *
                                        45.toDouble(),
                              )
                            ]),
                          )
                        ]));
        }),
      ),
    ));
  }

  /// Returns the realtime Cartesian line chart.
  Widget _buildLiveLineChart() {
    return Consumer<LiveDataProvider>(builder: (context, livechart, chid) {
      if (livechart.selctedGroupData.isEmpty) {
        livechart.startTimer(livechart.seletedGroup, context);

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
              legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  title: LegendTitle(
                      text:
                          "${livechart.selectedwindowSpan.toString()} MIN LIVE GRAPH")),

              primaryXAxis: DateTimeAxis(
                  autoScrollingMode: AutoScrollingMode.end,
                  desiredIntervals: 5,
                  minimum: DateTime.now().subtract(
                      Duration(minutes: livechart.selectedwindowSpan)),
                  labelFormat: '{value}°S',
                  // title: AxisTitle(
                  //   text: 'TagPoint',
                  // ),
                  maximum: DateTime.now()),
              primaryYAxis: NumericAxis(
                  axisLine: const AxisLine(width: 1),
                  majorTickLines: const MajorTickLines(size: 1)),

              series: livechart.chartSeries,
            ),
          ],
        );
      }
    });
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('Tag Names', 100),
      _getTitleItemWidget('CurTrendTitle', 100),
      // _getTitleItemWidget('UpperValue', 100),
      // _getTitleItemWidget('LowerValue', 100),
      _getTitleItemWidget('fValue', 100),
      _getTitleItemWidget('PenColor', 130),
      //  _getTitleItemWidget('EDIT', 50),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      color: Colors.black,
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      width: width,
      height: 40,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  //Current Tags Table FirstColumn Widegt----------------
  Widget _generateFirstColumnRow(BuildContext context, int index) {
    // print(index);
    return Consumer<LiveDataProvider>(builder: (context, livetrend, _) {
      return GestureDetector(
          onTap: () {
            //   print("${livetrend.[index]['POINTNAME']} tapped");
          },
          child: Container(
            child: Text(
              livetrend.selctedGroupData[index]['POINTNAME'],
              style: TextStyle(color: Colors.black),
            ),
            width: 100,
            height: 40,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ));
    });
  }

  //Current Tags Table FirstColumn Widegt----------------
  Widget _right(BuildContext context, int index) {
    // print(index);
    return Consumer<LiveDataProvider>(builder: (context, livetrend, _) {
      final myInteger = livetrend.selctedGroupData[index]['PENCOLOR'];
      final hexString = myInteger.toRadixString(16);
      Color col = Color(int.parse(hexString, radix: 16)).withOpacity(1.0);

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Text(
              livetrend.selctedGroupData[index]['CURTRENDTITLE'],
              style: TextStyle(color: Colors.black),
            ),
            width: 100,
            height: 40,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
          // Container(
          //   child: graphsEditableData[index].upperValue.length == 0
          //       ? Text(tagsData[index]['UPPERVALUE'].toString())
          //       : Text(graphsEditableData[index].upperValue.toString()),
          //   width: 100,
          //   height: 40,
          //   padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          //   alignment: Alignment.centerLeft,
          // ),
          //LowerValue-----------------------------------------------------
          // Container(
          //   child: graphsEditableData[index].lowerValue.length == 0
          //       ? Text(tagsData[index]['LOWERVALUE'].toString())
          //       : Text(graphsEditableData[index].lowerValue.toString()),
          //   width: 100,
          //   height: 40,
          //   padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          //   alignment: Alignment.centerLeft,
          // ),
          //LowerValue-----------------------------------------------------
          Container(
            child: Text(
              livetrend.selctedGroupData[index]['fvalue'].toString(),
              style: TextStyle(color: Colors.black),
            ),
            width: 100,
            height: 40,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),

          // PenColor------------------------------------------------
          Container(
            color: col,
            width: 130,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // IconButton(
                //     icon: Icon(Icons.add_box_sharp),
                //     onPressed: () {
                //       colorPicker();
                //     }),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                      livetrend.selctedGroupData[index]['PENCOLOR'].toString()),
                  width: 80,
                  height: 40,
                ),
              ],
            ),
          ),

          // Container(
          //   width: 50,
          //   height: 40,
          //   padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          //   alignment: Alignment.centerLeft,
          //   child: FlatButton(
          //       onPressed: () {
          //         print("${tagsData[index]['POINTNAME']} Clicked");
          //         showTrendsEditPopup(tagsData[index]['POINTNAME'], index);
          //       },
          //       child: Icon(Icons.edit)),
          // )
        ],
      );
    });
  }
}

/// Private calss for storing the chart series data points.
class ChartData {
  ChartData(this.country, this.sales);
  final DateTime country;
  final double sales;
}
