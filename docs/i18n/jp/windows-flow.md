# Windows Flow

- [Windows Flow](#windows-flow)
  - [はじめに](#はじめに)
  - [install-win.ps1](#install-winps1)
  - [windows\setup\install-app.ps1](#windowssetupinstall-appps1)
    - [windows\setup\scoop-install.ps1](#windowssetupscoop-installps1)
    - [windows/setup/git-setting.ps1](#windowssetupgit-settingps1)
    - [windows\setup\pwsh-modules.ps1](#windowssetuppwsh-modulesps1)
    - [windows\setup\symlink.ps1](#windowssetupsymlinkps1)
    - [windows\data\winget-app-list.json](#windowsdatawinget-app-listjson)
    - [(任意)windows\bin\installers\all-languages.ps1](#任意windowsbininstallersall-languagesps1)
    - [vimの管理マネージャーのインストール](#vimの管理マネージャーのインストール)

## はじめに

このぺーじは`install-win.ps1`によるインストールの工程でそれぞれ何をしているのかを説明します。

## install-win.ps1

- 主にgitをscoop経由でインストールし、管理者権限を持つ行動を行います

1. scoopのインストール

2. scoopでsudoコマンドなどのコマンドツールのインストール(`psutils`)

3. `install-app.ps1`へ移動

## windows\setup\install-app.ps1

- 複数の`ps1`モジュールを実行するwindowsのセットアップ作業を担う司令塔です。

1. $HOMEに移動し`git clone`でdotfilesを取得します。

### windows\setup\scoop-install.ps1

1. `npm`に似たエイリアスの登録。

2. scoopを使って[ソフトウェア](../../app-list-data/scoop-list.md)のインストール

### windows/setup/git-setting.ps1

[git-config.txt](../../../common/data/git-config.txt)を読み込み、`$HOME`の`.gitconfig`にリダイレクトします。

すでにファイルが存在する場合は`-Force`オプションを使わない限り、上書きされることはありません。

### windows\setup\pwsh-modules.ps1

- PowerShellのモジュールをインストールします。

私が気に入ってるのはWSLコマンドを`wsl.exe`宣言なしで使うことのできるモジュール、`fzf`という検索ツールコマンドのラッパーモジュールです。

### windows\setup\symlink.ps1

- `msys2`などのシンボリックリンクによるdotfilesとの連携

こちらも`.gitconfig`と同じくすでにファイルが存在する場合は`-Force`オプションを使わない限り、上書きされることはありません。

なお、シンボリックリンクでdotfilesと`Windows Terminal`の設定を連携すると保存した設定を反映するために再起動する必要があります。

### windows\data\winget-app-list.json

wingetによるインストール

前提: 実行にはwingetが必要です。

- windows11なら標準でインストールされています。
- またはwinget.exeを[こちら](https://github.com/microsoft/winget-cli)から入手してインストールします。

以下のファイルからインポートしています。

[winget リスト](./windows/data/../../../../../windows/data/winget-app-list.json)

### (任意)windows\bin\installers\all-languages.ps1

開発言語の一式をscoop経由でインストールでき、global環境に私がよく使うライブラリを一式インストールできます。

### vimの管理マネージャーのインストール
