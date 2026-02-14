import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'logger.dart';
import 'gemma.dart';

import 'presentation/pages/chat_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 初期化はUI層(Notifier)で制御するため、ここには記述しません。

  runApp(
    const ProviderScope(
      child: MaterialApp(
        title: 'Gemma 3 DDD Chat',
        debugShowCheckedModeBanner: false,
        home: ChatPage(),
      ),
    ),
  );
}

/*
void main() {
  // Gemmaの初期化
  WidgetsFlutterBinding.ensureInitialized();

  Gemma.initialize();

  runApp(const ProviderScope(child: MyApp()));
}
*/
/*
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

    final selectModel = ref.watch(selectModelProvider);
    final selectModelNotifier = ref.watch(selectModelProvider.notifier);
    final executeState = ref.watch(executeStateProvider);

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
            // モデル選択
            DropdownButton(
              items: [
                DropdownMenuItem(
                  value: 0,
                  child: Text('Download Gemma3-270 it'),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('Gemma3-270 it default'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('Gemma3-270 it Arrows We2'),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('Gemma3-270 it POCO F6 Pro'),
                )
              ],
              value: selectModel,
              onChanged: (value) {
                selectModelNotifier.state = value!;
              },
            ),

            // モデルのインストール
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

            // プロンプトの入力
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

            TextButton(onPressed: modelInstallation == null || executeState ?
              null :
              () async{
                await Gemma.execute(ref, _promptController.text);
              },
              child: Text('OK')
            ),

            // ログのクリア
            Row(
              children: [
                TextButton(onPressed:() => executeState ? null : Gemma.reset(), child: Text('チャットのリセット')),
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
*/