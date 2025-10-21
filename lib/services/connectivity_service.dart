import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum ConnectivityStatus {
  online,
  offline,
}

class ConnectivityService with ChangeNotifier {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  ConnectivityStatus _status = ConnectivityStatus.online;

  ConnectivityStatus get status => _status;

  ConnectivityService() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      _setStatus(ConnectivityStatus.offline);
    } else {
      _setStatus(ConnectivityStatus.online);
    }
  }

  void _setStatus(ConnectivityStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
