import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:live_line_charts_sample/Model/groupModel.dart';
import 'dart:math' as math;

import 'package:live_line_charts_sample/live_trend_page.dart';
import 'package:live_line_charts_sample/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LiveDataProvider extends ChangeNotifier {
  //WINDOW SPAN----------
  List<int> windowSpanItems = [1, 3, 5];
  int _selectedWindowSpan = 1;
  int get selectedwindowSpan => _selectedWindowSpan;
  set setSelectedWidnowSpan(int value) {
    _selectedWindowSpan = value;
  }

  //GROUPS-----------------
  List<String> _listOfGroups = [];
  List<String> get listOfGroups => _listOfGroups;

  //START AND STOP
  bool _isGraphStopped = false;
  bool get isGraphStopped => _isGraphStopped;
  set graphStopped(bool value) {
    _isGraphStopped = value;
    notifyListeners();
  }

  //GROUP INFO-----------
  List _selectedGroupData = [];
  List get selctedGroupData => _selectedGroupData;
  set selctedGroupDataSet(List value) {
    _selectedGroupData = value;
  }

  //SELECTED GROUP
  late String _seletedGroup;
  String get seletedGroup => _seletedGroup;
  set setSelectedGroup(String value) {
    _seletedGroup = value;
  }

  //CHART CONTROLLERS
  final List _controllers = [];

  //ChartSerirs
  List<LineSeries<ChartData, DateTime>> chartSeries = [];

  ///Chart DataSouce
  List<List<ChartData>> chartDatasource = [];
  List<GroupsModel> groupsData = [];
  late Timer _tagTimer;

  //START TIMER
  void startTimer(String selectedValue, BuildContext context) {
    _tagTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getSelectedGroupData(selectedValue, context);
    });
  }

//CANCEL TIMER
  void cancelTimer() {
    _tagTimer.cancel();
    notifyListeners();
  }

  //Fetching Groups Names API CAll--------------------------------------------------------------------------
  Future<List<GroupsModel>> getGroupsInfo(BuildContext context) async {
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
      _listOfGroups = uniqueJsonList;
      if (groupsData.isEmpty) {
        _seletedGroup = listOfGroups[0];
      }

      notifyListeners();
      // uniqueJsonList.map((item) => jsonDecode(item)).toList();
      groupsData = List<GroupsModel>.from(
          groups.map((e) => GroupsModel.fromJson(e)).toList());
      // if (returnLength == false) {
      //   setUpTimedFetch();
      // }
    } else if (response.statusCode == 500) {
      showAlert(context);
    } else {}
    notifyListeners();
    return groupsData;
  }

  ///Get the random data
  double _getRandomInt(int min, int max) {
    final math.Random _random = math.Random();
    return min + _random.nextInt(max - min).toDouble();
  }

  //Fetching Group Data API CAll--------------------------------------------------------------------------
  Future<List<GroupsModel>?> getSelectedGroupData(
      String selectedGroup, BuildContext context) async {
    var response = await http.get(Uri.parse(
        Utils.fetchSelectedGroupData + selectedGroup.replaceAll('"', '')));
    if (response.statusCode == 200) {
      _selectedGroupData = jsonDecode(response.body);
      //Work on Graph
      //if  series was not added

      if (chartDatasource.isEmpty) {
        //_selectedGroupData.length
        for (var i = 0; i < listOfGroups.length; i++) {
          // DateTime tempDate = DateFormat("2002-02-27T14:00:00")
          //     .parse(_selectedGroupData[i]['timestamp']);
          ///_selectedGroupData[i]['fvalue']
          chartDatasource.add([]);
        }
        notifyListeners();
      } else {
        print(_isGraphStopped);
        //_selectedGroupData.length
        for (var i = 0; i < _selectedGroupData.length; i++) {
          // DateTime tempDate = DateFormat("2002-02-27T14:00:00")
          //     .parse(_selectedGroupData[i]['timestamp']);
          ///_selectedGroupData[i]['fvalue']
          ////_getRandomInt(10, 100)
          chartDatasource[i]
              .add(ChartData(DateTime.now(), _getRandomInt(10, 100)));

          //Chart1 Datt update------
          if (_isGraphStopped == false) {
            if (chartDatasource[i].length >= _selectedWindowSpan * 60) {
              chartDatasource[i].removeAt(0);
              _controllers[i]?.updateDataSource(
                addedDataIndexes: <int>[chartDatasource[i].length - 1],
                removedDataIndexes: <int>[0],
              );
            } else {
              _controllers[i]?.updateDataSource(
                addedDataIndexes: <int>[chartDatasource[i].length - 1],
              );
            }
          }
        }
        //When graph is stoped donot update the chart
        if (_isGraphStopped == false) {
          notifyListeners();
        }
      }

      if (chartSeries.isEmpty) {
        //_selectedGroupData.length
        for (var i = 0; i < _selectedGroupData.length; i++) {
          final myInteger = _selectedGroupData[i]['PENCOLOR'];
          final hexString = myInteger.toRadixString(16);
          Color col = Color(int.parse(hexString, radix: 16));
          chartSeries.add(
            LineSeries<ChartData, DateTime>(
              onRendererCreated: (ChartSeriesController controller) {
                _controllers.add(controller);
              },
              dataSource: chartDatasource[i],
              name: _selectedGroupData[i]['POINTNAME'],
              // xAxisName: "DateTime",
              legendItemText: _selectedGroupData[i]['POINTNAME'],
              color: col,
              xValueMapper: (ChartData sales, _) => sales.country,
              yValueMapper: (ChartData sales, _) => sales.sales,

              animationDuration: 0,
            ),
          );
        }
      }
    } else if (response.statusCode == 500) {
      showAlert(context);
      // notifyListeners();
      return groupsData;
    } else {
      return null;
    }
  }
}

void showAlert(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => const AlertDialog(
            content: Text("hi"),
          ));
}
