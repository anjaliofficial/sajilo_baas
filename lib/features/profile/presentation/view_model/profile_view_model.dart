import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/profile_state.dart';
import '../../domain/usecases/profile_usecase.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/update_profile_usecase.dart';

class ProfileViewModel extends StateNotifier<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileViewModel(this.getProfileUseCase, this.updateProfileUseCase)
    : super(ProfileState.initial());

  Future<void> fetchProfile() async {
    state = ProfileState.loading();
    final result = await getProfileUseCase();
    result.fold(
      (failure) => state = ProfileState.error(failure.message),
      (profile) => state = ProfileState.loaded(profile),
    );
  }

  Future<void> updateProfile(ProfileEntity entity) async {
    state = ProfileState.loading();
    final result = await updateProfileUseCase(entity);
    result.fold(
      (failure) => state = ProfileState.error(failure.message),
      (profile) => state = ProfileState.loaded(profile),
    );
  }
}
