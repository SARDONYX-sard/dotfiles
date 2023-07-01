return function()
  local null_ls = require 'null-ls'
  local mason_null_ls = require 'mason-null-ls'
  local btns = null_ls.builtins

  -- Trigger specific files or folders to prevent conflicts with `denols`.
  local prevent_conflict_deno_lint = function(utils)
    return vim.fn.executable 'eslint_d' > 0
      and utils.root_has_file { 'package.json' }
      and not utils.root_has_file { 'deno.json' }
  end
  ---@param executable_cmd string
  ---@return function
  local prevent_conflict_deno_fmt = function(executable_cmd)
    return function(utils)
      return vim.fn.executable(executable_cmd) > 0 and utils.root_has_file { 'deno.json' }
    end
  end

  local executable_cspell = function()
    return vim.fn.executable 'cspell' > 0
  end

  ---@param diag_level  'INFO'|'DEBUG'|'WARN'|'ERROR'
  local set_diag_level = function(diag_level)
    ---@param diagnostic table<string, string>
    return function(diagnostic)
      diagnostic.severity = vim.diagnostic.severity[diag_level]
    end
  end

  -- Please set additional flags for the supported servers here
  -- Don't specify any config here if you are using the default one.

  -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/code_actions
  local sources = {
    -- With override configurations

    -- spell checker(need `npm`(node.js)
    btns.code_actions.cspell.with { condition = executable_cspell },
    btns.diagnostics.cspell.with { diagnostics_postprocess = set_diag_level 'INFO', condition = executable_cspell },
    -- js, ts linter
    btns.code_actions.eslint_d.with { condition = prevent_conflict_deno_lint },
    btns.diagnostics.eslint_d.with { condition = prevent_conflict_deno_lint },

    btns.formatting.deno_fmt.with { condition = prevent_conflict_deno_fmt 'deno' }, -- js runtime env by Rust
    btns.formatting.prettierd.with { condition = prevent_conflict_deno_fmt 'prettierd' }, -- frontend fmt

    -- lua
    btns.diagnostics.luacheck.with { extra_args = { '--globals', 'vim', '--globals', 'awesome' } }, -- static type check of lua

    -- python
    btns.formatting.black.with { extra_args = { '--fast' } },

    btns.formatting.clang_format.with {
      filetypes = { 'c', 'cpp' },
      extra_args = require 'completion.formatters.clang_format',
    },
  }

  null_ls.setup {
    border = 'rounded',
    debug = false,
    log_level = 'warn',
    update_in_insert = false,
    sources = sources,
  }

  mason_null_ls.setup {
    ensure_installed = require('core.settings').null_ls_deps,
    automatic_installation = false,
    automatic_setup = true,
    handlers = {},
  }

  require('modules.configs.completion.formatting').configure_format_on_save()
end
