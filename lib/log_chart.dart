import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live_line_charts_sample/live_charts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LogChart extends StatefulWidget {
  final List<ChartData> chartLogData;

  const LogChart({Key? key, required this.chartLogData}) : super(key: key);
  @override
  _LogChartState createState() => _LogChartState();
}

class _LogChartState extends State<LogChart> {
  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    // TODO: implement initState
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.x,
      enablePanning: true,
    );
    _trackballBehavior = TrackballBehavior(
      // Enables the trackball
      enable: true,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          height: 300,
          child: SfCartesianChart(
              zoomPanBehavior: _zoomPanBehavior,
              trackballBehavior: _trackballBehavior,
              enableSideBySideSeriesPlacement: true,
              crosshairBehavior: CrosshairBehavior(
                  shouldAlwaysShow: true,
                  enable: true,
                  activationMode: ActivationMode.singleTap),
              enableAxisAnimation: true,
              legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  title: LegendTitle(text: "10 MIN PREVIOUS LOG")),
              primaryXAxis: DateTimeAxis(
                //dateFormat: DateFormat.y(),
                maximum: DateTime.now(),
                minimum: DateTime.now().subtract(Duration(minutes: 10)),
                intervalType: DateTimeIntervalType.auto,
                desiredIntervals: 5,
              ),
              primaryYAxis: NumericAxis(
                  axisLine: const AxisLine(width: 1),
                  majorTickLines: const MajorTickLines(size: 1)),
              series: <LineSeries<ChartData, DateTime>>[
                LineSeries<ChartData, DateTime>(
                  onRendererCreated: (ChartSeriesController controller) {
                    //  _chartSeriesController = controller;
                  },
                  dataSource: widget.chartLogData,
                  legendItemText: "Log_DTms_0010",
                  //  color: const Color.fromRGBO(192, 108, 132, 1),
                  color: Colors.redAccent,
                  xValueMapper: (ChartData sales, _) => sales.country,
                  yValueMapper: (ChartData sales, _) => sales.sales,
                  animationDuration: 0,
                )
              ]),
        ));
  }
}
