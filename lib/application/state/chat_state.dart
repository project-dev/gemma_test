import '../../domain/entities/chat_message.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isModelLoaded;
  final bool isProcessing;
  final double installProgress;
  final String selectedModelPath;

  ChatState({
    required this.messages,
    required this.isModelLoaded,
    required this.isProcessing,
    required this.installProgress,
    required this.selectedModelPath,
  });

  factory ChatState.initial() => ChatState(
    messages: [],
    isModelLoaded: false,
    isProcessing: false,
    installProgress: 0.0,
    // 修正: assets/models/ から始まるパス
    selectedModelPath: 'assets/models/gemma3-270_default.task',
  );

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isModelLoaded,
    bool? isProcessing,
    double? installProgress,
    String? selectedModelPath,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isModelLoaded: isModelLoaded ?? this.isModelLoaded,
      isProcessing: isProcessing ?? this.isProcessing,
      installProgress: installProgress ?? this.installProgress,
      selectedModelPath: selectedModelPath ?? this.selectedModelPath,
    );
  }
}