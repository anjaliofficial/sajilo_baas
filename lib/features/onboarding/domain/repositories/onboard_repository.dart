import '../entities/onboard_entity.dart';

abstract class OnboardRepository {
  List<OnboardEntity> getOnboardingContents();
}
