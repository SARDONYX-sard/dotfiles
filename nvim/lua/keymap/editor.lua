local bind = require 'keymap.bind'
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_callback = bind.map_callback
local et = bind.escape_termcode

local plug_map = {
  -- Plugin: accelerate-jk
  ['n|j'] = map_callback(function()
    return et '<Plug>(accelerated_jk_gj)'
  end):with_expr(),
  ['n|k'] = map_callback(function()
    return et '<Plug>(accelerated_jk_gk)'
  end):with_expr(),

  -- Plugin: nvim-bufdel
  ['n|<leader>c'] = map_cr('BufDel'):with_noremap():with_silent():with_desc 'buffer: Close current',
  ['n|<leader>bl'] = map_cr('BufDelOthers'):with_noremap():with_silent():with_desc 'buffer: Close others',

  -- Plugin: clever-f
  ['n|:'] = map_callback(function()
    return et '<Plug>(clever-f-repeat-forward)'
  end):with_expr(),
  ['n|,'] = map_callback(function()
    return et '<Plug>(clever-f-repeat-back)'
  end):with_expr(),

  -- Plugin: comment.nvim
  ['n|gcc'] = map_callback(function()
      return vim.v.count == 0 and et '<Plug>(comment_toggle_linewise_current)'
        or et '<Plug>(comment_toggle_linewise_count)'
    end)
    :with_silent()
    :with_noremap()
    :with_expr()
    :with_desc 'edit: Toggle comment for line',
  ['n|gbc'] = map_callback(function()
      return vim.v.count == 0 and et '<Plug>(comment_toggle_blockwise_current)'
        or et '<Plug>(comment_toggle_blockwise_count)'
    end)
    :with_silent()
    :with_noremap()
    :with_expr()
    :with_desc 'edit: Toggle comment for block',
  ['n|gc'] = map_cmd('<Plug>(comment_toggle_linewise)')
    :with_silent()
    :with_noremap()
    :with_desc 'edit: Toggle comment for line with operator',
  ['n|gb'] = map_cmd('<Plug>(comment_toggle_blockwise)')
    :with_silent()
    :with_noremap()
    :with_desc 'edit: Toggle comment for block with operator',
  ['x|gc'] = map_cmd('<Plug>(comment_toggle_linewise_visual)')
    :with_silent()
    :with_noremap()
    :with_desc 'edit: Toggle comment for line with selection',
  ['x|gb'] = map_cmd('<Plug>(comment_toggle_blockwise_visual)')
    :with_silent()
    :with_noremap()
    :with_desc 'edit: Toggle comment for block with selection',

  -- Plugin: diffview
  ['n|<leader>D'] = map_cr('DiffviewOpen'):with_silent():with_noremap():with_desc 'git: Show diff',
  ['n|<leader><leader>D'] = map_cr('DiffviewClose'):with_silent():with_noremap():with_desc 'git: Close diff',

  -- Plugin: vim-easy-align
  ['nx|gea'] = map_cr('EasyAlign'):with_desc 'edit: Align with delimiter',

  -- Plugin: hop
  ['nv|<leader>k'] = map_cmd('<Cmd>HopWord<CR>'):with_noremap():with_desc 'jump: Goto word',
  ['nv|<leader>j'] = map_cmd('<Cmd>HopLine<CR>'):with_noremap():with_desc 'jump: Goto line',
  -- ['nv|<leader>c'] = map_cmd('<Cmd>HopChar1<CR>'): with_noremap(): with_desc 'jump: Goto one char',
  -- ['nv|<leader>cc'] = map_cmd('<Cmd>HopChar2<CR>'): with_noremap(): with_desc 'jump: Goto two chars',

  -- Possession
  ['nv|<leader>sc'] = map_cr('PossessionClose'):with_noremap():with_desc 'Session: Close',
  ['nv|<leader>sd'] = map_cr('PossessionDelete'):with_noremap():with_desc 'Session: Delete',
  ['nv|<leader>sl'] = map_cr('Telescope possession list'):with_noremap():with_desc 'Session: List',
  ['nv|<leader>sr'] = map_cr('PossessionLoad'):with_noremap():with_desc 'Session: Load',
  ['nv|<leader>ss'] = map_callback(vim.g.save_with_leaf_dir):with_noremap():with_desc 'Session: Save',

  -- Plugin: treehopper
  ['o|m'] = map_cu("lua require('tsht').nodes()"):with_silent():with_desc 'jump: Operate across syntax tree',

  -- Plugin: tabout
  ['i|<A-l>'] = map_cmd('<Plug>(TaboutMulti)'):with_silent():with_noremap():with_desc 'edit: Goto end of pair',
  ['i|<A-h>'] = map_cmd('<Plug>(TaboutBackMulti)'):with_silent():with_noremap():with_desc 'edit: Goto begin of pair',
}

bind.nvim_load_mapping(plug_map)
