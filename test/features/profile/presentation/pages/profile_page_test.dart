import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/profile/presentation/pages/profile_page.dart';
import 'package:sajilo_baas/core/providers/shared_pref_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilo_baas/features/profile/presentation/providers/profile_provider.dart';
import 'package:sajilo_baas/features/profile/presentation/state/profile_state.dart';
import 'package:sajilo_baas/features/profile/domain/entities/profile_entity.dart';
import 'package:sajilo_baas/features/auth/presentation/providers/auth_provider.dart';
import 'package:sajilo_baas/features/auth/presentation/state/auth_state.dart';
import 'package:sajilo_baas/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/features/profile/domain/usecases/profile_usecase.dart';
import 'package:sajilo_baas/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:sajilo_baas/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sajilo_baas/core/error/failure.dart';
import 'package:sajilo_baas/features/profile/domain/repositories/i_profile_repository.dart';

class FakeSharedPreferences implements SharedPreferences {
  final Map<String, Object> _storage = {};
  @override
  bool containsKey(String key) => _storage.containsKey(key);
  @override
  Object? get(String key) => _storage[key];
  @override
  bool? getBool(String key) => _storage[key] as bool?;
  @override
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final testProfile = ProfileEntity(
  id: '1',
  fullName: 'Test User',
  email: 'test@example.com',
  phoneNumber: '1234567890',
  address: 'Test Address',
  role: 'user',
  profilePicture: null,
);

class DummyProfileRepository implements IProfileRepository {
  @override
  Future<Either<Failure, ProfileEntity>> getCurrentUser() async {
    return Right(testProfile);
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(
    ProfileEntity entity,
  ) async {
    return Right(entity);
  }
}

class DummyGetProfileUseCase extends GetProfileUseCase {
  DummyGetProfileUseCase() : super(DummyProfileRepository());
  @override
  Future<Either<Failure, ProfileEntity>> call() async {
    return Right(testProfile);
  }
}

class DummyUpdateProfileUseCase extends UpdateProfileUseCase {
  DummyUpdateProfileUseCase() : super(DummyProfileRepository());
  @override
  Future<Either<Failure, ProfileEntity>> call(ProfileEntity entity) async {
    return Right(entity);
  }
}

class MockProfileViewModel extends ProfileViewModel {
  MockProfileViewModel()
    : super(DummyGetProfileUseCase(), DummyUpdateProfileUseCase()) {
    state = ProfileState.loaded(testProfile);
  }
  @override
  Future<void> fetchProfile() async {
    state = ProfileState.loaded(testProfile);
  }
}

class MockAuthViewModel extends AuthViewModel {
  MockAuthViewModel() : super(null) {
    state = const AuthState(status: AuthStatus.authenticated);
  }
}

void main() {
  final fakePrefs = FakeSharedPreferences();

  testWidgets('Profile page renders avatar', (WidgetTester tester) async {
    await tester.pumpWidget(Container()); // Riverpod binding workaround
    await tester.pump();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(fakePrefs),
          profileViewModelProvider.overrideWith(
            (ref) => MockProfileViewModel(),
          ),
          authViewModelProvider.overrideWith(MockAuthViewModel.new),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('Edit icon button is present', (WidgetTester tester) async {
    await tester.pumpWidget(Container()); // Riverpod binding workaround
    await tester.pump();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(fakePrefs),
          profileViewModelProvider.overrideWith(
            (ref) => MockProfileViewModel(),
          ),
          authViewModelProvider.overrideWith(MockAuthViewModel.new),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    expect(find.byIcon(Icons.edit), findsOneWidget);
  });
}
