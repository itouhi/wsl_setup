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