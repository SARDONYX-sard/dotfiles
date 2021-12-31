# Linux Flow

- [Linux Flow](#linux-flow)
  - [はじめに](#はじめに)
  - [PowerShellにて](#powershellにて)
  - [install-wsl.sh](#install-wslsh)
  - [linux/symlink.sh](#linuxsymlinksh)
  - [.gitconfigを$HOMEに出力](#gitconfigをhomeに出力)
  - [linux/bin/all-installer.sh](#linuxbinall-installersh)

## はじめに

WSL環境をdotfilesで整えたい場合、さきに`install-win.ps1`を実行することをオススメします。 理由は以下の3つです。

- WSLを自動インストールしてくれる
- gitなどの前提コマンドを手動でそろえなければならない
- scoopが環境変数に登録されていること(これを使ってWSLからwindowsのユーザー名を取って、windowsのdotfilesにシンボリックリンクをつなげています)

ただしこれらをすでにお持ちの場合、実行するのはたやすいでしょう。

## PowerShellにて

- WSLについてはまずWindows側の$HOMEにdotfilesを`git clone`してくる必要があります。
- さきに`install-win.ps1`を実行した場合、この操作はすでに自動終了しているので必要ありません。

```powershell
git clone https://github.com/SARDONYX-sard/dotfiles.git $HOME/dotfiles
```

## install-wsl.sh

- windowsと違い、今回はこれがセットアップの中核を担うファイルとなります。
- 引数にzshの文字列を渡すとzshに切り替えられます。`sudo bash install-wsl.sh zsh`

- WSLまたはLinuxのターミナルで以下のコマンドを実行します。

```bash
sudo bash install-wsl.sh
```

- このファイル内では、WSLかLinux自体か、Msys2かを自動判別してシンボリックリンクを繋ぐフォルダーを動的に決定しています。

決定した値は`HOME_DIR`変数に格納します。

Linuxの場合: $HOME_DIR = /home/linux username/

WSLの場合: $HOME_DIR = /mnt/c/Users/**windows username**/

Msys2の場合: $HOME_DIR = /c/Users/**windows username**/

## linux/symlink.sh

- WSLの場合はscoopの環境変数から割り出したWindowsの$HOMEディレクトリを使って、シンボリックリンクをつなげます。

## .gitconfigを$HOMEに出力

## linux/bin/all-installer.sh

管理マネージャーをbashでインストールし、核管理マネージャーで便利なパッケージをインストールします。

linux/bin/installerにはいくつかのパッケージのインストーラーが置いてありますが、これらはお好みでいれられます。

いれたくないパッケージがある場合、[こちら](../../../linux/bin/all-installer.sh)のファイルへ赴き、コメントアウトをしてください。

パッケージの例:

- aptによる便利なパッケージ群
- asdfによるプログラミング言語のインストール
- homebrew によりoh-my-poshをインストール(ターミナルのデザインを変えるため)
- rustupのインストール(cargoにより`procs`などのより速いコマンドを使うため、rustを使うため)
  asdfでの管理もできますが、rustupの利便性に軍配が上がるため、その必要はないと判断しました。
