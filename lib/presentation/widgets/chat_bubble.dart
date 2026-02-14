import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import '../../domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: BubbleSpecialThree(
        text: message.content.value,
        isSender: message.isUser,
        color: message.isUser ? const Color(0xFF1B97F3) : const Color(0xFFE8E8EE),
        tail: true,
        textStyle: TextStyle(
          color: message.isUser ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }
}