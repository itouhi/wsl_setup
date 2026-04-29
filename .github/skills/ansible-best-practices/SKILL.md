---
name: ansible-best-practices
description: 'Ansible playbookおよびroleの開発・レビュー・リファクタリング時に使用。ディレクトリ構成、インベントリ管理、role設計、変数管理、タスク記述のベストプラクティスを適用する。Use when: writing ansible playbooks, creating roles, reviewing ansible code, structuring ansible projects.'
argument-hint: 'レビュー対象のplaybook/roleパスを指定（省略時はワークスペース全体）'
---

# Ansible ベストプラクティス

## いつ使うか

- 新しいplaybook・roleを作成するとき
- 既存のAnsibleコードをレビュー・リファクタリングするとき
- プロジェクトのディレクトリ構成を設計するとき

---

## 1. ディレクトリ構成

推奨する標準ディレクトリレイアウト:

```
production            # 本番環境インベントリファイル
stage                 # ステージング環境インベントリファイル

group_vars/
   all               # 全グループ共通変数
   webservers        # webserverグループ固有変数
   dbservers         # dbserverグループ固有変数

host_vars/
   hostname1         # ホスト固有変数（必要な場合のみ）

site.yml              # マスターplaybook（他playbookをincludeするだけ）
webservers.yml        # webserver層のplaybook
dbservers.yml         # dbserver層のplaybook

roles/
  common/
    tasks/
      main.yml        # タスク定義（必要なら小さなファイルをinclude）
    handlers/
      main.yml        # ハンドラ定義
    templates/        # Jinja2テンプレート（*.j2）
    files/            # copyリソース用の静的ファイル
    vars/             # role内変数
    defaults/         # デフォルト変数（優先度最低）
    meta/             # role依存関係
  webtier/
  dbservers/
```

**チェックポイント:**
- [ ] `site.yml` はincludeのみで実質的な処理を持たない
- [ ] roleは `roles/` 以下に分離されている
- [ ] テンプレートファイルは `.j2` 拡張子を持つ

---

## 2. インベントリ管理（ステージ vs 本番）

- **本番とステージングのインベントリファイルを必ず分ける**（`production` / `stage`）
- ホストは役割・地域・データセンターでグループ化する
- 子グループ（`:children`）を使って階層的に管理する

```ini
# production
[atlanta-webservers]
www-atl-1.example.com

[webservers:children]
atlanta-webservers
boston-webservers

[atlanta:children]
atlanta-webservers
atlanta-dbservers
```

**チェックポイント:**
- [ ] 本番とステージのインベントリが別ファイルに分かれている
- [ ] `-i production` / `-i stage` で環境を切り替えられる

---

## 3. 変数管理

優先度と用途に応じて変数を分類する:

| ファイル | 用途 |
|---|---|
| `group_vars/all` | 全ホスト共通のデフォルト値 |
| `group_vars/<group>` | グループ固有の変数 |
| `host_vars/<hostname>` | ホスト固有の変数（必要最小限） |
| `roles/<role>/defaults/main.yml` | roleのデフォルト値（上書き可） |
| `roles/<role>/vars/main.yml` | role内部の固定変数 |

**チェックポイント:**
- [ ] `host_vars` は必要な場合のみ使用し、`group_vars` を優先している
- [ ] 共通デフォルトは `group_vars/all` に集約されている

---

## 4. Playbook・Role設計

### トップレベルplaybookはroleへの委譲のみ

```yaml
# site.yml
- include: webservers.yml
- include: dbservers.yml

# webservers.yml
- hosts: webservers
  roles:
    - common
    - webtier
```

### roleのタスクとハンドラを分離する

```yaml
# roles/common/tasks/main.yml
- name: NTPがインストールされていることを確認する
  yum:
    pkg: ntp
    state: installed
  tags: ntp

- name: NTP設定ファイルを配置する
  template:
    src: ntp.conf.j2
    dest: /etc/ntp.conf
  notify:
    - restart ntpd
  tags: ntp

# roles/common/handlers/main.yml
- name: restart ntpd
  service:
    name: ntpd
    state: restarted
```

**チェックポイント:**
- [ ] ハンドラはhandlers/に分離されている
- [ ] タスクには必ず `name` が付いている（理由を説明する形式が望ましい）
- [ ] `state` パラメータは明示的に記述している

---

## 5. タスク記述ルール

### 常にタスクに名前を付ける
- `name` は「何をするか」より「なぜするか」を説明する形式が望ましい
- 実行時にログとして表示されるため、可読性が重要

### 常に `state` を明示する
```yaml
# 良い例
- name: nginxが起動・有効化されていることを確認する
  service:
    name: nginx
    state: started
    enabled: yes

# 悪い例（stateが不明）
- service: name=nginx
```

### タグを活用する
```yaml
# 特定タスクのみ実行可能にする
- name: NTPを設定する
  template:
    src: ntp.conf.j2
    dest: /etc/ntp.conf
  tags: ntp
```

**実行例:**
```bash
# インフラ全体を再構成
ansible-playbook -i production site.yml

# NTP関連のみ再構成
ansible-playbook -i production site.yml --tags ntp

# Boston環境のwebserverのみ
ansible-playbook -i production webservers.yml --limit boston

# 実行前に対象ホストを確認
ansible-playbook -i production webservers.yml --limit boston --list-hosts

# 実行前にタスク一覧を確認
ansible-playbook -i production webservers.yml --tags ntp --list-tasks
```

---

## 6. OS・ディストリビューション差異の吸収

`group_by` モジュールで動的グループを生成し、OS差異を吸収する:

```yaml
- hosts: all
  tasks:
    - group_by:
        key: "{{ ansible_distribution }}"

- hosts: CentOS
  gather_facts: false
  tasks:
    - # CentOS固有のタスク
```

---

## 7. カスタムモジュールのバンドル

playbookと同じリポジトリでモジュールを管理する場合、`library/` ディレクトリに配置する:

```
site.yml
library/
  my_custom_module.py   # 自動的にモジュールパスに追加される
```

---

## 8. 一般原則

| 原則 | 内容 |
|---|---|
| **シンプルに保つ** | Ansibleの全機能を一度に使わない。必要なものだけ使う |
| **バージョン管理** | playbookとインベントリファイルをGitで管理し、変更時は必ずコミットする |
| **空白とコメント** | 適切な空白とコメント（`#`）でYAMLを読みやすくする |
| **ローリングアップデート** | `serial` キーワードで一度にアップデートするホスト数を制御する |
| **role毎のグループ** | システムはrole名に対応したグループに属させ、グループ変数でrole設定を管理する |

---

## レビューチェックリスト

コードレビュー時は以下を確認する:

- [ ] ディレクトリ構成が標準レイアウトに従っている
- [ ] 本番・ステージングインベントリが分離されている
- [ ] 全タスクに意味のある `name` がある
- [ ] `state` パラメータが明示されている
- [ ] タスクとハンドラが分離されている
- [ ] 変数が適切なスコープ（group_vars/host_vars）に配置されている
- [ ] playbookがGit管理されている
- [ ] 不必要な複雑さ（未使用変数、過剰な抽象化）がない
