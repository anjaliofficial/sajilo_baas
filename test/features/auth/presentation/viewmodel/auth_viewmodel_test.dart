import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sajilo_baas/features/auth/domain/repositories/auth_repository.dart';
import 'package:sajilo_baas/features/auth/presentation/providers/auth_provider.dart';
import 'package:sajilo_baas/features/auth/domain/usecases/login_usecase.dart';
import 'package:sajilo_baas/features/auth/domain/usecases/register_usecase.dart';
import 'package:sajilo_baas/features/auth/presentation/state/auth_state.dart';
import 'package:sajilo_baas/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:sajilo_baas/core/error/failure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_baas/features/auth/presentation/view_model/auth_view_model.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockApiClient {
  Future<void> saveToken(String token) async {}
  Future<void> removeToken() async {}
  Future<String?> readToken() async => 'mock_token';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late MockAuthRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(
      AuthEntity(
        authId: '',
        fullName: '',
        email: '',
        phoneNumber: '',
        address: '',
        password: '',
        role: '',
        token: '',
      ),
    );
  });

  setUp(() {
    mockRepo = MockAuthRepository();
    when(() => mockRepo.login(any(), any())).thenAnswer((invocation) async {
      final email = invocation.positionalArguments[0] as String;
      final password = invocation.positionalArguments[1] as String;
      if (email == 'ram@test.com' && password == 'wrong') {
        return Left(ApiFailure(message: 'Invalid credentials'));
      }
      return Left(ApiFailure(message: 'Mocked'));
    });
    when(
      () => mockRepo.register(
        any(),
        confirmPassword: any(named: 'confirmPassword'),
      ),
    ).thenAnswer((invocation) async {
      final entity = invocation.positionalArguments[0] as AuthEntity;
      final confirmPassword =
          invocation.namedArguments[const Symbol('confirmPassword')] as String?;
      if (entity.email == 'ram@test.com' && confirmPassword == '123456') {
        return const Right(true);
      }
      return Left(ApiFailure(message: 'Registration failed'));
    });
    when(() => mockRepo.logout()).thenAnswer((_) async => const Right(true));
    when(
      () => mockRepo.checkSession(),
    ).thenAnswer((_) async => const Right(null));

    final profileProvider = Provider((ref) => null);
    final apiClientProviderOverride = Provider((ref) => MockApiClient());
    container = ProviderContainer(
      overrides: [
        authViewModelProvider.overrideWith(
          () => AuthViewModel(mockRepo, false),
        ),
        profileProvider,
        apiClientProviderOverride,
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthViewModel Tests', () {
    test('should emit loading and success state on login', () async {
      final params = LoginParams(email: 'ram@test.com', password: '123456');
      final authEntity = AuthEntity(
        authId: '1',
        fullName: 'Ram',
        email: 'ram@test.com',
        phoneNumber: '9800000000',
        address: 'Kathmandu',
        password: '123456',
        role: 'user',
        token: 'token123',
      );
      when(
        () => mockRepo.login(params.email, params.password),
      ).thenAnswer((_) async => Right(authEntity));

      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.login(email: params.email, password: params.password);
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.authEntity, authEntity);
    });

    test('should emit loading and error state on login failure', () async {
      final params = LoginParams(email: 'ram@test.com', password: 'wrong');
      final failure = ApiFailure(message: 'Invalid credentials');
      when(
        () => mockRepo.login(params.email, params.password),
      ).thenAnswer((_) async => Left(failure));

      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.login(email: params.email, password: params.password);
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Invalid credentials');
    });
  });
}
