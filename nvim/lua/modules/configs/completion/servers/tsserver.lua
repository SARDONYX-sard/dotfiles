local lspconfig = require 'lspconfig'

return {
  root_dir = lspconfig.util.root_pattern 'package.json',
}
