import '../../domain/value_objects/message_content.dart';

abstract class IGemmaRepository {
  /// アプリ全体の初期化（エンジン起動）
  Future<void> initialize();

  /// アセットからモデルをインストール
  /// [assetPath]: アセットのパス
  /// [onProgress]: 進捗率(0~100)を受け取るコールバック
  Future<void> installFromAsset(String assetPath, {Function(int)? onProgress});

  /// 会話履歴のクリア（セッションリセット）
  Future<void> clearSession();

  /// プロンプトを投げて応答ストリームを取得
  Stream<String?> generateResponse(MessageContent prompt);
}