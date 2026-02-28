import '../../domain/usecases/mark_conversation_read.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/message_providers.dart';

final markConversationReadProvider = Provider<MarkConversationRead>((ref) {
  final repo = ref.read(messageRepositoryProvider);
  return MarkConversationRead(repo);
});
