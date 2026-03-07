import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sajilo_baas/features/auth/presentation/pages/login_page.dart';
import 'package:sajilo_baas/core/providers/shared_pref_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake SharedPreferences for testing
class FakeSharedPreferences implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<bool> commit() async => true;

  @override
  bool containsKey(String key) => _data.containsKey(key);

  @override
  Object? get(String key) => _data[key];

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  double? getDouble(String key) => _data[key] as double?;

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  Set<String> getKeys() => _data.keys.toSet();

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  List<String>? getStringList(String key) => _data[key] as List<String>?;

  @override
  Future<void> reload() async {}

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }
}

void main() {
  group('Auth Screen Widget Tests', () {
    final fakePrefs = FakeSharedPreferences();

    final overrides = [sharedPreferencesProvider.overrideWithValue(fakePrefs)];

    testWidgets('Email field present', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      expect(find.byKey(const Key('emailField')), findsOneWidget);
    });

    testWidgets('Password field present', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      expect(find.byKey(const Key('passwordField')), findsOneWidget);
    });

    testWidgets('Login/Register button present', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      expect(find.byKey(const Key('loginButton')), findsOneWidget);
    });

    testWidgets('Enter email works', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('emailField')),
        'test@example.com',
      );

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Enter password works', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );

      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('Login/Register button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();

      // Add expectations like navigation or loading
    });
  });
}
