local loaddir = {}

---Import (require) all files directly under `dir` as root path. At this time, pass `base` as the base path to the require function.
---@param dir string
---@param base string
---@param exclude string|table|nil
---@param callback function|nil - The return value of the module loaded by the require function is passed over as an argument, which can be used for processing.
---@return table|nil
loaddir.load_all = function(dir, base, exclude, callback)
  exclude = exclude or {}

  -- Likely being called from an `init` file, so always exclude it by default
  exclude['init'] = true

  -- libuv doesn't seem to like the string representing a link
  if dir and string.sub(dir, 1, 1) == '@' then
    -- Strip this off if present
    dir = string.sub(dir, 2)
  end

  local handle = vim.loop.fs_scandir(dir)
  local ret = {}

  if not handle then
    vim.notify('Error loading directory ' .. dir, vim.log.levels.ERROR, { title = 'module_loader' })
    return
  end

  local name, typ, success, req, ext, res

  while handle do
    name, typ = vim.loop.fs_scandir_next(handle)

    if not name then
      -- Done, nothing left
      break
    end

    ext = vim.fn.fnamemodify(name, ':e')
    req = vim.fn.fnamemodify(name, ':r')

    if ((ext == 'lua' and typ == 'file') or (typ == 'directory')) and not exclude[req] then
      success, res = pcall(require, base .. req)

      if success then
        ret[req] = res

        if callback and type(callback) == 'function' then
          callback(res)
        end
      else
        vim.notify('Error loading module ' .. req .. ' : ' .. res, vim.log.levels.ERROR, { title = 'module_loader' })
      end
    end
  end

  return ret
end

return loaddir
