---
name: git-commit-push
description: "commitしてpushする。Use when: git commit, git push, 変更をコミット, 変更をプッシュ, commitしてpush, 変更を保存してリモートに反映。commit単位は追加・修正ごとに分割し、pushは全変更をまとめて行う。"
argument-hint: "コミットメッセージのプレフィックスや対象ファイルを指定（省略可）"
---

# Git Commit & Push

追加・修正単位でcommitを分割し、最後にまとめてpushするワークフロー。

## ルール

| 操作 | 単位 |
|------|------|
| `git commit` | 追加・修正の種類ごと（1変更 = 1コミット） |
| `git push` | すべてのコミットをまとめて1回 |

## 手順

### 1. 変更状況を確認する

```bash
git status
git diff --stat
```

- 変更ファイルを一覧化する
- 各ファイルが「新規追加」か「修正」かを把握する

### 2. 変更をグループ分けする

以下の基準でコミット単位を決定する：

| 変更の種類 | conventional commits プレフィックス |
|-----------|--------------------------------------|
| 新機能・新規ファイルの追加 | `feat:` |
| バグ修正 | `fix:` |
| リファクタリング（動作変更なし） | `refactor:` |
| ドキュメント更新 | `docs:` |
| テスト追加・修正 | `test:` |
| ビルド・設定ファイルの変更 | `chore:` |

同じプレフィックスでも **論理的に独立した変更は別コミットに分ける**。

### 3. グループごとにcommitする

各グループについて：

```bash
git add <対象ファイル>
git commit -m "<prefix>: <変更内容の要約（日本語）>"
```

- `git add .` は使わない。対象ファイルを明示的に指定する
- コミットメッセージは日本語で簡潔に記述する

### 4. すべてのコミットをまとめてpushする

```bash
git push origin <current-branch>
```

- pushは全コミットが揃ってから **1回だけ** 実行する
- ブランチ名は `git branch --show-current` で確認する

## 完了確認

- [ ] `git log --oneline -5` でコミット履歴が意図通りか確認
- [ ] pushが正常終了（exit code 0）したか確認
