if (Get-Command git -ErrorAction SilentlyContinue) {
  Remove-Item alias:gc -Force # already used by Get-Content
  Remove-Item alias:gl -Force # already used by Get-Location
  Remove-Item alias:gp -Force # already used by Get-ItemProperty

  @(
    @{ name = "cl"; option = "clone" }
    @{ name = "gitConf"; option = "config --global -e" }

    @{ name = "gc"; option = "commit" }
    @{ name = "gl"; option = "log --graph --date=short --decorate=short --pretty=format:'%Cgreen%h %Creset%cd %Cblue%cn %Cred%d %Creset%s'" }
    @{ name = "gp"; option = "push" }
    @{ name = "gpf"; option = "push --force" }

    @{ name = "ga"; option = "add" }
    @{ name = "gpl"; option = "pull" }
    @{ name = "gs"; option = "status --short" }
  ) |
  ForEach-Object {
    New-DynamicFunction -CommandName $_.name -FunctionBody  "git $($_.option) `$args"
  }
}
