import '../../domain/entities/thread_entity.dart';
import '../../domain/repositories/message_repository.dart';

/// UseCase to fetch all threads / conversations
class GetThreads {
  final MessageRepository repository;

  GetThreads(this.repository);

  /// Returns a list of threads for the current user
  Future<List<ThreadEntity>> call() async {
    return await repository.getThreads();
  }
}
