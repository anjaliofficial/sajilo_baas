import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/core/services/connectivity/inetwork_info.dart';

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(connectivity: Connectivity());
});

class NetworkInfo implements INetworkInfo {
  final Connectivity connectivity;

  NetworkInfo({required this.connectivity});

  /// Check if device is currently connected
  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    final status = (result.isNotEmpty ? result.first : ConnectivityResult.none);
    return status != ConnectivityResult.none;
  }

  /// Stream to listen for connectivity changes
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((result) {
      final status = (result.isNotEmpty
          ? result.first
          : ConnectivityResult.none);
      return status != ConnectivityResult.none;
    });
  }
}
