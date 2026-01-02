import 'package:flutter/material.dart';
import '../../domain/entities/onboard_entity.dart';
import '../../domain/usecases/get_onboard_contents.dart';

class OnboardingViewModel extends ChangeNotifier {
  final GetOnboardContents getOnboardContents;

  OnboardingViewModel(this.getOnboardContents);

  int currentPage = 0;

  List<OnboardEntity> get contents => getOnboardContents();

  void setPage(int index) {
    currentPage = index;
    notifyListeners();
  }
}
