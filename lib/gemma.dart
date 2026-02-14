import 'dart:async';
import 'package:flutter_gemma/flutter_gemma.dart';
import '../../contract/repositories/i_gemma_repository.dart';
import '../../domain/value_objects/message_content.dart';

class GemmaRepositoryImpl implements IGemmaRepository {
  // セッションオブジェクト（型が公開されていない場合があるためdynamicで保持）
  dynamic _chat;

  // 初期化フラグ
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (!_isInitialized) {
      // 1. エンジンの初期化 (静的メソッド)
      await FlutterGemma.initialize(
        maxDownloadRetries: 3,
      );
      _isInitialized = true;
    }
  }

  @override
  Future<void> installFromAsset(String assetPath, {Function(int)? onProgress}) async {
    // 2. アセットからモデルをインストール (静的メソッドチェーン)
    // ModelType.gemmaIt (Instruction Tuned) を指定
    final installation = await FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
    )
    .fromAsset(assetPath)
    .withProgress((progress) {
      onProgress?.call(progress);
    })
        .install();

    if (installation == null) {
      throw Exception("モデルのインストールに失敗しました");
    }

    // 3. インストール完了後、モデルをロードしてセッションを作成
    await _loadActiveModel();
  }

  /// 内部メソッド: アクティブなモデルをロードしてチャットセッションを開始
  Future<void> _loadActiveModel() async {
    // getActiveModelでモデルインスタンスを取得
    // ※ 0.12.3時点では maxTokens, preferredBackend などが指定可能
    final model = await FlutterGemma.getActiveModel(
      maxTokens: 1024,
      // 必要に応じて preferredBackend: PreferredBackend.gpu などを指定
    );

    // チャットセッションを作成
    _chat = await model.createChat();
  }

  @override
  Future<void> clearSession() async {
    // セッションを再作成して履歴をクリア
    // _chat自体にclearメソッドがないため、作り直すのが確実
    await _loadActiveModel();
  }

  @override
  Stream<String?> generateResponse(MessageContent prompt) async* {
    // セッションがない場合はロードを試みる
    if (_chat == null) {
      await _loadActiveModel();
    }

    // 4. チャット応答の取得
    // 型がdynamicでも addQueryChunk と generateResponseStream は呼び出せます

    // ユーザーメッセージを追加
    await _chat.addQueryChunk(
      Message(text: prompt.value, isUser: true),
    );

    // ストリームを取得してyield
    final Stream<String?> stream = _chat.generateResponseStream();
    await for (final chunk in stream) {
      yield chunk;
    }
  }
}