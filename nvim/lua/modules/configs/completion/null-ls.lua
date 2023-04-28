return function()
  local null_ls = require 'null-ls'
  local mason_null_ls = require 'mason-null-ls'
  local btns = null_ls.builtins

  -- Trigger specific files or folders to prevent conflicts with `denols`.
  local prevenet_conflict_deno_lint = function(utils)
    return vim.fn.executable 'eslint_d' > 0
      and utils.root_has_file { 'package.json' }
      and not utils.root_has_file { 'deno.json' }
  end
  local prevenet_conflict_deno_fmt = function(executable_cmd)
    return function(utils)
      return vim.fn.executable(executable_cmd) > 0 and utils.root_has_file { 'deno.json' }
    end
  end

  -- Please set additional flags for the supported servers here
  -- Don't specify any config here if you are using the default one.
  local sources = {
    -- With override configurations
    btns.code_actions.eslint_d.with { condition = prevenet_conflict_deno_lint }, -- js, ts linter
    btns.diagnostics.eslint_d.with { condition = prevenet_conflict_deno_lint }, -- js, ts linter
    btns.diagnostics.luacheck.with { extra_args = { '--globals', 'vim', '--globals', 'awesome' } }, -- static type check of lua
    -- NOTE: Comment out because for some reason the setting cannot be overwritten
    --
    -- btns.diagnostics.cspell.with { -- spell checker(need `npm`(node.js)
    --   diagnostics_postprocess = function(diagnostic)
    --     diagnostic.severity = vim.diagnostic.severity['INFO']
    --   end,
    --   condition = function()
    --     return vim.fn.executable 'cspell' > 0
    --   end,
    -- },
    btns.formatting.prettierd.with { condition = prevenet_conflict_deno_fmt 'prettierd' }, -- frontend fmt
    btns.formatting.deno_fmt.with { condition = prevenet_conflict_deno_fmt 'deno' }, -- js runtime env by Rust
    btns.formatting.black.with { extra_args = { '--fast' } }, -- python fmt
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
