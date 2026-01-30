import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sajilo_baas/core/api/api_client.dart';
import '../../data/datasources/remote/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/profile_usecase.dart';
import '../state/profile_state.dart';
import '../view_model/profile_view_model.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>(
  (ref) => ProfileRemoteDatasource(ref.read(apiClientProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepositoryImpl>(
  (ref) => ProfileRepositoryImpl(ref.read(profileRemoteDatasourceProvider)),
);

final getProfileUseCaseProvider = Provider<GetProfileUseCase>(
  (ref) => GetProfileUseCase(ref.read(profileRepositoryProvider)),
);

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>(
      (ref) => ProfileViewModel(ref.read(getProfileUseCaseProvider)),
    );
