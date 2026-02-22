import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/core/api/api_client.dart';
import 'package:sajilo_baas/core/api/api_endpoints.dart';
import '../../data/datasources/remote/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../state/profile_state.dart';
import '../view_model/profile_view_model.dart';

// ApiClient provider
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(baseUrl: ApiEndpoints.baseUrl),
);

// Remote datasource provider
final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>(
  (ref) => ProfileRemoteDatasource(ref.read(apiClientProvider)),
);

// Repository provider
final profileRepositoryProvider = Provider<ProfileRepositoryImpl>(
  (ref) => ProfileRepositoryImpl(ref.read(profileRemoteDatasourceProvider)),
);

// Use case providers
final getProfileUseCaseProvider = Provider<GetProfileUseCase>(
  (ref) => GetProfileUseCase(ref.read(profileRepositoryProvider)),
);

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>(
  (ref) => UpdateProfileUseCase(ref.read(profileRepositoryProvider)),
);

// ViewModel provider
final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>(
      (ref) => ProfileViewModel(
        ref.read(getProfileUseCaseProvider),
        ref.read(updateProfileUseCaseProvider),
      ),
    );
