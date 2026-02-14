# flutter_gemmaのお試し

スマホでローカルLLMを動かしたくて、なんならプログラム組んで動かしたいなと思ったのでやってみいました。
Androidでのみ動作を確認しています。
gemma-3n-E2B-it-litert-lm をダウンロードして使用します。

| 機種          | 状況     |
|-------------|--------|
| POCO F6 Pro | 動作しました |
| ROG Phone   | 落ちました  |
| Arrows We2  | 落ちました  |

お試しなのとReverpodの使い方がいまいちなのは目を瞑ってください。

# 注意点

## config.json
ルートにconfig.jsonを以下の形式で作成してください。
```json
{
  "HUGGINGFACE_TOKEN": "hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
```

## 実行時のオプション
実行時に --dart-define-from-file=config.json オプションをつけてください。

```agsl
flutter run --dart-define-from-file=config.json
```
