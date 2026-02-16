---
allowed-tools: Bash(printf *), Bash(echo *)
---

# clipboard-copy

## Description

指定されたテキストをクリップボードにコピーするスキル

## User Invocable

yes

## Arguments

- text: コピーするテキスト

## Instructions

macOS の pbcopy コマンドを使用してテキストをクリップボードにコピーする。

**禁止: heredoc (`<<EOF`)、cat は絶対に使わないこと。**

以下のように `printf` でパイプする:

```bash
printf '%s' "テキスト" | pbcopy
```

コピー完了後、「クリップボードにコピーしたで！」とユーザーに伝える。
