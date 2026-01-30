// features/profile/presentation/view_model/profile_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/profile_state.dart';
import '../../domain/usecases/profile_usecase.dart';

class ProfileViewModel extends Notifier<ProfileState> {
  final GetProfileUseCase getProfileUseCase;

  ProfileViewModel(this.getProfileUseCase);

  @override
  ProfileState build() => const ProfileState.initial();

  Future<void> fetchProfile() async {
    state = const ProfileState.loading();

    final result = await getProfileUseCase();

    result.fold(
      (failure) => state = ProfileState.error(failure.message),
      (profile) => state = ProfileState.loaded(profile),
    );
  }
}
