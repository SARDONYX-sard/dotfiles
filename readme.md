# dotfiles

[日本語](./docs/i18n/jp/readme.md)

- This project is currently under development. If you run it carelessly, you may get errors.

## Table of Contents

- [dotfiles](#dotfiles)
  - [Table of Contents](#table-of-contents)
  - [Complete the builder](#complete-the-builder)
  - [Incomplete](#incomplete)
  - [Warning'!'](#warning)
  - [Things you have to do manually](#things-you-have-to-do-manually)
  - [Workarounds I've done for coding](#workarounds-ive-done-for-coding)
  - [Reference sites](#reference-sites)
  - [License](#license)

## Complete the builder

- Windows settings

## Incomplete

- Linux settings

## Warning'!'

- This is the setup repository for my development environment.
  If you do not know what you are doing, do not run this code unnecessarily.
  If you run it easily, your current development environment will be overwritten by my development environment settings.

- Some settings are in Japanese and may not be suitable for English speakers.

- This project is based on the dotfiles project from [here](https://github.com/LumaKernel/dotfiles).
  A huge thanks to him...

## Things you have to do manually

- Rewrite the `user` setting in `.gitconfig`.

- Install [PowerShell-WSL-Interop](https://github.com/mikebattista/PowerShell-WSL-Interop).

## Workarounds I've done for coding

Some of them are left in the comments, but I'll include them here as well.

- In `git clone`, `~` is not expanded and becomes a directory called `~`. For this reason, we use the `$HOME` variable.
- Running the `ps1` file did not expand `$HOME`, so the `~` variable is used.

## Reference sites

- <https://github.com/LumaKernel/dotfiles>

## License

Unlicense
