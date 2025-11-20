import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'logger.dart';
import 'gemma.dart';

void main() {
  // Gemmaの初期化
  WidgetsFlutterBinding.ensureInitialized();

  const hugFaceToken = String.fromEnvironment('HUGGINGFACE_TOKEN');

  FlutterGemma.initialize(
    huggingFaceToken: hugFaceToken,
    maxDownloadRetries: 10,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {

  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _logController = TextEditingController(text: "flutter gemma test\nstart");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(installProgressProvider);
    final modelInstallation = ref.watch(modelInstallationProvider);
    final logger = ref.watch(loggerProvider.notifier);
    _logController.text = ref.watch(loggerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Gemma Test'),
      ),
      body: Center(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed:modelInstallation == null ?
                      () => Gemma.installModel(ref) :
                      null,
                  child: Text('Modelのインストール')
                ),
                TextButton(
                  onPressed:modelInstallation == null ?
                    null :
                    () => Gemma.uninstallModel(ref),
                  child: Text('Modelのアンインストール')
                )
              ],
            ),

            //プログレス
            Padding(
              padding: EdgeInsetsGeometry.all(16),
              child: Column(
                children: [
                  Text("${progress * 100.0} %"),
                  LinearProgressIndicator(
                    value: progress
                  ),
              ])
            ),

            Padding(
              padding: EdgeInsetsGeometry.all(16),
              child:
                Column(
                  children: [
                    Text('入力'),
                    TextField(
                      controller: _promptController,
                    )
                  ],
                ),
            ),

            TextButton(onPressed: modelInstallation == null ?
              null :
              () async{
                await Gemma.execute(ref, _promptController.text);
              },
              child: Text('OK')
            ),
            Row(
              children: [
                TextButton(onPressed:() => logger.clear(), child: Text('ログのクリア'))
              ],
            ),
            // ログエリア
            Expanded(
              child:
                Padding(
                    padding: EdgeInsetsGeometry.all(16),
                    child:
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        readOnly: true,
                        controller: _logController,
                      )
                ),
            )
          ],
        ),
      ),
    );
  }
}
