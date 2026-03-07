import 'package:sajilo_baas/core/services/connectivity/inetwork_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sajilo_baas/core/services/connectivity/network_info.dart';
import 'dart:async';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late NetworkInfo networkInfo;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfo(connectivity: mockConnectivity);
  });

  group('NetworkInfo', () {
    group('isConnected', () {
      test('returns true for WiFi', () async {
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) => Future.value([ConnectivityResult.wifi]));
        final result = await networkInfo.isConnected;
        expect(result, true);
      });

      test('returns true for mobile', () async {
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) => Future.value([ConnectivityResult.mobile]));
        final result = await networkInfo.isConnected;
        expect(result, true);
      });

      test('returns true for ethernet', () async {
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) => Future.value([ConnectivityResult.ethernet]));
        final result = await networkInfo.isConnected;
        expect(result, true);
      });

      test('returns false for none', () async {
        when(
          () => mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) => Future.value([ConnectivityResult.none]));
        final result = await networkInfo.isConnected;
        expect(result, false);
      });
    });

    test('implements INetworkInfo', () {
      expect(networkInfo, isA<INetworkInfo>());
    });

    test('onConnectivityChanged emits correct values', () async {
      final controller = StreamController<List<ConnectivityResult>>();
      when(
        () => mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => controller.stream);
      final results = <bool>[];
      networkInfo.onConnectivityChanged.listen(results.add);
      controller.add([ConnectivityResult.wifi]);
      controller.add([ConnectivityResult.none]);
      await Future.delayed(Duration.zero);
      expect(results, [true, false]);
      await controller.close();

      // List value stream
      final controllerList = StreamController<List<ConnectivityResult>>();
      when(
        () => mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => controllerList.stream);
      final resultsList = <bool>[];
      networkInfo.onConnectivityChanged.listen(resultsList.add);
      controllerList.add([ConnectivityResult.wifi]);
      controllerList.add([ConnectivityResult.none]);
      await Future.delayed(Duration.zero);
      expect(resultsList, [true, false]);
      await controllerList.close();
    });
  });
}
