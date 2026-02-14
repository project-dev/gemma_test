import 'package:flutter/foundation.dart';

@immutable
class MessageContent {
  final String value;
  const MessageContent(this.value);

  // 空文字は許容しないバリデーション
  bool get isValid => value.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MessageContent && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}