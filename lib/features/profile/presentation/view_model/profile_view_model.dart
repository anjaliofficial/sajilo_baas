import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../state/profile_state.dart';
import '../../domain/usecases/profile_usecase.dart';

class ProfileViewModel extends StateNotifier<ProfileState> {
  final GetProfileUseCase getProfileUseCase;

  ProfileViewModel(this.getProfileUseCase) : super(ProfileState.initial());

  Future<void> fetchProfile() async {
    state = ProfileState.loading();

    final result = await getProfileUseCase();

    result.fold(
      (failure) => state = ProfileState.error(failure.message),
      (profile) => state = ProfileState.loaded(profile),
    );
  }
}
