local bind = require 'keymap.bind'
local map_callback = bind.map_callback

local crates_keymap = {
  ['n|<leader><leader>ct'] = map_callback(function()
      require('crates').toggle()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc 'crates: Toggle spec activities',
  ['n|<leader><leader>cr'] = map_callback(function()
      require('crates').reload()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc 'crates: Reload crate specs',

  ['n|<leader><leader>cs'] = map_callback(function()
      require('crates').show_popup()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc 'crates: Toggle pop-up window',
  ['n|<leader><leader>cv'] = map_callback(function()
      require('crates').show_versions_popup()
      require('crates').show_popup()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc 'crates: Select spec versions',
  ['n|<leader><leader>cf'] = map_callback(function()
      require('crates').show_features_popup()
      require('crates').show_popup()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc 'crates: Select spec features',
  ['n|<leader><leader>cd'] = map_callback(function()
      require('crates').show_dependencies_popup()
      require('crates').show_popup()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc 'crates: Show project dependencies',

  ['n|<leader><leader>cu'] = map_callback(function()
      require('crates').update_crate()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc "crates: Update current crate's spec",
  ['v|<leader><leader>cu'] = map_callback(function()
      require('crates').update_crates()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc "crates: Update selected crate's spec",
  ['n|<leader><leader>ca'] = map_callback(function()
      require('crates').update_all_crates()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc "crates: Update all crates' specs",
  ['n|<leader><leader>cU'] = map_callback(function()
      require('crates').upgrade_crate()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc 'crates: Upgrade current crate',
  ['v|<leader><leader>cU'] = map_callback(function()
      require('crates').upgrade_crates()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc 'crates: Upgrade selected crates',
  ['n|<leader><leader>cA'] = map_callback(function()
      require('crates').upgrade_all_crates()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc 'crates: Upgrade all crates',

  ['n|<leader><leader>cH'] = map_callback(function()
      require('crates').open_homepage()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc "crates: Open current crate's homepage",
  ['n|<leader><leader>cR'] = map_callback(function()
      require('crates').open_repository()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc "crates: Open current crate's repository",
  ['n|<leader><leader>cD'] = map_callback(function()
      require('crates').open_documentation()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc "crates: Open current crate's documentation",
  ['n|<leader><leader>cC'] = map_callback(function()
      require('crates').open_crates_io()
    end)
    :with_noremap()
    :with_silent()
    :with_buffer(0)
    :with_desc 'crates: Browse current crate on crates.io',
}

bind.nvim_load_mapping(crates_keymap)
