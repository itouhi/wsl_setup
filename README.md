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
- 移行手順の参考: [WSL2 Ubuntu 26.04 移行メモ](https://kwrkb.com/wsl2-ubuntu-2604-mi-gration/)
- 既存環境から移行する場合は、上記記事の注意点（バックアップや移行前確認）を先に確認しておくと安全です。
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

### 2.5 Optional: sudo をパスワードなしで実行する

必要に応じて、現在のユーザーに `NOPASSWD` 設定を追加できます。

```bash
echo "${USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${USER} >/dev/null
sudo chmod 440 /etc/sudoers.d/${USER}
```

### 2.6 Optional: uv と Node.js をインストールする

Python ツールチェーンとして `uv`、JavaScript ツールチェーンとして Node.js を利用する場合は、以下を実行します。

#### uv

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
uv --version
```

永続化する場合は、`~/.bashrc` に PATH を追加します。

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Node.js (nvm 経由)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts
node -v
npm -v
```

### 2.7 Optional: Docker をインストールする

WSL 上で Docker Engine を使う場合は、以下を実行します。

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	$(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

sudo なしで Docker を使う場合は、ユーザーを `docker` グループへ追加します。

```bash
sudo usermod -aG docker $USER
newgrp docker
docker --version
docker compose version
```

### 3. curlで `git_init.sh` を直接取得してパイプ実行

リポジトリーをcloneせずに、スクリプトを直接取得してそのまま実行する場合は以下を使用します。

ユーザー名とメールアドレスを引数で指定して実行する場合:

```bash
curl -fsSL https://raw.githubusercontent.com/itouhi/wsl_setup/main/scripts/git_init.sh | bash -s -- "Your Name" "you@example.com"
```

未指定で実行し、プロンプト入力する場合:

```bash
curl -fsSL https://raw.githubusercontent.com/itouhi/wsl_setup/main/scripts/git_init.sh | bash
```

### 4. Optional: SSHコマンド alias 設定

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

### 5. devcontainer で開く

このリポジトリーには `.devcontainer/` を追加済みです。VS Code で以下の手順を実行すると、コンテナー内で開発できます。

1. Docker が起動していることを確認
2. VS Code でこのフォルダーを開く
3. コマンドパレットから `Dev Containers: Reopen in Container` を実行

初回ビルドでは、以下が自動で設定されます。

- Ubuntu 26.04 ベースの開発コンテナー
- 開発に必要な基本コマンド（git, curl, sudo など）
- `scripts/*.sh` への実行権限付与

手動で再ビルドする場合は、コマンドパレットから `Dev Containers: Rebuild Container` を実行してください。

コンテナー内から bind mount を使う場合は、コンテナー内パスではなくホスト側パスを使ってください。devcontainer では `LOCAL_WORKSPACE_FOLDER` にホスト側のワークスペース絶対パスが入ります。

```bash
docker run --rm -v "$LOCAL_WORKSPACE_FOLDER":/workspace alpine ls /workspace
```