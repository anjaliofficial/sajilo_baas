import '../entities/onboard_entity.dart';
import '../repositories/onboard_repository.dart';

class GetOnboardContents {
  final OnboardRepository repository;

  GetOnboardContents(this.repository);

  List<OnboardEntity> call() {
    return repository.getOnboardingContents();
  }
}
