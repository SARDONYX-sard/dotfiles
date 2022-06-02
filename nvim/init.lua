--[[
  GPL-3.0 license
  Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>

  Lunarvim: https://github.com/LunarVim/LunarVim/blob/rolling/LICENSE
]]

local base_dir = os.getenv("AppData") .. "\\lunarvim"

if not vim.tbl_contains(vim.opt.rtp:get(), base_dir) then
  vim.opt.rtp:append(base_dir)
end

require("lvim.bootstrap"):init(base_dir)

require("lvim.config"):load()

local plugins = require "lvim.plugins"
require("lvim.plugin-loader").load { plugins, lvim.plugins }

local Log = require "lvim.core.log"
Log:debug "Starting LunarVim"

local commands = require "lvim.core.commands"
commands.load(commands.defaults)

require("lvim.lsp").setup()
