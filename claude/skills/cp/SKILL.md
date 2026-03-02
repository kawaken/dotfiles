---
allowed-tools: Bash(printf *), Bash(echo *)
---

# clipboard-copy

## Description

指定されたテキストをクリップボードにコピーするスキル

TRIGGER when: user asks to copy text to clipboard (e.g. "コピーして", "クリップボードに入れて", "copy this")

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
