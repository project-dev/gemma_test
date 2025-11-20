
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'logger.dart';

// Provider
final installProgressProvider = StateProvider((ref) => 0.0);

// InferenceInstallation
final modelInstallationProvider = StateProvider<InferenceInstallation?>((ref) {
  return null; // 初期値
});

class Gemma{
  static const _hugFaceToken = String.fromEnvironment('HUGGINGFACE_TOKEN');

  /// モデルのインストール
  ///
  /// @param WidgetRef ref
  /// @return Future&gt;void&lt;
  static Future<void> installModel(WidgetRef ref) async{
    final logger = ref.watch(loggerProvider.notifier);
    logger.addLog("start install model");
    ref.read(installProgressProvider.notifier).state = 0;

    await FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
    ).fromNetwork(
        'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/gemma-3n-E2B-it-int4.litertlm',
//        token: _hugFaceToken
    ).withProgress((progress) {
      ref.read(installProgressProvider.notifier).state = progress / 100;
    })
    .install()
    .then((value) {
      ref.read(modelInstallationProvider.notifier).state = value;
      logger.addLog("model : ${value.modelId}");
    },onError:(error, stackTrace) {
      logger.addLog("ERROR : $error");
    })
    .whenComplete(() {
      var modelInstallation = ref.read(modelInstallationProvider.notifier).state;
      logger.addLog("finish install model");
      if(modelInstallation != null){
        logger.addLog("OK");
      }else{
        logger.addLog("NG");
      }
    });
  }

  /// モデルのアンインストール
  ///
  /// @param WidgetRef ref
  /// @return Future&gt;void&lt;
  static Future<void> uninstallModel(WidgetRef ref) async{
    final logger = ref.watch(loggerProvider.notifier);

    logger.addLog("start uninstall model");
    var modelInstallation = ref.read(modelInstallationProvider.notifier).state;

    await FlutterGemma.uninstallModel(modelInstallation!.modelId)
        .then((value) {
      logger.addLog("finish uninstall model");
      ref.read(modelInstallationProvider.notifier).state = null;
    },onError: (error, stackTrace) {
      logger.addLog("ERROR : $error");
    });
  }

  /// 会話を実行
  ///
  /// @param WidgetRef ref
  /// @param String prompt
  /// @return Future&gt;void&lt;
  static Future<void> execute(WidgetRef ref, String prompt) async{
    final logger = ref.watch(loggerProvider.notifier);
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    var formatted = formatter.format(DateTime.now());

    logger.addLog("Start $formatted");
    final model = await FlutterGemma.getActiveModel(
      maxTokens: 2048,
      preferredBackend: PreferredBackend.gpu
    );
    final chat = await model.createChat();
    await chat.addQueryChunk(Message.text(text: prompt, isUser: true));
    final response = await chat.generateChatResponse();
    if(response is TextResponse){
      logger.addLog(response.token);
    }else{
      logger.addLog('?????');
    }

    formatted = formatter.format(DateTime.now());
    logger.addLog("End $formatted");
  }


}