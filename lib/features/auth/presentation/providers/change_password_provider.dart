import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/change_password_view_model.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../data/repositories/change_password_repository_impl.dart';
import '../../data/datasources/remote/change_password_remote_datasource.dart';
import '../../../../core/api/api_client.dart';

final changePasswordProvider =
    StateNotifierProvider<ChangePasswordViewModel, bool>((ref) {
      final apiClient = ref.read(apiClientProvider);
      final datasource = ChangePasswordRemoteDatasource(apiClient);
      final repository = ChangePasswordRepositoryImpl(datasource);
      final useCase = ChangePasswordUseCase(repository);
      return ChangePasswordViewModel(useCase);
    });
