import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkBloc extends Cubit<NetworkState> {
  static final NetworkBloc _instance = NetworkBloc._internal();
  final Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _wasDisconnected = false;
  bool _hasShownDisconnectedToast = true;

  factory NetworkBloc({required Connectivity connectivity}) => _instance;

  NetworkBloc._internal({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(NetworkState.connected()) {
    _monitorInternet();
  }

  void _monitorInternet() async {
    // Check initial connectivity state
    final initialResult = await _connectivity.checkConnectivity();
    _handleConnectivityChange(initialResult);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      _handleDisconnection();
    } else {
      _handleConnection();
    }
  }

  void _handleDisconnection() {
    _wasDisconnected = true;
    emit(NetworkState.disconnected());

    // Show toast only once per disconnection event
    if (!_hasShownDisconnectedToast) {
      _hasShownDisconnectedToast = true;
    }
  }

  void _handleConnection() async {
    if (_wasDisconnected) {
      emit(NetworkState.restored());
      _wasDisconnected = false;
      _hasShownDisconnectedToast = false;
    } else {
      emit(NetworkState.connected());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }

  // Optional: Reset singleton for testing
  static void reset() {
    _instance._connectivitySubscription.cancel();
    // Recreate the instance
    NetworkBloc._internal();
  }
}

class NetworkState {
  final bool isConnected;
  final bool isRestored;

  NetworkState.connected() : isConnected = true, isRestored = false;

  NetworkState.disconnected() : isConnected = false, isRestored = false;

  NetworkState.restored() : isConnected = true, isRestored = true;
}
