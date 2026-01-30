// features/profile/presentation/providers/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/profile_view_model.dart';
import '../state/profile_state.dart';
import '../../domain/usecases/profile_usecase.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/datasources/remote/profile_remote_datasource.dart';
import 'package:sajilo_baas/core/api/api_client.dart';

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(() {
      final apiClient = ApiClient();
      final datasource = ProfileRemoteDatasource(apiClient);
      final repository = ProfileRepositoryImpl(datasource);
      final usecase = GetProfileUseCase(repository);

      return ProfileViewModel(usecase);
    });
