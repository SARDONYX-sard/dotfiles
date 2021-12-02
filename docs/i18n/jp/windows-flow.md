# Windows Flow

- install-win.ps1によるインストールの工程

1 scoopのインストール:

- [該当ファイル](install-win.ps1)

2 ~/dotfiles/windows/setup/scoop-install.ps1:

- scoopを使った[ソフトウェア](docs\scoop-list.md)のインストール

3 シンボリックリンクによるdotfilesとの連携

- [該当ファイル](windows\setup\symlink.ps1)

4 wingetによるインストール(windows11かwinget.exeを入手)

- [winget リスト](windows\data\winget-app-list.json)
