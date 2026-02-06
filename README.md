# flutter_gemmaのお試し

スマホでローカルLLMを動かしたくて、なんならプログラム組んで動かしたいなと思ったのでやってみいました。
Androidでのみ動作を確認しています。
gemma-3n-E2B-it-litert-lm をダウンロードして使用します。
メモリが充分にある機種で動かすことができます。
(Arrows We2で試しに動かしたら落ちました)

# 注意点

## config.json
onfig.jsonを以下の形式で作成してください。
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
