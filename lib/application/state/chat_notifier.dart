import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../usecase/chat_usecase.dart';
import '../../infrastructure/repositories/gemma_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/value_objects/message_content.dart';
import 'chat_state.dart';

// DI構成
final chatUseCaseProvider = Provider<ChatUseCase>((ref) {
  return ChatUseCase(GemmaRepositoryImpl());
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.watch(chatUseCaseProvider));
});

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatUseCase _useCase;

  ChatNotifier(this._useCase) : super(ChatState.initial());

  /// アプリ初期化＆モデルインストール
  Future<void> loadModel() async {
    try {
      // 1. エンジン初期化
      await _useCase.initApp();

      state = state.copyWith(isProcessing: true, installProgress: 0.0);

      // 2. モデルインストール（進捗付き）
      await _useCase.setupModel(state.selectedModelPath, (int progressPercent) {
        state = state.copyWith(installProgress: progressPercent / 100.0);
      });

      // 完了
      state = state.copyWith(
        isModelLoaded: true,
        isProcessing: false,
        installProgress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(isProcessing: false, installProgress: 0.0);
      print("Model Load Error: $e");
    }
  }

  /// モデルパスの変更（ドロップダウン選択時）
  void selectModelPath(String path) {
    if (state.selectedModelPath != path) {
      state = state.copyWith(
        selectedModelPath: path,
        isModelLoaded: false,
        installProgress: 0.0,
      );
    }
  }

  /// 会話クリア
  Future<void> clearChat() async {
    await _useCase.resetChat();
    state = state.copyWith(messages: []);
  }

  /// メッセージ送信
  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(content: MessageContent(text), isUser: true);
    final botMsg = ChatMessage(content: const MessageContent("..."), isUser: false);

    // 一旦UIに反映
    state = state.copyWith(
      messages: [...state.messages, userMsg, botMsg],
      isProcessing: true,
    );

    String responseBuffer = "";

    // ストリームの購読
    _useCase.ask(text).listen(
          (chunk) {
        if (chunk != null) {
          responseBuffer += chunk;
          // 最新のメッセージ（botMsg）の中身を更新して再描画
          final updatedMessages = List<ChatMessage>.from(state.messages);
          updatedMessages[updatedMessages.length - 1] = botMsg.copyWith(
            content: MessageContent(responseBuffer),
          );
          state = state.copyWith(messages: updatedMessages);
        }
      },
      onDone: () {
        state = state.copyWith(isProcessing: false);
      },
      onError: (e) {
        state = state.copyWith(isProcessing: false);
        print("Chat Error: $e");
      },
    );
  }
}