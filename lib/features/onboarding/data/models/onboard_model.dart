import '../../domain/entities/onboard_entity.dart';

class OnboardModel extends OnboardEntity {
  const OnboardModel({required super.title, required super.description});

  factory OnboardModel.fromJson(Map<String, dynamic> json) {
    return OnboardModel(title: json['title'], description: json['description']);
  }
}
