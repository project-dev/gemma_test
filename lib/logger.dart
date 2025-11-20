
// 1. Notifierを継承。型は管理したい状態の型（ここではString）を指定
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoggerNotifier extends Notifier<String> {
  @override
  String build() {
    return ""; // 初期値 (_logText = "" に相当)
  }

  /// ログ追加
  ///
  /// @param String log
  void addLog(String log) {
    // state は現在の値です。
    // 新しい文字列を作成して state に代入すると、UIが更新されます。
    state = "$state\n$log";
  }

  /// ログのクリア
  void clear() {
    state = "";
  }
}

// 2. Providerの手動定義
// <Notifierのクラス名, 管理する状態の型>
final loggerProvider = NotifierProvider<LoggerNotifier, String>(() {
  return LoggerNotifier();
});