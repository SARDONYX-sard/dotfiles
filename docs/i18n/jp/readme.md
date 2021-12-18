# dotfiles

- 現在このプロジェクトは開発中です。不用意に実行するとエラーする可能性があります。

## 目次

- [dotfiles](#dotfiles)
  - [目次](#目次)
  - [インストール方法](#インストール方法)
    - [windows](#windows)
    - [GNU/Linux](#gnulinux)
  - [進捗状況](#進捗状況)
  - [注意'!'](#注意)
  - [手動でやらなければならないこと](#手動でやらなければならないこと)
  - [コーディングに際して行った回避策](#コーディングに際して行った回避策)
  - [参考サイト](#参考サイト)
  - [ライセンス](#ライセンス)

## インストール方法

以下のコマンドを実行します。

### windows

以下のコマンドを実行します。

```powershell
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/SARDONYX-sard/dotfiles/main/install-win.ps1')
```

### GNU/Linux

WSLまたはLinux上で可能です。

Linux(WSLではない)でinstall-wsl.shを実行した場合、linux単体の使用を想定したシンボリックリンクになります。

WSLでinstall-wsl.shを実行した場合、Windows側からシンボリックリンクをWSLに繋ぎます。

- Linux(WSLではない)の場合

以下のコマンドを実行します。

```bash
# Can be done on Windows or linux
git clone https://github.com/SARDONYX-sard/dotfiles.git $HOME

cd ~/dotfiles
bash "install-wsl.sh"
```

- WSL(Windows Subsystem for Linux)

1.PowerShellで以下のコマンドを実行します。

```powershell
git clone https://github.com/SARDONYX-sard/dotfiles.git $HOME
```

2.WSLで以下のコマンドを実行します。

```bash
# reference: (https://www.reddit.com/r/bashonubuntuonwindows/comments/8dhhrr/is_it_possible_to_get_the_windows_username_from/)

export USERNAME=`cmd.exe /c echo %username%`
cd /mnt/c/Users/${USERNAME}/dotfiles
bash "install-wsl.sh"
```

## 進捗状況

- 完成箇所

  - Windows settings
  - Linux settings

- 未完成箇所

  - 細かなバグ修正
  - 再現性の未確認(とくにWSL)
  - テストコードの追加

## 注意'!'

- これは私の開発環境のセットアップリポジトリです。 あなたが何をしているのか分かっていないのであれば、むやみにこのコードを実行しないでください。
  安易に実行すると、現在のあなたの開発環境が私の開発環境の設定に上書きされてしまいます。

- いくつかの設定は、日本語になっており、英語話者向けではない可能性があります。

- このプロジェクトは[こちら](https://github.com/LumaKernel/dotfiles)のdotfilesプロジェクトを参考にしています。
  彼に多大な感謝を…

## 手動でやらなければならないこと

- `hard coded`とコメントが書かれたユーザー名の書き換え。(エディターの検索機能を使ってください)

## コーディングに際して行った回避策

いくつかはコメントにも残してありますが、こちらにも記載しておきます。

- `git clone`では`~`が展開されず、`~`というディレクトリになってしまいます。そのため、`$HOME`変数を用いています。
- `ps1`ファイルの実行では`$HOME`が展開されなかったので、`~`変数を使っています。

## 参考サイト

- <https://github.com/LumaKernel/dotfiles>

## ライセンス

Unlicense
