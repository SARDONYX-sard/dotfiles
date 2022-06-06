# if (Get-Command lvim -ErrorAction SilentlyContinue) {
#   New-DynamicFunction -CommandName vim -FunctionBody  "lvim `$args"
# }
# else
if (Get-Command nvim -ErrorAction SilentlyContinue) {
  New-DynamicFunction -CommandName vim -FunctionBody  "nvim `$args"
  New-DynamicFunction -CommandName vi -FunctionBody  "nvim `$args"
}
