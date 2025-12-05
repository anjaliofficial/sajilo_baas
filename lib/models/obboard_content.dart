class OnboardContent {
  final String title;
  final String description;

  OnboardContent({required this.title, required this.description});
}

// Data for 3 separate onboarding pages
List<OnboardContent> contents = [
  OnboardContent(
    title: 'Explore Properties Easily',
    description:
        'Find your dream home or next rental with our intuitive search filters and map view.',
  ),
  OnboardContent(
    title: 'Instant Property Alerts',
    description:
        'Get notified immediately when new properties matching your criteria hit the market.',
  ),
  OnboardContent(
    title: 'Connect with Agents',
    description:
        'Directly chat and schedule viewings with verified real estate agents instantly.',
  ),
];
