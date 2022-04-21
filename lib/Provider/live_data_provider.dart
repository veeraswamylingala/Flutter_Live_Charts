import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:live_line_charts_sample/DataModel/groupModel.dart';
import 'package:live_line_charts_sample/live_charts.dart';
import 'package:live_line_charts_sample/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LiveDataProvider extends ChangeNotifier {
  String? seletedGroup;
  int selectedWindowSpan = 1;

  List<String> get listOfGroups => _listOfGroups;
  List<String> _listOfGroups = [];

//_selectedGroupData getter
  List get selctedGroupData => _selectedGroupData;

//_selectedGroupData setter
  set selctedGroupDataSet(List value) {
    _selectedGroupData = value;
  }

  List _selectedGroupData = [];
  List _controllers = [];

//ChartSerirs
  List<LineSeries<ChartData, DateTime>> chartSeries = [];

  ///Chart DataSouce
  List<List<ChartData>> chartDatasource = [];

  List<GroupsModel> groupsData = [];
  List<String> tagDAS1 = ["DAS1_IND_01", "DAS1_IND_02"];
  List<String> tagDAS2 = ["DAS2_OK_01", "DAS2_OK_02"];
  List<int> windowSpanItems = [1, 3, 5];

  late Timer _tagTimer;

  ///timer
  void startTimer(String selectedValue) {
    _tagTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getSelectedGroupData(selectedValue);
    });
  }

//Cancel TImer
  void cancelTimer() {
    _tagTimer.cancel();
    notifyListeners();
  }

//UPdate Tags
  void updateTagsData() {}

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
      _listOfGroups = uniqueJsonList;
      if (seletedGroup == null) {
        seletedGroup = listOfGroups[0];
      }
      notifyListeners();
      // uniqueJsonList.map((item) => jsonDecode(item)).toList();
      groupsData = List<GroupsModel>.from(
          groups.map((e) => GroupsModel.fromJson(e)).toList());
      // if (returnLength == false) {
      //   setUpTimedFetch();
      // }
    } else {}
    notifyListeners();
    return groupsData;
  }

  ///Get the random data
  double _getRandomInt(int min, int max) {
    final math.Random _random = math.Random();
    return min + _random.nextInt(max - min).toDouble();
  }

  //Fetching Groups Names API CAll--------------------------------------------------------------------------
  Future<List<GroupsModel>> getSelectedGroupData(String selectedGroup) async {
    print(selectedGroup);
    var response = await http.get(Uri.parse(
        Utils.fetchSelectedGroupData + selectedGroup.replaceAll('"', '')));
    if (response.statusCode == 200) {
      print(response);
      _selectedGroupData = jsonDecode(response.body);
      //Work on Graph
      //if  series was not added

      if (chartDatasource.isEmpty) {
        //_selectedGroupData.length
        for (var i = 0; i < 1; i++) {
          // DateTime tempDate = DateFormat("2002-02-27T14:00:00")
          //     .parse(_selectedGroupData[i]['timestamp']);
          ///_selectedGroupData[i]['fvalue']
          chartDatasource
              .add([ChartData(DateTime.now(), _getRandomInt(10, 100))]);
        }
        notifyListeners();
      } else {
        //_selectedGroupData.length
        for (var i = 0; i < 1; i++) {
          // DateTime tempDate = DateFormat("2002-02-27T14:00:00")
          //     .parse(_selectedGroupData[i]['timestamp']);
          ///_selectedGroupData[i]['fvalue']
          chartDatasource[i]
              .add(ChartData(DateTime.now(), _getRandomInt(10, 100)));
          //Chart1 Datt update------
          if (chartDatasource[i].length >= selectedWindowSpan * 60) {
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
        notifyListeners();
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
    return groupsData;
  }
}
