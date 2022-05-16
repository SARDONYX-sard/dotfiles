function tree ($cmd) {
  $errorMsg = @"
Error:
該当するNodeモジュールがありません。以下のコマンドを実行し、tree-cliをインストールしてください
npm install -g tree-cli

・node.jsがない場合は、https://nodejs.org/ を参照してください
"@

  $helpMsg = @"
tree            : ソースツリーを実行します
tree o          : 第2層までのnode_modulesを除くtreeを、tree.txtとして書き込みます
tree h, help    : このヘルプを表示します


--help       :詳細な使用状況を出力します。
--version    : tree-cli のバージョンを出力します。
--debug      : デバッグ情報を表示します。
--fullpath   : 各ファイルのフルパス・プレフィックスを表示します。
--ignore     : 指定したディレクトリやファイルを無視します - 配列をカンマ区切りの文字列(e.g.: 'node_modules/, .git/, .gitignore')として受け取ります
--link       : シンボリックリンクがディレクトリを指している場合、ディレクトリであるかのようにそれに従います。再帰を引き起こすシンボリックリンクは検出された時点で回避されます。
--noreport   : ツリー一覧の最後にファイルとディレクトリのレポートを表示することを省略し、コンソールへのツリーの表示を省略します。
--base       : ルートディレクトリを指定します。cwd rootからの相対パスでも、絶対パスでも構いません。この引数はオプションです。
-a           : すべてのファイルを表示します。デフォルトでは、tree は隠しファイル (ドット '.' で始まるファイル) を表示しません。
              また、ファイルシステムの構造体である '.' (現在のディレクトリ) と '..' (前のディレクトリ) を表示することはありません。
              (前のディレクトリ)を表示しません。
-d           : ディレクトリのみをリストアップします。
-f           : ディレクトリには '/'、ソケットファイルには '='、FIFO には '|' を付加します。
-i           :ツリーにインデント行を表示しないようにします。-fオプションと併用すると便利です。
-l           : ディレクトリツリーの最大表示深度を指定します。
-o           : 出力をファイル名に送ります。
"@

  if ((Get-Command treee).Name -ne "treee.ps1") { Write-Host $errorMsg }

  switch ($cmd) {
    "o" { treee -l 2 --ignore 'node_modules' -o ./tree.txt }
    "node" { treee -l 2 --ignore 'node_modules' }
    "h" { Write-Output $helpMsg }
    "help" { Write-Output $helpMsg }
    Default { treee $args }
  }
}
