# Ansible セットアップ手順

WSL2の初期状態（Ubuntu 26.04 LTS インストール直後）から `ansible-playbook` を実行できるようにするための手順です。

## 前提条件

- WSL2 上の Ubuntu 26.04 LTS が起動済みであること
- インターネット接続があること

---

## 1. Ansibleをインストールする

WSL2初期状態にはAnsibleが入っていないため、まずインストールします。

```bash
sudo apt-get update
sudo apt-get install -y ansible
```

インストールを確認します。

```bash
ansible --version
```

---

## 2. リポジトリをクローンする

```bash
git clone https://github.com/itouhi/wsl_setup.git
cd wsl_setup
```

> git がない場合は先にインストールしてください。
>
> ```bash
> sudo apt-get install -y git
> ```

---

## 3. ansible-playbook を実行する

### 全ロールをまとめて実行する

```bash
ansible-playbook -i ansible/inventories/hosts ansible/site.yml \
  -e "git_user_name='Your Name' git_user_email='you@example.com'"
```

### 特定のロールだけ実行する

タグで絞り込めます。

| タグ | 内容 |
|------|------|
| `common` | sudo NOPASSWD 設定 |
| `git` | git グローバル設定（user.name / user.email / core.sshCommand） |
| `uv` | uv（Python ツールチェーン）のインストール |
| `nodejs` | nvm + Node.js LTS のインストール |
| `docker` | Docker Engine のインストール |
| `ssh_aliases` | 1Password SSH agent 用エイリアス設定 |

例: Docker だけインストールする

```bash
ansible-playbook -i ansible/inventories/hosts ansible/site.yml --tags docker
```

例: git 設定と SSH エイリアスだけ適用する

```bash
ansible-playbook -i ansible/inventories/hosts ansible/site.yml \
  --tags "git,ssh_aliases" \
  -e "git_user_name='Your Name' git_user_email='you@example.com'"
```

### 実行前に対象ホスト・タスクを確認する

```bash
# 対象ホストを確認
ansible-playbook -i ansible/inventories/hosts ansible/site.yml --list-hosts

# 実行されるタスクを確認
ansible-playbook -i ansible/inventories/hosts ansible/site.yml --list-tasks
```

---

## 4. 変数一覧

| 変数名 | デフォルト | 説明 |
|--------|-----------|------|
| `git_user_name` | `""` | git の user.name |
| `git_user_email` | `""` | git の user.email |
| `nvm_version` | `"v0.40.3"` | インストールする nvm のバージョン |
| `nodejs_version` | `"--lts"` | インストールする Node.js のバージョン |

変数は `-e` オプションまたは `ansible/group_vars/all.yml` で上書きできます。

---

## 5. ディレクトリ構成

```
ansible/
├── site.yml                          # マスターplaybook
├── wsl_setup.yml                     # 実行playbook（全ロール定義）
├── inventories/
│   └── hosts                         # インベントリ（ローカル実行）
├── group_vars/
│   └── all.yml                       # 共通変数
└── roles/
    ├── common/tasks/main.yml         # sudo NOPASSWD 設定
    ├── git/tasks/main.yml            # git グローバル設定
    ├── uv/tasks/main.yml             # uv インストール
    ├── nodejs/tasks/main.yml         # nvm + Node.js インストール
    ├── docker/tasks/main.yml         # Docker Engine インストール
    └── ssh_aliases/tasks/main.yml    # SSH エイリアス設定
```
