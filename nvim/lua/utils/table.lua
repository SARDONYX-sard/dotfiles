local M = {}

---Returns merged multi tables.
---@param ... table tables
---@return table
---
---# Example
---```lua
---local result = merge({ prefix = "hello" }, { suffix = "world" })
---assert(result == { prefix = "hello", suffix = "world" })
---```
---
---# References
--- - [merge two tables in lua](https://gist.github.com/qizhihere/cb2a14432d9bf65693ad)
function M.merge(...)
  local tables_to_merge = { ... }
  assert(#tables_to_merge > 1, 'There should be at least two tables to merge them')

  for k, t in ipairs(tables_to_merge) do
    assert(type(t) == 'table', string.format('Expected a table as function parameter %d', k))
  end

  local result = tables_to_merge[1]

  for i = 2, #tables_to_merge do
    local from = tables_to_merge[i]
    for k, v in pairs(from) do
      if type(k) == 'number' then
        table.insert(result, v)
      elseif type(k) == 'string' then
        if type(v) == 'table' then
          result[k] = result[k] or {}
          result[k] = M.merge(result[k], v)
        else
          result[k] = v
        end
      end
    end
  end

  return result
end

--- # Parameters
---@param common_plugins table -- VSCode & Neovim plugins
---@param nvim_only_plugins table
---@return table
---
---# Example
---```lua
---local common_plugins = { 'nvim-lualine/lualine.nvim' } --vscode & neovim
---local nvim_only_plugins = { 'lukas-reineke/indent-blankline.nvim' }
---local result = auto_select_for_vscode(common_plugins, nvim_only_plugins)
----- on VSCode Neovim
---assert(result == { 'nvim-lualine/lualine.nvim' })
----- on Neovim
---assert(result == { 'nvim-lualine/lualine.nvim', 'lukas-reineke/indent-blankline.nvim' })
---```
function M.auto_select_for_vscode(common_plugins, nvim_only_plugins)
  if vim.g.vscode then
    return common_plugins
  end

  return M.merge(common_plugins, nvim_only_plugins)
end

---For debuging tool.
---
---# Parameter
---@param node table - Table that you usually want to output as standard output.
---
---# Why use this?
--- Table is usually used because it could not be standard output and was difficult to debug.
---
---# Example
---```lua
---local table = { 'lukas-reineke/indent-blankline.nvim' }
-----> table = {'nvim-lualine/lualine.nvim'}
---```
---
---# References
---- https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
function M.print_table(node)
  local cache, stack, output = {}, {}, {}
  local depth = 1
  local output_str = '{\n'

  while true do
    local size = 0
    for _, _ in pairs(node) do
      size = size + 1
    end

    local cur_index = 1
    for k, v in pairs(node) do
      if (cache[node] == nil) or (cur_index >= cache[node]) then
        if string.find(output_str, '}', output_str:len()) then
          output_str = output_str .. ',\n'
        elseif not (string.find(output_str, '\n', output_str:len())) then
          output_str = output_str .. '\n'
        end

        -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
        table.insert(output, output_str)
        output_str = ''

        local key
        if type(k) == 'number' or type(k) == 'boolean' then
          key = '[' .. tostring(k) .. ']'
        else
          key = "['" .. tostring(k) .. "']"
        end

        if type(v) == 'number' or type(v) == 'boolean' then
          output_str = output_str .. string.rep('\t', depth) .. key .. ' = ' .. tostring(v)
        elseif type(v) == 'table' then
          output_str = output_str .. string.rep('\t', depth) .. key .. ' = {\n'
          table.insert(stack, node)
          table.insert(stack, v)
          cache[node] = cur_index + 1
          break
        else
          output_str = output_str .. string.rep('\t', depth) .. key .. " = '" .. tostring(v) .. "'"
        end

        if cur_index == size then
          output_str = output_str .. '\n' .. string.rep('\t', depth - 1) .. '}'
        else
          output_str = output_str .. ','
        end
      else
        -- close the table
        if cur_index == size then
          output_str = output_str .. '\n' .. string.rep('\t', depth - 1) .. '}'
        end
      end

      cur_index = cur_index + 1
    end

    if size == 0 then
      output_str = output_str .. '\n' .. string.rep('\t', depth - 1) .. '}'
    end

    if #stack > 0 then
      node = stack[#stack]
      stack[#stack] = nil
      depth = cache[node] == nil and depth + 1 or depth - 1
    else
      break
    end
  end

  -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
  table.insert(output, output_str)
  output_str = table.concat(output)

  print(output_str)
end

---Imports the array given by require as a path and returns a concatenated table of field names.
---@param dirs string[] -- Root path to lua files.
---@param field string -- Field name(neovim only supports plugin names)
---@param field2 string|nil -- Field names that may be read even when the `vscode` variable are defined.
---@return table
---
---# Example
---```lua
---local plugin_features = {}
---for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath 'config' .. '/lua/plugins', [[v:val =~ '\.lua$']])) do
---  plugin_features[#plugin_features + 1] = file:gsub('%.lua$', '')
---end
---concat_fields(plugin_features, 'plugins', 'common_plugins')
---```
function M.concat_fields(dirs, field, field2)
  local new_table = {}

  for _, dir in ipairs(dirs) do
    (function()
      local module = require(field .. '.' .. dir)
      -- local ok, module = pcall(require, field .. '.' .. dir)
      -- if not ok then
      -- vim.notify("Couldn't load " .. dir, vim.log.levels.ERROR, { title = 'Your init.lua' })
      -- return
      -- end
      local next_tables = module[field]
      if module[field2] then
        next_tables = M.auto_select_for_vscode(module[field2], module[field])
      end

      table.insert(new_table, next_tables)
    end)()
  end
  return new_table
end

return M
