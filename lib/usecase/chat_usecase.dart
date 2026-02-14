import '../contract/repositories/i_gemma_repository.dart';
import '../domain/value_objects/message_content.dart';

class ChatUseCase {
  final IGemmaRepository _repository;
  ChatUseCase(this._repository);

  /// アプリ初期化
  Future<void> initApp() => _repository.initialize();

  /// モデルセットアップ（進捗通知あり）
  Future<void> setupModel(String path, Function(int) onProgress) =>
      _repository.installFromAsset(path, onProgress: onProgress);

  /// 会話リセット
  Future<void> resetChat() => _repository.clearSession();

  /// 対話実行
  Stream<String?> ask(String text) {
    final content = MessageContent(text);
    if (!content.isValid) return const Stream.empty();
    return _repository.generateResponse(content);
  }
}