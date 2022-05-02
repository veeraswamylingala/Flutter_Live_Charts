import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckConnectivity extends ChangeNotifier {
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity(BuildContext context) async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) {
    //   return Future.value(null);
    // }
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((val) {
      _updateConnectionStatus(val, context);
    });
    return _updateConnectionStatus(result, context);
  }

  Future<void> _updateConnectionStatus(
      ConnectivityResult result, BuildContext context) async {
    print(result);
    connectionStatus = result;
    if (connectionStatus == ConnectivityResult.none) {
      // showAlert(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text("No Internet Connection")));
      ScaffoldMessenger.of(context)
        ..removeCurrentMaterialBanner()
        ..showMaterialBanner(_showMaterialBanner(context));
      notifyListeners();
    } else {
      ScaffoldMessenger.of(context)..removeCurrentMaterialBanner();
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text("No Internet Connection")));
      notifyListeners();
    }
  }

  MaterialBanner _showMaterialBanner(BuildContext context) {
    return MaterialBanner(
        content: Text('No Internet Connection'),
        leading: Icon(Icons.error),
        padding: EdgeInsets.all(15),
        backgroundColor: Colors.lightGreenAccent,
        contentTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
        actions: [
          SizedBox()
          // TextButton(
          //   onPressed: () {
          //     initConnectivity(context);
          //   },
          //   child: Text(
          //     'Try again',
          //     style: TextStyle(color: Colors.purple),
          //   ),
          // ),
          // TextButton(
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          //   },
          //   child: Text(
          //     'Cancel',
          //     style: TextStyle(color: Colors.purple),
          //   ),
          //  ),
        ]);
  }

  void showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text("Server ERROR 505"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK"))
              ],
            ));
  }
}
