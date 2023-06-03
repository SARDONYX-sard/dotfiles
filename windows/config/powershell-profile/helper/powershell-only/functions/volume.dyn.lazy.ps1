Get-ChildItem |
Select-Object Name, @{ name = "Size"; expression = {
    [math]::round((Get-ChildItem $_.FullName -Recurse -Force |
        Measure-Object Length -Sum).Sum / 1.0MB).ToString() + " MiB"
  }
}
