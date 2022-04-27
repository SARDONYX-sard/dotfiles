if (Get-Command waifu2x-ncnn-vulkan -ErrorAction SilentlyContinue) {
  function to4k () {
    param (
      [Parameter()]
      [String]$i,
      [String]$ImagePath = $i,
      [String]$o = "./output/$(Split-Path $i -Leaf)",
      [String]$OutputPath = $o
    )
    mkdir -p $(Split-Path $OutputPath)
    Write-Host "Output path: $OutputPath"
    waifu2x-ncnn-vulkan -i $ImagePath -o $OutputPath -n 2 -s 2
  }
}

if (Get-Command magisk -ErrorAction SilentlyContinue) {
  function Convert-Img {
    param (
      [Parameter()]
      [String]$p = "*.png",
      [String]$ImagePath,
      [String]$o = "jpg",
      [String]$Output,
      [Switch]$h,
      [Switch]$Help
    )

    if ($Help) {
      Write-Host @"
    Convert image to other format.

    Usage:
      Convert-Img [options] [path]

    Options:
      -p, --path     [string]  Path to image. glob or a file. default: *.png
      -o, --output   [string]  Output format. default: jpg
      -h, --help     [switch]  Show help.
"@
    }

    if ($p) { $ImagePath = $p }
    if ($o) { $Output = $o }

    $images = Get-ChildItem -Path $ImagePath -Recurse | Write-Output
    foreach ($image in $images) {
      $OutputFile = [io.path]::ChangeExtension($image, $o)
      magick $image  $OutputFile
    }
  }
}
