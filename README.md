# WSL2 for Ubuntu 26.04 LTS Setup Script

このリポジトリーは、WSL2向けのUbuntu 26.04 LTS環境を構築するためのセットアップ手順とスクリプトをまとめたものです。

## 概要

- WSL2にUbuntu 26.04 LTSをインストール・設定
- Linuxでの開発環境を整備
- devcontainerを使用した再現性の高い開発
- 最小限の設定で素早く利用開始

## セットアップ手順

### 1. Ubuntu 26.04 LTSのダウンロード

- 公式ページの [WSLイメージ](https://releases.ubuntu.com/26.04/) を使用します。
- ダウンロード後、PowerShellで以下を実行します。

```powershell
wsl --install --from-file "%USERPROFILE%\Downloads\ubuntu-26.04-wsl-amd64.wsl" --name Ubuntu
```

### 2. WSL2の起動と初期設定

初回起動時に、以下のようなプロンプトが表示されます。案内に従ってデフォルトユーザー名とパスワードを設定してください。

```text
Provisioning the new WSL instance Ubuntu
This might take a while...
Create a default Unix user account: ubuntu
New password:
Retype new password:
passwd: password updated successfully
Help improve Ubuntu!
Would you like to opt-in to platform metrics collection (Y/n)?
```

### 3. GitHubのリポジトリーをダウンロードして `scripts/git_init.sh` を実行

WSL上のターミナルで、以下の手順を実行します。

- スクリプト: https://github.com/itouhi/wsl_setup/blob/main/scripts/git_init.sh

```bash
git clone https://github.com/itouhi/wsl_setup.git
cd wsl_setup
chmod +x scripts/git_init.sh
```

ユーザー名とメールアドレスを引数で指定して実行する場合:

```bash
./scripts/git_init.sh "Your Name" "you@example.com"
```

未指定で実行し、プロンプト入力する場合:

```bash
./scripts/git_init.sh
```

### 4. curlで `git_init.sh` を直接ダウンロードして実行

リポジトリーをcloneせずに、スクリプトを直接ダウンロードして実行する場合は以下を使用します。

```bash
curl -fsSL -o git_init.sh https://raw.githubusercontent.com/itouhi/wsl_setup/main/scripts/git_init.sh
chmod +x git_init.sh
```

ユーザー名とメールアドレスを引数で指定して実行する場合:

```bash
./git_init.sh "Your Name" "you@example.com"
```

未指定で実行し、プロンプト入力する場合:

```bash
./git_init.sh
```

### 5. Optional: SSHコマンド alias 設定

1Password SSH agent を Git 以外でも使う場合、`ssh` と `ssh-add` を `ssh.exe` と `ssh-add.exe` に向ける alias を設定できます。

```bash
chmod +x scripts/ssh_aliases_init.sh
./scripts/ssh_aliases_init.sh
```

実行後に表示される `Configured SSH aliases in: ...` のファイルを `source` してください。

```bash
source ~/.bashrc
# or
source ~/.bash_aliases
```

`~/.bash_aliases` を使いたい場合は、引数で指定できます。

```bash
./scripts/ssh_aliases_init.sh ~/.bash_aliases
source ~/.bash_aliases
```