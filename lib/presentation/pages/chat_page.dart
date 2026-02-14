import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import '../../application/state/chat_notifier.dart';
import '../../application/state/chat_state.dart';
import '../widgets/chat_bubble.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpodから状態とNotifierを取得
    final state = ref.watch(chatProvider);
    final notifier = ref.read(chatProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF7494C0), // LINE風の背景色
      appBar: AppBar(
        title: const Text(
          "Gemma 3 Clean Arch",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          // 会話クリアボタン
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '会話をクリア',
            onPressed: state.messages.isEmpty ? null : () => notifier.clearChat(),
          ),
          // モデル再選択（アンインストール）ボタン
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: 'モデルを再選択',
            // モデルロード済みの場合のみ有効
            onPressed: state.isModelLoaded
                ? () {
              // 同じパスを再選択させることで、状態を未ロードに戻す（簡易的なリセット）
              // 本格的な実装では notifier.unloadModel() 等を作成して呼ぶのが理想
              notifier.selectModelPath(state.selectedModelPath);
            }
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. モデル選択ドロップダウン
          _buildModelSelector(state, notifier),

          // 2. インストール進捗バー (0%超〜100%未満のとき表示)
          if (state.installProgress > 0.0 && state.installProgress < 1.0)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  LinearProgressIndicator(value: state.installProgress),
                  const SizedBox(height: 4),
                  Text(
                    "インストール中: ${(state.installProgress * 100).toInt()}%",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

          // 3. メインエリア (セットアップ画面 or チャットリスト)
          Expanded(
            child: !state.isModelLoaded
                ? _buildSetupView(notifier, state)
                : _buildChatList(state),
          ),

          // 4. メッセージ送信バー (モデルロード済みのみ表示)
          if (state.isModelLoaded)
            MessageBar(
              onSend: (text) => notifier.send(text),
              sendButtonColor: const Color(0xFF1B97F3),
              messageBarHintText: "メッセージを入力...",
            ),
        ],
      ),
    );
  }

  /// モデル選択UI
  Widget _buildModelSelector(ChatState state, ChatNotifier notifier) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.selectedModelPath,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          // 処理中またはインストール中は変更不可
          onChanged: (state.isProcessing || (state.installProgress > 0 && state.installProgress < 1))
              ? null
              : (val) {
            if (val != null) notifier.selectModelPath(val);
          },
          items: const [
            // アセットパスを assets/models/ に統一
            DropdownMenuItem(
              value: 'assets/models/gemma3-270_default.task',
              child: Text('Standard Model'),
            ),
            DropdownMenuItem(
              value: 'assets/models/gemma3-270_arrows_we2.task',
              child: Text('Arrows WE2 Model'),
            ),
            DropdownMenuItem(
              value: 'assets/models/gemma3-270_pocof6pro.task',
              child: Text('POCO F6 Pro Model'),
            ),
          ],
        ),
      ),
    );
  }

  /// 未ロード時のセットアップ画面
  Widget _buildSetupView(ChatNotifier notifier, ChatState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.smart_toy_outlined, size: 80, color: Colors.white60),
          const SizedBox(height: 16),
          const Text(
            "AIモデルが準備できていません",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            // インストール処理中はボタンを無効化
            onPressed: (state.isProcessing || state.installProgress > 0)
                ? null
                : notifier.loadModel,
            icon: state.isProcessing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
            )
                : const Icon(Icons.download),
            label: Text(
              state.isProcessing ? "準備中..." : "インストールして開始",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  /// チャットメッセージリスト
  Widget _buildChatList(ChatState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: state.messages.length,
      // 自動スクロールのために reverse: true にする場合はデータ順序の反転が必要ですが、
      // ここでは標準的な上から下へのリストとして実装
      itemBuilder: (context, index) {
        return ChatBubble(message: state.messages[index]);
      },
    );
  }
}