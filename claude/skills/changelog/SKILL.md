---
allowed-tools: WebFetch
---

# Claude Code Changelog

## Description

Claude Codeの最近のアップデート内容を確認する。

TRIGGER when: user invokes `/changelog`, "最近のアップデート", "更新内容", "何が変わった"

## User Invocable

yes

## Instructions

1. WebFetchで `https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md` を取得する
   - 失敗した場合は「ネットワークに接続できへんから、手動で確認してな」と伝えて終了
2. 直近10バージョン分（`## x.y.z` のH2ヘッダ単位）のエントリを抽出する
3. 以下のフォーマットで日本語サマリーを提示する:

```
**Claude Code 最近のアップデート**

直近10バージョン（{最新バージョン} 〜 {10件目のバージョン}）の主な変更:

- [重要な変更を日本語で要約したもの]
- ...

詳細を見たい？
```

4. ユーザーが詳細を希望した場合、バージョンごとの変更内容を原文のまま新しい順に表示する

## 注意事項

- サマリーは全変更の羅列ではなく、重要・注目すべき変更をピックアップして日本語でまとめること
- CHANGELOGのフォーマットは `## x.y.z` のH2ヘッダ + 箇条書き（日付なし）
