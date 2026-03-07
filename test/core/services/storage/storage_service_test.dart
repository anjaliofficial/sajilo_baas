import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilo_baas/core/services/storage/storage_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
	late MockSharedPreferences mockPrefs;
	late StorageService storageService;

	setUp(() {
		mockPrefs = MockSharedPreferences();
		storageService = StorageService(mockPrefs);
	});

	test('setString and getString', () async {
		when(() => mockPrefs.setString('key', 'value')).thenAnswer((_) async => true);
		when(() => mockPrefs.getString('key')).thenReturn('value');
		await storageService.setString('key', 'value');
		expect(storageService.getString('key'), 'value');
		verify(() => mockPrefs.setString('key', 'value')).called(1);
		verify(() => mockPrefs.getString('key')).called(1);
	});

	test('setBool and getBool', () async {
		when(() => mockPrefs.setBool('flag', true)).thenAnswer((_) async => true);
		when(() => mockPrefs.getBool('flag')).thenReturn(true);
		await storageService.setBool('flag', true);
		expect(storageService.getBool('flag'), true);
		verify(() => mockPrefs.setBool('flag', true)).called(1);
		verify(() => mockPrefs.getBool('flag')).called(1);
	});

	test('remove', () async {
		when(() => mockPrefs.remove('key')).thenAnswer((_) async => true);
		await storageService.remove('key');
		verify(() => mockPrefs.remove('key')).called(1);
	});

	test('clear', () async {
		when(() => mockPrefs.clear()).thenAnswer((_) async => true);
		await storageService.clear();
		verify(() => mockPrefs.clear()).called(1);
	});
}
