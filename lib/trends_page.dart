import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live_line_charts_sample/Provider/live_data_provider.dart';
import 'package:live_line_charts_sample/historic_trend_page.dart';
import 'package:live_line_charts_sample/live_trend_page.dart';
import 'package:live_line_charts_sample/log_data.dart';
import 'package:provider/provider.dart';

class TrendsPage extends StatefulWidget {
  const TrendsPage({Key? key}) : super(key: key);

  @override
  _TrendsPageState createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    //Provider.of<LiveDataProvider>(context, listen: false).cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of<LiveDataProvider>(context, listen: false)
    //     .checkConeection(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Trend"),
          // ignore: prefer_const_constructors
          bottom: TabBar(
            tabs: const [
              Tab(
                //  icon: Icon(Icons.directions_car),
                text: "Live Trend",
              ),
              Tab(
                //  icon: Icon(Icons.directions_bike),
                text: "Log Data",
              ),
              Tab(
                  //   icon: Icon(Icons.directions_bike),
                  text: "Historic Trend"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [LiveTrend(), LogData(), HistoricTrend()],
        ),
      ),
    );
  }
}
