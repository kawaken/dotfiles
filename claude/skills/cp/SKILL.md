# clipboard-copy

## Description

指定されたテキストをクリップボードにコピーするスキル

## User Invocable

yes

## Arguments

- text: コピーするテキスト

## Instructions

macOS の pbcopy コマンドを使用してテキストをクリップボードにコピーする。

1. 引数で渡されたテキストを一時ファイルに書き出す
2. pbcopy コマンドでクリップボードにコピー
3. 一時ファイルを削除
4. コピー完了をユーザーに通知

```bash
echo -n "$text" | pbcopy
```

コピー完了後、「クリップボードにコピーしたで！」とユーザーに伝える。
