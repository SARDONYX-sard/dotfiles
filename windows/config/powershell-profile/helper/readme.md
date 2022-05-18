# Helper files

## index.ps1

- Automatically reads files in helper directories external-modules-settings and
  linux-compatible and powershell-only.

## index.lazy.ps1

- Automatically performs delayed loading of files in helper directories
  external-modules-settings and linux-compatible and powershell-only.

- You can use `lazy.ps1` extension for automatic lazy loading.

- Only some functions added dynamically by New-DynamicFunction, module settings,
  tab completion, etc. can be lazy-loaded. Normal functions will fail to load
  lazily.