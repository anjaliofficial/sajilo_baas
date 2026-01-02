import '../../domain/entities/onboard_entity.dart';
import '../../domain/repositories/onboard_repository.dart';
import '../datasources/onboard_local_datasource.dart';

class OnboardRepositoryImpl implements OnboardRepository {
  final OnboardLocalDataSource localDataSource;

  OnboardRepositoryImpl(this.localDataSource);

  @override
  List<OnboardEntity> getOnboardingContents() {
    return localDataSource.getContents();
  }
}
