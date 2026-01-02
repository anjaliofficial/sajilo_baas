import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

// For Hive/Database errors
class LocalFailure extends Failure {
  const LocalFailure({required super.message});
}

// For API/Network errors (if you add Dio later)
class ApiFailure extends Failure {
  final int? statusCode;
  const ApiFailure({required super.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// For General/Unexpected errors
class SharedFailure extends Failure {
  const SharedFailure({required super.message});
}
