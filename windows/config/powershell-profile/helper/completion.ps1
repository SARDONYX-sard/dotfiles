using namespace System.Management.Automation
using namespace System.Management.Automation.Language


if ($PSVersionTable.PSEdition -eq "Core") {
  # Shows navigable menu of all options when hitting Tab
  Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

  # Autocompletion for arrow keys
  Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
  Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

  # --------------------------------------------------------------------------------------------------
  # rustup completion
  # --------------------------------------------------------------------------------------------------
  Register-ArgumentCompleter -Native -CommandName 'rustup' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
      'rustup'
      for ($i = 1; $i -lt $commandElements.Count; $i++) {
        $element = $commandElements[$i]
        if ($element -isnot [StringConstantExpressionAst] -or
          $element.StringConstantType -ne [StringConstantType]::BareWord -or
          $element.Value.StartsWith('-')) {
          break
        }
        $element.Value
      }) -join ';'

    $completions = @(switch ($command) {
        'rustup' {
          [CompletionResult]::new('-v', 'v', [CompletionResultType]::ParameterName, 'Enable verbose output')
          [CompletionResult]::new('--verbose', 'verbose', [CompletionResultType]::ParameterName, 'Enable verbose output')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Disable progress output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Disable progress output')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('dump-testament', 'dump-testament', [CompletionResultType]::ParameterValue, 'Dump information about the build')
          [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Show the active and installed toolchains or profiles')
          [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Update Rust toolchains')
          [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstall Rust toolchains')
          [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update Rust toolchains and rustup')
          [CompletionResult]::new('check', 'check', [CompletionResultType]::ParameterValue, 'Check for updates to Rust toolchains and rustup')
          [CompletionResult]::new('default', 'default', [CompletionResultType]::ParameterValue, 'Set the default toolchain')
          [CompletionResult]::new('toolchain', 'toolchain', [CompletionResultType]::ParameterValue, 'Modify or query the installed toolchains')
          [CompletionResult]::new('target', 'target', [CompletionResultType]::ParameterValue, 'Modify a toolchain''s supported targets')
          [CompletionResult]::new('component', 'component', [CompletionResultType]::ParameterValue, 'Modify a toolchain''s installed components')
          [CompletionResult]::new('override', 'override', [CompletionResultType]::ParameterValue, 'Modify directory toolchain overrides')
          [CompletionResult]::new('run', 'run', [CompletionResultType]::ParameterValue, 'Run a command with an environment configured for a given toolchain')
          [CompletionResult]::new('which', 'which', [CompletionResultType]::ParameterValue, 'Display which binary will be run for a given command')
          [CompletionResult]::new('doc', 'doc', [CompletionResultType]::ParameterValue, 'Open the documentation for the current toolchain')
          [CompletionResult]::new('self', 'self', [CompletionResultType]::ParameterValue, 'Modify the rustup installation')
          [CompletionResult]::new('set', 'set', [CompletionResultType]::ParameterValue, 'Alter rustup settings')
          [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate tab-completion scripts for your shell')
          [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Prints this message or the help of the given subcommand(s)')
          break
        }
        'rustup;dump-testament' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;show' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('active-toolchain', 'active-toolchain', [CompletionResultType]::ParameterValue, 'Show the active toolchain')
          [CompletionResult]::new('home', 'home', [CompletionResultType]::ParameterValue, 'Display the computed value of RUSTUP_HOME')
          [CompletionResult]::new('profile', 'profile', [CompletionResultType]::ParameterValue, 'Show the current profile')
          [CompletionResult]::new('keys', 'keys', [CompletionResultType]::ParameterValue, 'Display the known PGP keys')
          [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Prints this message or the help of the given subcommand(s)')
          break
        }
        'rustup;show;active-toolchain' {
          [CompletionResult]::new('-v', 'v', [CompletionResultType]::ParameterName, 'Enable verbose output with rustc information')
          [CompletionResult]::new('--verbose', 'verbose', [CompletionResultType]::ParameterName, 'Enable verbose output with rustc information')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;show;home' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;show;profile' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;show;keys' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;show;help' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;install' {
          [CompletionResult]::new('--profile', 'profile', [CompletionResultType]::ParameterName, 'profile')
          [CompletionResult]::new('--no-self-update', 'no-self-update', [CompletionResultType]::ParameterName, 'Don''t perform self-update when running the `rustup install` command')
          [CompletionResult]::new('--force', 'force', [CompletionResultType]::ParameterName, 'Force an update, even if some components are missing')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;uninstall' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;update' {
          [CompletionResult]::new('--no-self-update', 'no-self-update', [CompletionResultType]::ParameterName, 'Don''t perform self update when running the `rustup update` command')
          [CompletionResult]::new('--force', 'force', [CompletionResultType]::ParameterName, 'Force an update, even if some components are missing')
          [CompletionResult]::new('--force-non-host', 'force-non-host', [CompletionResultType]::ParameterName, 'Install toolchains that require an emulator. See https://github.com/rust-lang/rustup/wiki/Non-host-toolchains')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;check' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;default' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;toolchain' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List installed toolchains')
          [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Install or update a given toolchain')
          [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstall a toolchain')
          [CompletionResult]::new('link', 'link', [CompletionResultType]::ParameterValue, 'Create a custom toolchain by symlinking to a directory')
          [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Prints this message or the help of the given subcommand(s)')
          break
        }
        'rustup;toolchain;list' {
          [CompletionResult]::new('-v', 'v', [CompletionResultType]::ParameterName, 'Enable verbose output with toolchain information')
          [CompletionResult]::new('--verbose', 'verbose', [CompletionResultType]::ParameterName, 'Enable verbose output with toolchain information')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;toolchain;install' {
          [CompletionResult]::new('--profile', 'profile', [CompletionResultType]::ParameterName, 'profile')
          [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Add specific components on installation')
          [CompletionResult]::new('--component', 'component', [CompletionResultType]::ParameterName, 'Add specific components on installation')
          [CompletionResult]::new('-t', 't', [CompletionResultType]::ParameterName, 'Add specific targets on installation')
          [CompletionResult]::new('--target', 'target', [CompletionResultType]::ParameterName, 'Add specific targets on installation')
          [CompletionResult]::new('--no-self-update', 'no-self-update', [CompletionResultType]::ParameterName, 'Don''t perform self update when running the`rustup toolchain install` command')
          [CompletionResult]::new('--force', 'force', [CompletionResultType]::ParameterName, 'Force an update, even if some components are missing')
          [CompletionResult]::new('--allow-downgrade', 'allow-downgrade', [CompletionResultType]::ParameterName, 'Allow rustup to downgrade the toolchain to satisfy your component choice')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;toolchain;uninstall' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;toolchain;link' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;toolchain;help' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;target' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List installed and available targets')
          [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add a target to a Rust toolchain')
          [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove a target from a Rust toolchain')
          [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Prints this message or the help of the given subcommand(s)')
          break
        }
        'rustup;target;list' {
          [CompletionResult]::new('--toolchain', 'toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
          [CompletionResult]::new('--installed', 'installed', [CompletionResultType]::ParameterName, 'List only installed targets')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;target;add' {
          [CompletionResult]::new('--toolchain', 'toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;target;remove' {
          [CompletionResult]::new('--toolchain', 'toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;target;help' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;component' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List installed and available components')
          [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add a component to a Rust toolchain')
          [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove a component from a Rust toolchain')
          [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Prints this message or the help of the given subcommand(s)')
          break
        }
        'rustup;component;list' {
          [CompletionResult]::new('--toolchain', 'toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
          [CompletionResult]::new('--installed', 'installed', [CompletionResultType]::ParameterName, 'List only installed components')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;component;add' {
          [CompletionResult]::new('--toolchain', 'toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
          [CompletionResult]::new('--target', 'target', [CompletionResultType]::ParameterName, 'target')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;component;remove' {
          [CompletionResult]::new('--toolchain', 'toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
          [CompletionResult]::new('--target', 'target', [CompletionResultType]::ParameterName, 'target')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;component;help' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;override' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List directory toolchain overrides')
          [CompletionResult]::new('set', 'set', [CompletionResultType]::ParameterValue, 'Set the override toolchain for a directory')
          [CompletionResult]::new('unset', 'unset', [CompletionResultType]::ParameterValue, 'Remove the override toolchain for a directory')
          [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Prints this message or the help of the given subcommand(s)')
          break
        }
        'rustup;override;list' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;override;set' {
          [CompletionResult]::new('--path', 'path', [CompletionResultType]::ParameterName, 'Path to the directory')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;override;unset' {
          [CompletionResult]::new('--path', 'path', [CompletionResultType]::ParameterName, 'Path to the directory')
          [CompletionResult]::new('--nonexistent', 'nonexistent', [CompletionResultType]::ParameterName, 'Remove override toolchain for all nonexistent directories')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;override;help' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;run' {
          [CompletionResult]::new('--install', 'install', [CompletionResultType]::ParameterName, 'Install the requested toolchain if needed')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;which' {
          [CompletionResult]::new('--toolchain', 'toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;doc' {
          [CompletionResult]::new('--toolchain', 'toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
          [CompletionResult]::new('--path', 'path', [CompletionResultType]::ParameterName, 'Only print the path to the documentation')
          [CompletionResult]::new('--alloc', 'alloc', [CompletionResultType]::ParameterName, 'The Rust core allocation and collections library')
          [CompletionResult]::new('--book', 'book', [CompletionResultType]::ParameterName, 'The Rust Programming Language book')
          [CompletionResult]::new('--cargo', 'cargo', [CompletionResultType]::ParameterName, 'The Cargo Book')
          [CompletionResult]::new('--core', 'core', [CompletionResultType]::ParameterName, 'The Rust Core Library')
          [CompletionResult]::new('--edition-guide', 'edition-guide', [CompletionResultType]::ParameterName, 'The Rust Edition Guide')
          [CompletionResult]::new('--nomicon', 'nomicon', [CompletionResultType]::ParameterName, 'The Dark Arts of Advanced and Unsafe Rust Programming')
          [CompletionResult]::new('--proc_macro', 'proc_macro', [CompletionResultType]::ParameterName, 'A support library for macro authors when defining new macros')
          [CompletionResult]::new('--reference', 'reference', [CompletionResultType]::ParameterName, 'The Rust Reference')
          [CompletionResult]::new('--rust-by-example', 'rust-by-example', [CompletionResultType]::ParameterName, 'A collection of runnable examples that illustrate various Rust concepts and standard libraries')
          [CompletionResult]::new('--rustc', 'rustc', [CompletionResultType]::ParameterName, 'The compiler for the Rust programming language')
          [CompletionResult]::new('--rustdoc', 'rustdoc', [CompletionResultType]::ParameterName, 'Generate documentation for Rust projects')
          [CompletionResult]::new('--std', 'std', [CompletionResultType]::ParameterName, 'Standard library API documentation')
          [CompletionResult]::new('--test', 'test', [CompletionResultType]::ParameterName, 'Support code for rustc''s built in unit-test and micro-benchmarking framework')
          [CompletionResult]::new('--unstable-book', 'unstable-book', [CompletionResultType]::ParameterName, 'The Unstable Book')
          [CompletionResult]::new('--embedded-book', 'embedded-book', [CompletionResultType]::ParameterName, 'The Embedded Rust Book')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;self' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Download and install updates to rustup')
          [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstall rustup.')
          [CompletionResult]::new('upgrade-data', 'upgrade-data', [CompletionResultType]::ParameterValue, 'Upgrade the internal data format.')
          [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Prints this message or the help of the given subcommand(s)')
          break
        }
        'rustup;self;update' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;self;uninstall' {
          [CompletionResult]::new('-y', 'y', [CompletionResultType]::ParameterName, 'y')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;self;upgrade-data' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;self;help' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;set' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('default-host', 'default-host', [CompletionResultType]::ParameterValue, 'The triple used to identify toolchains when not specified')
          [CompletionResult]::new('profile', 'profile', [CompletionResultType]::ParameterValue, 'The default components installed')
          [CompletionResult]::new('auto-self-update', 'auto-self-update', [CompletionResultType]::ParameterValue, 'The rustup auto self update mode')
          [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Prints this message or the help of the given subcommand(s)')
          break
        }
        'rustup;set;default-host' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;set;profile' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;set;auto-self-update' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;set;help' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;completions' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
        'rustup;help' {
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          break
        }
      })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
    Sort-Object -Property ListItemText
  }


  # --------------------------------------------------------------------------------------------------
  # deno completion
  # --------------------------------------------------------------------------------------------------
  Register-ArgumentCompleter -Native -CommandName 'deno' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
      'deno'
      for ($i = 1; $i -lt $commandElements.Count; $i++) {
        $element = $commandElements[$i]
        if ($element -isnot [StringConstantExpressionAst] -or
          $element.StringConstantType -ne [StringConstantType]::BareWord -or
          $element.Value.StartsWith('-')) {
          break
        }
        $element.Value
      }) -join ';'

    $completions = @(switch ($command) {
        'deno' {
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('bundle', 'bundle', [CompletionResultType]::ParameterValue, 'Bundle module and dependencies into single file')
          [CompletionResult]::new('cache', 'cache', [CompletionResultType]::ParameterValue, 'Cache the dependencies')
          [CompletionResult]::new('compile', 'compile', [CompletionResultType]::ParameterValue, 'UNSTABLE: Compile the script into a self contained executable')
          [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate shell completions')
          [CompletionResult]::new('coverage', 'coverage', [CompletionResultType]::ParameterValue, 'Print coverage reports')
          [CompletionResult]::new('doc', 'doc', [CompletionResultType]::ParameterValue, 'Show documentation for a module')
          [CompletionResult]::new('eval', 'eval', [CompletionResultType]::ParameterValue, 'Eval script')
          [CompletionResult]::new('fmt', 'fmt', [CompletionResultType]::ParameterValue, 'Format source files')
          [CompletionResult]::new('info', 'info', [CompletionResultType]::ParameterValue, 'Show info about cache or info related to source file')
          [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Install script as an executable')
          [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstall a script previously installed with deno install')
          [CompletionResult]::new('lsp', 'lsp', [CompletionResultType]::ParameterValue, 'Start the language server')
          [CompletionResult]::new('lint', 'lint', [CompletionResultType]::ParameterValue, 'Lint source files')
          [CompletionResult]::new('repl', 'repl', [CompletionResultType]::ParameterValue, 'Read Eval Print Loop')
          [CompletionResult]::new('run', 'run', [CompletionResultType]::ParameterValue, 'Run a JavaScript or TypeScript program')
          [CompletionResult]::new('test', 'test', [CompletionResultType]::ParameterValue, 'Run tests')
          [CompletionResult]::new('types', 'types', [CompletionResultType]::ParameterValue, 'Print runtime TypeScript declarations')
          [CompletionResult]::new('upgrade', 'upgrade', [CompletionResultType]::ParameterValue, 'Upgrade deno executable to given version')
          [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Prints this message or the help of the given subcommand(s)')
          break
        }
        'deno;bundle' {
          [CompletionResult]::new('--import-map', 'import-map', [CompletionResultType]::ParameterName, 'Load import map file')
          [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('--config', 'config', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('-r', 'r', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--reload', 'reload', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--lock', 'lock', [CompletionResultType]::ParameterName, 'Check the specified lock file')
          [CompletionResult]::new('--cert', 'cert', [CompletionResultType]::ParameterName, 'Load certificate authority from PEM encoded file')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--no-remote', 'no-remote', [CompletionResultType]::ParameterName, 'Do not resolve remote modules')
          [CompletionResult]::new('--no-check', 'no-check', [CompletionResultType]::ParameterName, 'Skip type checking modules')
          [CompletionResult]::new('--lock-write', 'lock-write', [CompletionResultType]::ParameterName, 'Write lock file (use with --lock)')
          [CompletionResult]::new('--watch', 'watch', [CompletionResultType]::ParameterName, 'UNSTABLE: Watch for file changes and restart process automatically')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;cache' {
          [CompletionResult]::new('--import-map', 'import-map', [CompletionResultType]::ParameterName, 'Load import map file')
          [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('--config', 'config', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('-r', 'r', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--reload', 'reload', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--lock', 'lock', [CompletionResultType]::ParameterName, 'Check the specified lock file')
          [CompletionResult]::new('--cert', 'cert', [CompletionResultType]::ParameterName, 'Load certificate authority from PEM encoded file')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--no-remote', 'no-remote', [CompletionResultType]::ParameterName, 'Do not resolve remote modules')
          [CompletionResult]::new('--no-check', 'no-check', [CompletionResultType]::ParameterName, 'Skip type checking modules')
          [CompletionResult]::new('--lock-write', 'lock-write', [CompletionResultType]::ParameterName, 'Write lock file (use with --lock)')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;compile' {
          [CompletionResult]::new('--import-map', 'import-map', [CompletionResultType]::ParameterName, 'Load import map file')
          [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('--config', 'config', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('-r', 'r', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--reload', 'reload', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--lock', 'lock', [CompletionResultType]::ParameterName, 'Check the specified lock file')
          [CompletionResult]::new('--cert', 'cert', [CompletionResultType]::ParameterName, 'Load certificate authority from PEM encoded file')
          [CompletionResult]::new('--allow-read', 'allow-read', [CompletionResultType]::ParameterName, 'Allow file system read access')
          [CompletionResult]::new('--allow-write', 'allow-write', [CompletionResultType]::ParameterName, 'Allow file system write access')
          [CompletionResult]::new('--allow-net', 'allow-net', [CompletionResultType]::ParameterName, 'Allow network access')
          [CompletionResult]::new('--unsafely-ignore-certificate-errors', 'unsafely-ignore-certificate-errors', [CompletionResultType]::ParameterName, 'DANGER: Disables verification of TLS certificates')
          [CompletionResult]::new('--allow-env', 'allow-env', [CompletionResultType]::ParameterName, 'Allow environment access')
          [CompletionResult]::new('--allow-run', 'allow-run', [CompletionResultType]::ParameterName, 'Allow running subprocesses')
          [CompletionResult]::new('--allow-ffi', 'allow-ffi', [CompletionResultType]::ParameterName, 'Allow loading dynamic libraries')
          [CompletionResult]::new('--location', 'location', [CompletionResultType]::ParameterName, 'Value of ''globalThis.location'' used by some web APIs')
          [CompletionResult]::new('--v8-flags', 'v8-flags', [CompletionResultType]::ParameterName, 'Set V8 command line options (for help: --v8-flags=--help)')
          [CompletionResult]::new('--seed', 'seed', [CompletionResultType]::ParameterName, 'Seed Math.random()')
          [CompletionResult]::new('-o', 'o', [CompletionResultType]::ParameterName, 'Output file (defaults to $PWD/<inferred-name>)')
          [CompletionResult]::new('--output', 'output', [CompletionResultType]::ParameterName, 'Output file (defaults to $PWD/<inferred-name>)')
          [CompletionResult]::new('--target', 'target', [CompletionResultType]::ParameterName, 'Target OS architecture')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--no-remote', 'no-remote', [CompletionResultType]::ParameterName, 'Do not resolve remote modules')
          [CompletionResult]::new('--no-check', 'no-check', [CompletionResultType]::ParameterName, 'Skip type checking modules')
          [CompletionResult]::new('--lock-write', 'lock-write', [CompletionResultType]::ParameterName, 'Write lock file (use with --lock)')
          [CompletionResult]::new('--allow-hrtime', 'allow-hrtime', [CompletionResultType]::ParameterName, 'Allow high resolution time measurement')
          [CompletionResult]::new('-A', 'A', [CompletionResultType]::ParameterName, 'Allow all permissions')
          [CompletionResult]::new('--allow-all', 'allow-all', [CompletionResultType]::ParameterName, 'Allow all permissions')
          [CompletionResult]::new('--prompt', 'prompt', [CompletionResultType]::ParameterName, 'Fallback to prompt if required permission wasn''t passed')
          [CompletionResult]::new('--cached-only', 'cached-only', [CompletionResultType]::ParameterName, 'Require that remote dependencies are already cached')
          [CompletionResult]::new('--enable-testing-features-do-not-use', 'enable-testing-features-do-not-use', [CompletionResultType]::ParameterName, 'INTERNAL: Enable internal features used during integration testing')
          [CompletionResult]::new('--compat', 'compat', [CompletionResultType]::ParameterName, 'Node compatibility mode. Currently only enables built-in node modules like ''fs'' and globals like ''process''.')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;completions' {
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;coverage' {
          [CompletionResult]::new('--ignore', 'ignore', [CompletionResultType]::ParameterName, 'Ignore coverage files')
          [CompletionResult]::new('--include', 'include', [CompletionResultType]::ParameterName, 'Include source files in the report')
          [CompletionResult]::new('--exclude', 'exclude', [CompletionResultType]::ParameterName, 'Exclude source files from the report')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--lcov', 'lcov', [CompletionResultType]::ParameterName, 'Output coverage report in lcov format')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;doc' {
          [CompletionResult]::new('--import-map', 'import-map', [CompletionResultType]::ParameterName, 'Load import map file')
          [CompletionResult]::new('-r', 'r', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--reload', 'reload', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--json', 'json', [CompletionResultType]::ParameterName, 'Output documentation in JSON format')
          [CompletionResult]::new('--private', 'private', [CompletionResultType]::ParameterName, 'Output private documentation')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;eval' {
          [CompletionResult]::new('--import-map', 'import-map', [CompletionResultType]::ParameterName, 'Load import map file')
          [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('--config', 'config', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('-r', 'r', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--reload', 'reload', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--lock', 'lock', [CompletionResultType]::ParameterName, 'Check the specified lock file')
          [CompletionResult]::new('--cert', 'cert', [CompletionResultType]::ParameterName, 'Load certificate authority from PEM encoded file')
          [CompletionResult]::new('--inspect', 'inspect', [CompletionResultType]::ParameterName, 'Activate inspector on host:port (default: 127.0.0.1:9229)')
          [CompletionResult]::new('--inspect-brk', 'inspect-brk', [CompletionResultType]::ParameterName, 'Activate inspector on host:port and break at start of user script')
          [CompletionResult]::new('--location', 'location', [CompletionResultType]::ParameterName, 'Value of ''globalThis.location'' used by some web APIs')
          [CompletionResult]::new('--v8-flags', 'v8-flags', [CompletionResultType]::ParameterName, 'Set V8 command line options (for help: --v8-flags=--help)')
          [CompletionResult]::new('--seed', 'seed', [CompletionResultType]::ParameterName, 'Seed Math.random()')
          [CompletionResult]::new('--ext', 'ext', [CompletionResultType]::ParameterName, 'Set standard input (stdin) content type')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--no-remote', 'no-remote', [CompletionResultType]::ParameterName, 'Do not resolve remote modules')
          [CompletionResult]::new('--no-check', 'no-check', [CompletionResultType]::ParameterName, 'Skip type checking modules')
          [CompletionResult]::new('--lock-write', 'lock-write', [CompletionResultType]::ParameterName, 'Write lock file (use with --lock)')
          [CompletionResult]::new('--cached-only', 'cached-only', [CompletionResultType]::ParameterName, 'Require that remote dependencies are already cached')
          [CompletionResult]::new('--enable-testing-features-do-not-use', 'enable-testing-features-do-not-use', [CompletionResultType]::ParameterName, 'INTERNAL: Enable internal features used during integration testing')
          [CompletionResult]::new('--compat', 'compat', [CompletionResultType]::ParameterName, 'Node compatibility mode. Currently only enables built-in node modules like ''fs'' and globals like ''process''.')
          [CompletionResult]::new('-T', 'T', [CompletionResultType]::ParameterName, 'Treat eval input as TypeScript')
          [CompletionResult]::new('--ts', 'ts', [CompletionResultType]::ParameterName, 'Treat eval input as TypeScript')
          [CompletionResult]::new('-p', 'p', [CompletionResultType]::ParameterName, 'print result to stdout')
          [CompletionResult]::new('--print', 'print', [CompletionResultType]::ParameterName, 'print result to stdout')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;fmt' {
          [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('--config', 'config', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('--ext', 'ext', [CompletionResultType]::ParameterName, 'Set standard input (stdin) content type')
          [CompletionResult]::new('--ignore', 'ignore', [CompletionResultType]::ParameterName, 'Ignore formatting particular source files')
          [CompletionResult]::new('--options-line-width', 'options-line-width', [CompletionResultType]::ParameterName, 'Define maximum line width. Defaults to 80.')
          [CompletionResult]::new('--options-indent-width', 'options-indent-width', [CompletionResultType]::ParameterName, 'Define indentation width. Defaults to 2.')
          [CompletionResult]::new('--options-prose-wrap', 'options-prose-wrap', [CompletionResultType]::ParameterName, 'Define how prose should be wrapped. Defaults to always.')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--check', 'check', [CompletionResultType]::ParameterName, 'Check if the source files are formatted')
          [CompletionResult]::new('--watch', 'watch', [CompletionResultType]::ParameterName, 'UNSTABLE: Watch for file changes and restart process automatically')
          [CompletionResult]::new('--options-use-tabs', 'options-use-tabs', [CompletionResultType]::ParameterName, 'Use tabs instead of spaces for indentation. Defaults to false.')
          [CompletionResult]::new('--options-single-quote', 'options-single-quote', [CompletionResultType]::ParameterName, 'Use single quotes. Defaults to false.')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;info' {
          [CompletionResult]::new('-r', 'r', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--reload', 'reload', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--cert', 'cert', [CompletionResultType]::ParameterName, 'Load certificate authority from PEM encoded file')
          [CompletionResult]::new('--location', 'location', [CompletionResultType]::ParameterName, 'Show files used for origin bound APIs like the Web Storage API when running a script with ''--location=<HREF>''')
          [CompletionResult]::new('--import-map', 'import-map', [CompletionResultType]::ParameterName, 'Load import map file')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--no-check', 'no-check', [CompletionResultType]::ParameterName, 'Skip type checking modules')
          [CompletionResult]::new('--json', 'json', [CompletionResultType]::ParameterName, 'UNSTABLE: Outputs the information in JSON format')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;install' {
          [CompletionResult]::new('--import-map', 'import-map', [CompletionResultType]::ParameterName, 'Load import map file')
          [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('--config', 'config', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('-r', 'r', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--reload', 'reload', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--lock', 'lock', [CompletionResultType]::ParameterName, 'Check the specified lock file')
          [CompletionResult]::new('--cert', 'cert', [CompletionResultType]::ParameterName, 'Load certificate authority from PEM encoded file')
          [CompletionResult]::new('--allow-read', 'allow-read', [CompletionResultType]::ParameterName, 'Allow file system read access')
          [CompletionResult]::new('--allow-write', 'allow-write', [CompletionResultType]::ParameterName, 'Allow file system write access')
          [CompletionResult]::new('--allow-net', 'allow-net', [CompletionResultType]::ParameterName, 'Allow network access')
          [CompletionResult]::new('--unsafely-ignore-certificate-errors', 'unsafely-ignore-certificate-errors', [CompletionResultType]::ParameterName, 'DANGER: Disables verification of TLS certificates')
          [CompletionResult]::new('--allow-env', 'allow-env', [CompletionResultType]::ParameterName, 'Allow environment access')
          [CompletionResult]::new('--allow-run', 'allow-run', [CompletionResultType]::ParameterName, 'Allow running subprocesses')
          [CompletionResult]::new('--allow-ffi', 'allow-ffi', [CompletionResultType]::ParameterName, 'Allow loading dynamic libraries')
          [CompletionResult]::new('--inspect', 'inspect', [CompletionResultType]::ParameterName, 'Activate inspector on host:port (default: 127.0.0.1:9229)')
          [CompletionResult]::new('--inspect-brk', 'inspect-brk', [CompletionResultType]::ParameterName, 'Activate inspector on host:port and break at start of user script')
          [CompletionResult]::new('--location', 'location', [CompletionResultType]::ParameterName, 'Value of ''globalThis.location'' used by some web APIs')
          [CompletionResult]::new('--v8-flags', 'v8-flags', [CompletionResultType]::ParameterName, 'Set V8 command line options (for help: --v8-flags=--help)')
          [CompletionResult]::new('--seed', 'seed', [CompletionResultType]::ParameterName, 'Seed Math.random()')
          [CompletionResult]::new('-n', 'n', [CompletionResultType]::ParameterName, 'Executable file name')
          [CompletionResult]::new('--name', 'name', [CompletionResultType]::ParameterName, 'Executable file name')
          [CompletionResult]::new('--root', 'root', [CompletionResultType]::ParameterName, 'Installation root')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--no-remote', 'no-remote', [CompletionResultType]::ParameterName, 'Do not resolve remote modules')
          [CompletionResult]::new('--no-check', 'no-check', [CompletionResultType]::ParameterName, 'Skip type checking modules')
          [CompletionResult]::new('--lock-write', 'lock-write', [CompletionResultType]::ParameterName, 'Write lock file (use with --lock)')
          [CompletionResult]::new('--allow-hrtime', 'allow-hrtime', [CompletionResultType]::ParameterName, 'Allow high resolution time measurement')
          [CompletionResult]::new('-A', 'A', [CompletionResultType]::ParameterName, 'Allow all permissions')
          [CompletionResult]::new('--allow-all', 'allow-all', [CompletionResultType]::ParameterName, 'Allow all permissions')
          [CompletionResult]::new('--prompt', 'prompt', [CompletionResultType]::ParameterName, 'Fallback to prompt if required permission wasn''t passed')
          [CompletionResult]::new('--cached-only', 'cached-only', [CompletionResultType]::ParameterName, 'Require that remote dependencies are already cached')
          [CompletionResult]::new('--enable-testing-features-do-not-use', 'enable-testing-features-do-not-use', [CompletionResultType]::ParameterName, 'INTERNAL: Enable internal features used during integration testing')
          [CompletionResult]::new('--compat', 'compat', [CompletionResultType]::ParameterName, 'Node compatibility mode. Currently only enables built-in node modules like ''fs'' and globals like ''process''.')
          [CompletionResult]::new('-f', 'f', [CompletionResultType]::ParameterName, 'Forcefully overwrite existing installation')
          [CompletionResult]::new('--force', 'force', [CompletionResultType]::ParameterName, 'Forcefully overwrite existing installation')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;uninstall' {
          [CompletionResult]::new('--root', 'root', [CompletionResultType]::ParameterName, 'Installation root')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;lsp' {
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;lint' {
          [CompletionResult]::new('--rules-tags', 'rules-tags', [CompletionResultType]::ParameterName, 'Use set of rules with a tag')
          [CompletionResult]::new('--rules-include', 'rules-include', [CompletionResultType]::ParameterName, 'Include lint rules')
          [CompletionResult]::new('--rules-exclude', 'rules-exclude', [CompletionResultType]::ParameterName, 'Exclude lint rules')
          [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('--config', 'config', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('--ignore', 'ignore', [CompletionResultType]::ParameterName, 'Ignore linting particular source files')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--rules', 'rules', [CompletionResultType]::ParameterName, 'List available rules')
          [CompletionResult]::new('--json', 'json', [CompletionResultType]::ParameterName, 'Output lint result in JSON format')
          [CompletionResult]::new('--watch', 'watch', [CompletionResultType]::ParameterName, 'UNSTABLE: Watch for file changes and restart process automatically')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;repl' {
          [CompletionResult]::new('--import-map', 'import-map', [CompletionResultType]::ParameterName, 'Load import map file')
          [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('--config', 'config', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('-r', 'r', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--reload', 'reload', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--lock', 'lock', [CompletionResultType]::ParameterName, 'Check the specified lock file')
          [CompletionResult]::new('--cert', 'cert', [CompletionResultType]::ParameterName, 'Load certificate authority from PEM encoded file')
          [CompletionResult]::new('--inspect', 'inspect', [CompletionResultType]::ParameterName, 'Activate inspector on host:port (default: 127.0.0.1:9229)')
          [CompletionResult]::new('--inspect-brk', 'inspect-brk', [CompletionResultType]::ParameterName, 'Activate inspector on host:port and break at start of user script')
          [CompletionResult]::new('--location', 'location', [CompletionResultType]::ParameterName, 'Value of ''globalThis.location'' used by some web APIs')
          [CompletionResult]::new('--v8-flags', 'v8-flags', [CompletionResultType]::ParameterName, 'Set V8 command line options (for help: --v8-flags=--help)')
          [CompletionResult]::new('--seed', 'seed', [CompletionResultType]::ParameterName, 'Seed Math.random()')
          [CompletionResult]::new('--eval', 'eval', [CompletionResultType]::ParameterName, 'Evaluates the provided code when the REPL starts.')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--no-remote', 'no-remote', [CompletionResultType]::ParameterName, 'Do not resolve remote modules')
          [CompletionResult]::new('--no-check', 'no-check', [CompletionResultType]::ParameterName, 'Skip type checking modules')
          [CompletionResult]::new('--lock-write', 'lock-write', [CompletionResultType]::ParameterName, 'Write lock file (use with --lock)')
          [CompletionResult]::new('--cached-only', 'cached-only', [CompletionResultType]::ParameterName, 'Require that remote dependencies are already cached')
          [CompletionResult]::new('--enable-testing-features-do-not-use', 'enable-testing-features-do-not-use', [CompletionResultType]::ParameterName, 'INTERNAL: Enable internal features used during integration testing')
          [CompletionResult]::new('--compat', 'compat', [CompletionResultType]::ParameterName, 'Node compatibility mode. Currently only enables built-in node modules like ''fs'' and globals like ''process''.')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;run' {
          [CompletionResult]::new('--import-map', 'import-map', [CompletionResultType]::ParameterName, 'Load import map file')
          [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('--config', 'config', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('-r', 'r', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--reload', 'reload', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--lock', 'lock', [CompletionResultType]::ParameterName, 'Check the specified lock file')
          [CompletionResult]::new('--cert', 'cert', [CompletionResultType]::ParameterName, 'Load certificate authority from PEM encoded file')
          [CompletionResult]::new('--allow-read', 'allow-read', [CompletionResultType]::ParameterName, 'Allow file system read access')
          [CompletionResult]::new('--allow-write', 'allow-write', [CompletionResultType]::ParameterName, 'Allow file system write access')
          [CompletionResult]::new('--allow-net', 'allow-net', [CompletionResultType]::ParameterName, 'Allow network access')
          [CompletionResult]::new('--unsafely-ignore-certificate-errors', 'unsafely-ignore-certificate-errors', [CompletionResultType]::ParameterName, 'DANGER: Disables verification of TLS certificates')
          [CompletionResult]::new('--allow-env', 'allow-env', [CompletionResultType]::ParameterName, 'Allow environment access')
          [CompletionResult]::new('--allow-run', 'allow-run', [CompletionResultType]::ParameterName, 'Allow running subprocesses')
          [CompletionResult]::new('--allow-ffi', 'allow-ffi', [CompletionResultType]::ParameterName, 'Allow loading dynamic libraries')
          [CompletionResult]::new('--inspect', 'inspect', [CompletionResultType]::ParameterName, 'Activate inspector on host:port (default: 127.0.0.1:9229)')
          [CompletionResult]::new('--inspect-brk', 'inspect-brk', [CompletionResultType]::ParameterName, 'Activate inspector on host:port and break at start of user script')
          [CompletionResult]::new('--location', 'location', [CompletionResultType]::ParameterName, 'Value of ''globalThis.location'' used by some web APIs')
          [CompletionResult]::new('--v8-flags', 'v8-flags', [CompletionResultType]::ParameterName, 'Set V8 command line options (for help: --v8-flags=--help)')
          [CompletionResult]::new('--seed', 'seed', [CompletionResultType]::ParameterName, 'Seed Math.random()')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--no-remote', 'no-remote', [CompletionResultType]::ParameterName, 'Do not resolve remote modules')
          [CompletionResult]::new('--no-check', 'no-check', [CompletionResultType]::ParameterName, 'Skip type checking modules')
          [CompletionResult]::new('--lock-write', 'lock-write', [CompletionResultType]::ParameterName, 'Write lock file (use with --lock)')
          [CompletionResult]::new('--allow-hrtime', 'allow-hrtime', [CompletionResultType]::ParameterName, 'Allow high resolution time measurement')
          [CompletionResult]::new('-A', 'A', [CompletionResultType]::ParameterName, 'Allow all permissions')
          [CompletionResult]::new('--allow-all', 'allow-all', [CompletionResultType]::ParameterName, 'Allow all permissions')
          [CompletionResult]::new('--prompt', 'prompt', [CompletionResultType]::ParameterName, 'Fallback to prompt if required permission wasn''t passed')
          [CompletionResult]::new('--cached-only', 'cached-only', [CompletionResultType]::ParameterName, 'Require that remote dependencies are already cached')
          [CompletionResult]::new('--enable-testing-features-do-not-use', 'enable-testing-features-do-not-use', [CompletionResultType]::ParameterName, 'INTERNAL: Enable internal features used during integration testing')
          [CompletionResult]::new('--compat', 'compat', [CompletionResultType]::ParameterName, 'Node compatibility mode. Currently only enables built-in node modules like ''fs'' and globals like ''process''.')
          [CompletionResult]::new('--watch', 'watch', [CompletionResultType]::ParameterName, 'UNSTABLE: Watch for file changes and restart process automatically')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;test' {
          [CompletionResult]::new('--import-map', 'import-map', [CompletionResultType]::ParameterName, 'Load import map file')
          [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('--config', 'config', [CompletionResultType]::ParameterName, 'Load configuration file')
          [CompletionResult]::new('-r', 'r', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--reload', 'reload', [CompletionResultType]::ParameterName, 'Reload source code cache (recompile TypeScript)')
          [CompletionResult]::new('--lock', 'lock', [CompletionResultType]::ParameterName, 'Check the specified lock file')
          [CompletionResult]::new('--cert', 'cert', [CompletionResultType]::ParameterName, 'Load certificate authority from PEM encoded file')
          [CompletionResult]::new('--allow-read', 'allow-read', [CompletionResultType]::ParameterName, 'Allow file system read access')
          [CompletionResult]::new('--allow-write', 'allow-write', [CompletionResultType]::ParameterName, 'Allow file system write access')
          [CompletionResult]::new('--allow-net', 'allow-net', [CompletionResultType]::ParameterName, 'Allow network access')
          [CompletionResult]::new('--unsafely-ignore-certificate-errors', 'unsafely-ignore-certificate-errors', [CompletionResultType]::ParameterName, 'DANGER: Disables verification of TLS certificates')
          [CompletionResult]::new('--allow-env', 'allow-env', [CompletionResultType]::ParameterName, 'Allow environment access')
          [CompletionResult]::new('--allow-run', 'allow-run', [CompletionResultType]::ParameterName, 'Allow running subprocesses')
          [CompletionResult]::new('--allow-ffi', 'allow-ffi', [CompletionResultType]::ParameterName, 'Allow loading dynamic libraries')
          [CompletionResult]::new('--inspect', 'inspect', [CompletionResultType]::ParameterName, 'Activate inspector on host:port (default: 127.0.0.1:9229)')
          [CompletionResult]::new('--inspect-brk', 'inspect-brk', [CompletionResultType]::ParameterName, 'Activate inspector on host:port and break at start of user script')
          [CompletionResult]::new('--location', 'location', [CompletionResultType]::ParameterName, 'Value of ''globalThis.location'' used by some web APIs')
          [CompletionResult]::new('--v8-flags', 'v8-flags', [CompletionResultType]::ParameterName, 'Set V8 command line options (for help: --v8-flags=--help)')
          [CompletionResult]::new('--seed', 'seed', [CompletionResultType]::ParameterName, 'Seed Math.random()')
          [CompletionResult]::new('--ignore', 'ignore', [CompletionResultType]::ParameterName, 'Ignore files')
          [CompletionResult]::new('--fail-fast', 'fail-fast', [CompletionResultType]::ParameterName, 'Stop after N errors. Defaults to stopping after first failure.')
          [CompletionResult]::new('--filter', 'filter', [CompletionResultType]::ParameterName, 'Run tests with this string or pattern in the test name')
          [CompletionResult]::new('--shuffle', 'shuffle', [CompletionResultType]::ParameterName, '(UNSTABLE): Shuffle the order in which the tests are run')
          [CompletionResult]::new('--coverage', 'coverage', [CompletionResultType]::ParameterName, 'UNSTABLE: Collect coverage profile data into DIR')
          [CompletionResult]::new('-j', 'j', [CompletionResultType]::ParameterName, 'Number of parallel workers, defaults to # of CPUs when no value is provided. Defaults to 1 when the option is not present.')
          [CompletionResult]::new('--jobs', 'jobs', [CompletionResultType]::ParameterName, 'Number of parallel workers, defaults to # of CPUs when no value is provided. Defaults to 1 when the option is not present.')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--no-remote', 'no-remote', [CompletionResultType]::ParameterName, 'Do not resolve remote modules')
          [CompletionResult]::new('--no-check', 'no-check', [CompletionResultType]::ParameterName, 'Skip type checking modules')
          [CompletionResult]::new('--lock-write', 'lock-write', [CompletionResultType]::ParameterName, 'Write lock file (use with --lock)')
          [CompletionResult]::new('--allow-hrtime', 'allow-hrtime', [CompletionResultType]::ParameterName, 'Allow high resolution time measurement')
          [CompletionResult]::new('-A', 'A', [CompletionResultType]::ParameterName, 'Allow all permissions')
          [CompletionResult]::new('--allow-all', 'allow-all', [CompletionResultType]::ParameterName, 'Allow all permissions')
          [CompletionResult]::new('--prompt', 'prompt', [CompletionResultType]::ParameterName, 'Fallback to prompt if required permission wasn''t passed')
          [CompletionResult]::new('--cached-only', 'cached-only', [CompletionResultType]::ParameterName, 'Require that remote dependencies are already cached')
          [CompletionResult]::new('--enable-testing-features-do-not-use', 'enable-testing-features-do-not-use', [CompletionResultType]::ParameterName, 'INTERNAL: Enable internal features used during integration testing')
          [CompletionResult]::new('--compat', 'compat', [CompletionResultType]::ParameterName, 'Node compatibility mode. Currently only enables built-in node modules like ''fs'' and globals like ''process''.')
          [CompletionResult]::new('--no-run', 'no-run', [CompletionResultType]::ParameterName, 'Cache test modules, but don''t run tests')
          [CompletionResult]::new('--doc', 'doc', [CompletionResultType]::ParameterName, 'UNSTABLE: type check code blocks')
          [CompletionResult]::new('--allow-none', 'allow-none', [CompletionResultType]::ParameterName, 'Don''t return error code if no test files are found')
          [CompletionResult]::new('--watch', 'watch', [CompletionResultType]::ParameterName, 'UNSTABLE: Watch for file changes and restart process automatically')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;types' {
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;upgrade' {
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'The version to upgrade to')
          [CompletionResult]::new('--output', 'output', [CompletionResultType]::ParameterName, 'The path to output the updated version to')
          [CompletionResult]::new('--cert', 'cert', [CompletionResultType]::ParameterName, 'Load certificate authority from PEM encoded file')
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--dry-run', 'dry-run', [CompletionResultType]::ParameterName, 'Perform all checks without replacing old exe')
          [CompletionResult]::new('-f', 'f', [CompletionResultType]::ParameterName, 'Replace current exe even if not out-of-date')
          [CompletionResult]::new('--force', 'force', [CompletionResultType]::ParameterName, 'Replace current exe even if not out-of-date')
          [CompletionResult]::new('--canary', 'canary', [CompletionResultType]::ParameterName, 'Upgrade to canary builds')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
        'deno;help' {
          [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('--log-level', 'log-level', [CompletionResultType]::ParameterName, 'Set log level')
          [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
          [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
          [CompletionResult]::new('--unstable', 'unstable', [CompletionResultType]::ParameterName, 'Enable unstable features and APIs')
          [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Suppress diagnostic output')
          break
        }
      })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
    Sort-Object -Property ListItemText
  }
}
