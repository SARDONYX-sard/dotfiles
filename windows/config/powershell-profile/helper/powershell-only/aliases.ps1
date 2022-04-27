@(
  @{ name = "scoop"; alias_name = "s" }
  @{ name = "waihu2x-ncnn-vulkan"; alias_name = "chimg" }
  @{ name = "uutils"; alias_name = "u" } # Rust uutils https://github.com/uutils/coreutils

  @{ name = "$HOME\.local\bin\lvim.ps1"; alias_name = "lvim" }

  # Node.js
  @{ name = "npm"; alias_name = "np" }
  @{ name = "pnpm"; alias_name = "pn" }
  @{ name = "yarn"; alias_name = "ya" }
) |
ForEach-Object {
  if (Get-Command $_.name -ErrorAction SilentlyContinue) { Set-Alias $_.alias_name $_.name }
}

Set-Alias wh which
