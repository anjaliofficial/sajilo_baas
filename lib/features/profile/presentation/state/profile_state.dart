// features/profile/presentation/state/profile_state.dart
import '../../domain/entities/profile_entity.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState {
  final ProfileStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  const ProfileState.initial() : this(status: ProfileStatus.initial);
  const ProfileState.loading() : this(status: ProfileStatus.loading);
  const ProfileState.loaded(ProfileEntity profile)
    : this(status: ProfileStatus.loaded, profile: profile);
  const ProfileState.error(String message)
    : this(status: ProfileStatus.error, errorMessage: message);
}
