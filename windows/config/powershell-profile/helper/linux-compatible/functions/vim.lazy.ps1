if (Get-Command lvim -ErrorAction SilentlyContinue) {
  New-DynamicFunction -CommandName vim -FunctionBody  "lvim `$args"
}
elseif (Get-Command nvim -ErrorAction SilentlyContinue) {
  New-DynamicFunction -CommandName vim -FunctionBody  "nvim `$args"
}
