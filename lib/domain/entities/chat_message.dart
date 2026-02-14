import 'package:uuid/uuid.dart';
import '../value_objects/message_content.dart';

class ChatMessage {
  final String id;
  final MessageContent content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    String? id,
    required this.content,
    required this.isUser,
  })  : id = id ?? const Uuid().v4(),
        timestamp = DateTime.now();

  ChatMessage copyWith({MessageContent? content}) {
    return ChatMessage(
      id: id,
      content: content ?? this.content,
      isUser: isUser,
      // timestampは更新しない
    );
  }
}