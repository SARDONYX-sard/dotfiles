-- Minimal, dependency-free surround (replaces nvim-surround).
--
--   ys{motion}{char}  add around motion        yss{char}  add around line content
--   S{char} (visual)  add around selection     ds{char}   delete surrounding pair
--   cs{old}{new}      change surrounding pair  t         HTML tag (asks for name)
--
-- Opening brackets ( [ { < add inner spaces; closing ones ) ] } > and aliases
-- b B r a do not. `ds(` also trims inner spaces.
--
-- Edits go through nvim_buf_set_text only: one undo step, no visual-mode round
-- trips (keeps vscode-neovim in sync), and `.` repeats via operatorfunc.
--
-- Coordinates: "row1" = 1-based row (nvim_win_get_cursor / marks),
-- "row0"/"col0" = 0-based (nvim_buf_set_text). Columns are byte offsets.

---@alias surround.Pos [integer, integer, integer, integer] row0/col0 of the open char, row0/col0 of the close char
---@alias surround.OpKind 'char'|'line'|'block' operatorfunc motion type

---@class surround.State
---@field add string? char for ys (cached for `.` repeat)
---@field del string? char for ds
---@field change [string, string]? old/new chars for cs

---@class surround
local M = {}

local api = vim.api

---@type table<string, [string, string]>
local brackets = {
  ['('] = { '(', ')' },
  [')'] = { '(', ')' },
  b = { '(', ')' },
  ['['] = { '[', ']' },
  [']'] = { '[', ']' },
  r = { '[', ']' },
  ['{'] = { '{', '}' },
  ['}'] = { '{', '}' },
  B = { '{', '}' },
  ['<'] = { '<', '>' },
  ['>'] = { '<', '>' },
  a = { '<', '>' },
}

--- Opening chars that add/trim inner spaces.
---@type table<string, true>
local spaced = { ['('] = true, ['['] = true, ['{'] = true, ['<'] = true }

--- Read one key.
---@return string? key nil on <Esc>/<C-c>
local function getchar()
  local ok, c = pcall(vim.fn.getcharstr)
  if not ok or c == '\27' or c == '\3' then return nil end
  return c
end

--- Text to insert for `ch`.
---@param ch string
---@return string? open nil when cancelled (empty tag name)
---@return string? close
local function delimiters(ch)
  if ch == 't' then
    local tag = vim.fn.input('Tag: ')
    if tag == '' then return nil end
    return '<' .. tag .. '>', '</' .. tag:match('^%S+') .. '>'
  end
  local pair = brackets[ch]
  if pair then
    if spaced[ch] then return pair[1] .. ' ', ' ' .. pair[2] end
    return pair[1], pair[2]
  end
  return ch, ch
end

---@param row1 integer
---@return string
local function line_text(row1)
  return api.nvim_buf_get_lines(0, row1 - 1, row1, true)[1]
end

--- Byte index just past the (possibly multibyte) character starting at `col0`.
---@param line string
---@param col0 integer
---@return integer
local function char_end(line, col0)
  if col0 >= #line then return #line end
  return col0 + 1 + vim.str_utf_end(line, col0 + 1)
end

--- Leading-whitespace byte count.
---@param s string
---@return integer
local function indent_len(s)
  return #s:match('^%s*')
end

--- Byte length without trailing whitespace.
---@param s string
---@return integer
local function trimmed_len(s)
  return #(s:gsub('%s+$', ''))
end

--- Insert `open`/`close` around [srow0,scol0)..[erow0,ecol0) (end exclusive) and
--- put the cursor on the opening delimiter, like vim-surround.
---@param srow0 integer
---@param scol0 integer
---@param erow0 integer
---@param ecol0 integer
---@param open string
---@param close string
local function wrap(srow0, scol0, erow0, ecol0, open, close)
  api.nvim_buf_set_text(0, erow0, ecol0, erow0, ecol0, { close })
  api.nvim_buf_set_text(0, srow0, scol0, srow0, scol0, { open })
  api.nvim_win_set_cursor(0, { srow0 + 1, scol0 })
end

-- ---------------------------------------------------------------- finding pairs

--- Bracket pair enclosing the cursor (or with the cursor on one of its brackets).
--- Handles nesting and multiple lines via searchpairpos.
---@param open string
---@param close string
---@return surround.Pos?
local function find_bracket(open, close)
  local cur = api.nvim_win_get_cursor(0) -- { row1, col0 }
  local o, c = '\\V' .. open, '\\V' .. close
  ---@type [integer, integer] row1, col1 (searchpairpos is 1-based)
  local start
  if line_text(cur[1]):sub(cur[2] + 1, cur[2] + 1) == open then
    start = { cur[1], cur[2] + 1 }
  else
    start = vim.fn.searchpairpos(o, '', c, 'bnW')
  end
  if start[1] == 0 then return nil end

  -- Search the match forward from the opening bracket, then restore the cursor.
  api.nvim_win_set_cursor(0, { start[1], start[2] - 1 })
  local finish = vim.fn.searchpairpos(o, '', c, 'nW')
  api.nvim_win_set_cursor(0, cur)
  if finish[1] == 0 then return nil end
  return { start[1] - 1, start[2] - 1, finish[1] - 1, finish[2] - 1 }
end

--- Pair of `q` on the cursor line enclosing the cursor, else the next one after it.
---@param q string
---@return surround.Pos?
local function find_same(q)
  local cur = api.nvim_win_get_cursor(0)
  local line = line_text(cur[1])
  ---@type integer[] col0 of every occurrence
  local idx, i = {}, 1
  while true do
    local s = line:find(q, i, true)
    if not s then break end
    idx[#idx + 1] = s - 1
    i = s + #q
  end
  ---@type surround.Pos?
  local fallback
  for k = 1, #idx - 1, 2 do
    local l, r = idx[k], idx[k + 1]
    if l <= cur[2] and cur[2] <= r then return { cur[1] - 1, l, cur[1] - 1, r } end
    if not fallback and l > cur[2] then fallback = { cur[1] - 1, l, cur[1] - 1, r } end
  end
  return fallback
end

--- Locate the pair for `ch`.
---@param ch string
---@return surround.Pos? pos
---@return string? open delimiter text as found in the buffer
---@return string? close
local function find(ch)
  local pair = brackets[ch]
  if pair then return find_bracket(pair[1], pair[2]), pair[1], pair[2] end
  if ch == 't' then
    vim.notify('surround: ds/cs on tags is not supported', vim.log.levels.WARN)
    return nil
  end
  return find_same(ch), ch, ch
end

--- Byte ranges to replace for the pair at `pos`: the open and close delimiters,
--- widened over inner whitespace when `trim` is set (`ds(` on `( x )`).
---@param pos surround.Pos
---@param open string
---@param close string
---@param trim boolean?
---@return integer srow0, integer ostart, integer oend, integer erow0, integer cstart, integer cend  end exclusive
local function pair_ranges(pos, open, close, trim)
  ---@diagnostic disable-next-line: deprecated
  local srow, scol, erow, ecol = unpack(pos)
  local ostart, oend = scol, scol + #open
  local cstart, cend = ecol, ecol + #close
  if trim then
    local sline, eline = line_text(srow + 1), line_text(erow + 1)
    local same = srow == erow
    while oend < #sline and sline:sub(oend + 1, oend + 1):match('%s') and not (same and oend >= cstart) do
      oend = oend + 1
    end
    while cstart > 0 and eline:sub(cstart, cstart):match('%s') and not (same and cstart <= oend) do
      cstart = cstart - 1
    end
  end
  return srow, ostart, oend, erow, cstart, cend
end

--- Replace the pair at `pos` with `new_open`/`new_close` ('' deletes it).
---@param pos surround.Pos
---@param open string
---@param close string
---@param trim boolean?
---@param new_open string
---@param new_close string
local function replace_pair(pos, open, close, trim, new_open, new_close)
  local srow, ostart, oend, erow, cstart, cend = pair_ranges(pos, open, close, trim)
  -- Close first so the open-side columns stay valid.
  api.nvim_buf_set_text(0, erow, cstart, erow, cend, { new_close })
  api.nvim_buf_set_text(0, srow, ostart, srow, oend, { new_open })
end

-- ------------------------------------------------------------------ operators

---@type surround.State
local state = {}

--- operatorfunc for ys / yss (and their `.` repeat).
---@param kind surround.OpKind
function M.add_op(kind)
  local ch = state.add
  if not ch then
    ch = getchar()
    if not ch then return end
    state.add = ch
  end
  local open, close = delimiters(ch)
  if not open or not close then return end

  local s, e = api.nvim_buf_get_mark(0, '['), api.nvim_buf_get_mark(0, ']')
  if kind == 'line' then
    wrap(s[1] - 1, indent_len(line_text(s[1])), e[1] - 1, trimmed_len(line_text(e[1])), open, close)
  elseif kind == 'char' then
    wrap(s[1] - 1, s[2], e[1] - 1, char_end(line_text(e[1]), e[2]), open, close)
  else
    vim.notify('surround: blockwise is not supported', vim.log.levels.WARN)
  end
end

--- operatorfunc for ds (invoked via `g@l` so `.` repeats).
function M.del_op()
  local ch = state.del
  if not ch then return end
  local pos, open, close = find(ch)
  if not pos or not open or not close then return end
  replace_pair(pos, open, close, spaced[ch], '', '')
end

--- operatorfunc for cs (invoked via `g@l` so `.` repeats).
function M.change_op()
  if not state.change then return end
  local old, new = state.change[1], state.change[2]
  local pos, o, c = find(old)
  if not pos or not o or not c then return end
  local open, close = delimiters(new)
  if not open or not close then return end
  replace_pair(pos, o, c, spaced[old], open, close)
end

-- -------------------------------------------------------------------- mappings

--- Install the ys / yss / ds / cs / S mappings.
function M.setup()
  local map = vim.keymap.set

  ---@param name string
  ---@return string
  local function opfunc(name)
    return "v:lua.require'builtin.surround'." .. name
  end

  map('n', 'ys', function()
    state.add = nil
    vim.o.operatorfunc = opfunc('add_op')
    return 'g@'
  end, { expr = true, desc = 'Surround: add (motion)' })

  map('n', 'yss', function()
    state.add = nil
    vim.o.operatorfunc = opfunc('add_op')
    return 'g@_'
  end, { expr = true, desc = 'Surround: add (line)' })

  map('n', 'ds', function()
    local ch = getchar()
    if not ch then return '' end
    state.del = ch
    vim.o.operatorfunc = opfunc('del_op')
    return 'g@l'
  end, { expr = true, desc = 'Surround: delete' })

  map('n', 'cs', function()
    local old = getchar()
    if not old then return '' end
    local new = getchar()
    if not new then return '' end
    state.change = { old, new }
    vim.o.operatorfunc = opfunc('change_op')
    return 'g@l'
  end, { expr = true, desc = 'Surround: change' })

  map('x', 'S', function()
    local mode = vim.fn.mode()
    local ch = getchar()
    if not ch then return end
    api.nvim_feedkeys('\27', 'nx', false) -- leave visual so '< '> are set
    local open, close = delimiters(ch)
    if not open or not close then return end
    local s, e = api.nvim_buf_get_mark(0, '<'), api.nvim_buf_get_mark(0, '>')
    if mode == 'V' then
      wrap(s[1] - 1, indent_len(line_text(s[1])), e[1] - 1, trimmed_len(line_text(e[1])), open, close)
    elseif mode == 'v' then
      wrap(s[1] - 1, s[2], e[1] - 1, char_end(line_text(e[1]), e[2]), open, close)
    else
      vim.notify('surround: blockwise is not supported', vim.log.levels.WARN)
    end
  end, { desc = 'Surround: add (visual)' })
end

return M
