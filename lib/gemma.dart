
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

final selectModelProvider = StateProvider((ref) => 0);

final executeStateProvider = StateProvider((ref) => false);

class Gemma{

  static InferenceChat? _chat;
  static InferenceModel? _model;

  // static const MAX_TOKEN = 512;
  // static const MAX_TOKEN = 1024;
  static const MAX_TOKEN = 2048;

  /// 初期化
  static Future<void> initialize() async{
    // 必ずconstがついた変数に代入しないと空になる
    const token = String.fromEnvironment('HUGGINGFACE_TOKEN');

    await FlutterGemma.initialize(
      huggingFaceToken: token,
      maxDownloadRetries: 10,
    );
  }

  /// モデルのインストール
  ///
  /// @param WidgetRef ref
  /// @return Future&gt;void&lt;
  static Future<void> installModel(WidgetRef ref) async{
    final logger = ref.watch(loggerProvider.notifier);
    final selectModel = ref.read(selectModelProvider);

    logger.addLog("start install model");
    ref.read(installProgressProvider.notifier).state = 0;

    switch(selectModel){
      case 0:
        await installFromHuggingFace(ref);
        break;

      case 1:
        await installFromAsset(ref);
        break;
    }
  }

  /// HuggingFaceからモデルをインストールする
  ///
  /// @param WidgetRef ref
  static Future<void> installFromHuggingFace(WidgetRef ref) async{
    const token = String.fromEnvironment('HUGGINGFACE_TOKEN');
    final logger = ref.watch(loggerProvider.notifier);
    await FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
    ).fromNetwork(
        'https://huggingface.co/google/gemma-3n-E2B-it-litert-lm/resolve/main/gemma-3n-E2B-it-int4.litertlm',
        token: token
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

  /// アセットからモデルをインストールする
  ///
  /// @param WidgetRef ref
  static Future<void> installFromAsset(WidgetRef ref) async {
    final logger = ref.watch(loggerProvider.notifier);
    await FlutterGemma.installModel(modelType: ModelType.gemmaIt)
    .fromAsset('assets/models/gemma3_mobile.task')
    .withProgress((progress) {
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
      ref.read(installProgressProvider.notifier).state = 100;
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

    var installedModels = await FlutterGemma.listInstalledModels();
    logger.addLog("start uninstall model");
    var modelInstallation = ref.read(modelInstallationProvider.notifier).state;
    logger.addLog('--- models ----');
    var modelId = '';
    for (var element in installedModels) {
      logger.addLog(element);
      var token = element.split('.');
      if(token[0] == modelInstallation!.modelId){
        modelId = element;
      }
    }

    if(modelId == ''){
      logger.addLog("一致するモデルはなし");
      return;
    }

    logger.addLog("削除するモデル:$modelId");

    await FlutterGemma.uninstallModel(modelId)
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
    final executeState = ref.watch(executeStateProvider.notifier);

    if(executeState.state){
      return;
    }

    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    var formatted = formatter.format(DateTime.now());
    logger.clear();
    logger.addLog("Start $formatted");
    executeState.state = true;
    try{
      _model ??= await FlutterGemma.getActiveModel(
            maxTokens: MAX_TOKEN,
            preferredBackend: PreferredBackend.gpu
        );
      _chat ??= await _model?.createChat();
      await _chat?.addQueryChunk(Message.text(text: prompt, isUser: true));
      final response = await _chat?.generateChatResponse();
      if(response is TextResponse){
        logger.addLog('${response.token}');
      }else{
        logger.addLog('?????');
      }
    }catch(e, stackTrace){
      logger.addLog('Error       : $e');
      logger.addLog('Stack Trace : $stackTrace');
    }

    formatted = formatter.format(DateTime.now());
    executeState.state = false;
    logger.addLog("End $formatted");
  }

  /// リセット
  static void reset(){
    FlutterGemma.reset();
  }
}