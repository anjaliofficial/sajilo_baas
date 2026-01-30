// profile/presentation/state/profile_state.dart
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

  // Named constructors for convenience
  const ProfileState.initial() : this(status: ProfileStatus.initial);

  const ProfileState.loading() : this(status: ProfileStatus.loading);

  const ProfileState.loaded(ProfileEntity profile)
    : this(status: ProfileStatus.loaded, profile: profile);

  const ProfileState.error(String message)
    : this(status: ProfileStatus.error, errorMessage: message);

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
