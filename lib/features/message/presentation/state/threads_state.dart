import '../../domain/entities/thread_entity.dart';

class ThreadsState {
  final List<ThreadEntity> threads;
  final bool loading;

  ThreadsState({required this.threads, this.loading = false});

  ThreadsState copyWith({List<ThreadEntity>? threads, bool? loading}) {
    return ThreadsState(
      threads: threads ?? this.threads,
      loading: loading ?? this.loading,
    );
  }
}
