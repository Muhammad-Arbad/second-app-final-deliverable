


import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';



class CheckConnection{

  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  bool isConnected = false;


  bool isNetworkConnected(){
    _networkConnectivity.initialise();
    _networkConnectivity.myStream.listen((source) {
      _source = source;
      // print('source $_source');
      // 1.
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          // widget.conivicityString =
          // _source.values.toList()[0] ? GlobalItems().connectedString : GlobalItems().notConnectedString;
          _source.values.toList()[0] ? isConnected= true : isConnected= false;
          break;
        case ConnectivityResult.wifi:
          // widget.conivicityString =
          // _source.values.toList()[0] ? GlobalItems().connectedString : GlobalItems().notConnectedString;
          _source.values.toList()[0] ? isConnected= true : isConnected= false;
          break;
        case ConnectivityResult.none:
        default:
        isConnected= false;
      }

    });

    print("Inside connection class");
    print(isConnected);

    return isConnected;
  }
}





class NetworkConnectivity {
  NetworkConnectivity._();
  static final _instance = NetworkConnectivity._();
  static NetworkConnectivity get instance => _instance;
  final _networkConnectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;
  void initialise() async {
    ConnectivityResult result = await _networkConnectivity.checkConnectivity();
    _checkStatus(result);
    _networkConnectivity.onConnectivityChanged.listen((result) {
      // print(result);
      _checkStatus(result);
    });
  }
  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }
  void disposeStream() => _controller.close();
}