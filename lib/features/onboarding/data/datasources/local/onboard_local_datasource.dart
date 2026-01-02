import '../models/onboard_model.dart';

abstract class OnboardLocalDataSource {
  List<OnboardModel> getContents();
}

class OnboardLocalDataSourceImpl implements OnboardLocalDataSource {
  @override
  List<OnboardModel> getContents() {
    return const [
      OnboardModel(
        title: "Find Your Perfect Home",
        description:
            "Browse thousands of verified listings tailored to your preferences and budget.",
      ),
      OnboardModel(
        title: "Secure & Easy Booking",
        description:
            "Book viewings and secure your dream property with our seamless platform.",
      ),
      OnboardModel(
        title: "Expert Advice & Support",
        description:
            "Get help from experienced real estate professionals 24/7.",
      ),
    ];
  }
}
