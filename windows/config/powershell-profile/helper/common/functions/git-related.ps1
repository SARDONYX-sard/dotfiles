if (Get-Command git -ErrorAction SilentlyContinue) {
  Remove-Item alias:gc -Force # already used by Get-Content
  Remove-Item alias:gl -Force # already used by Get-Location
  Remove-Item alias:gp -Force # already used by Get-ItemProperty

  @(
    @{ name = "cl"; option = "clone" }
    @{ name = "gitConf"; option = "config --global -e" }

    @{ name = "gc"; option = "commit" }
    @{ name = "gl"; option = "log" }
    @{ name = "gp"; option = "push" }

    @{ name = "ga"; option = "add" }
    @{ name = "gpl"; option = "pull" }
    @{ name = "gs"; option = "status --short" }
  )
  | ForEach-Object {
    New-DynamicFunction -CommandName $_.name -FunctionBody  "git $_.option `$args"
  }
}
