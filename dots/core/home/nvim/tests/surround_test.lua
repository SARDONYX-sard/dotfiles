-- Run: nvim --headless -u NONE -l dots/core/home/nvim/tests/surround_test.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.rtp:prepend(root)
require('builtin.surround').setup()

local failed = 0
local function case(name, lines, cursor, keys, expected)
  vim.cmd('enew!')
  vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
  vim.cmd('let &undolevels = &undolevels') -- undo break (headless has no typed input)
  vim.api.nvim_win_set_cursor(0, cursor)
  local k = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(k, 'mx', false)
  local got = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  if vim.deep_equal(got, expected) then
    print('ok   ' .. name)
  else
    failed = failed + 1
    print(('FAIL %s\n  expected %s\n  got      %s'):format(name, vim.inspect(expected), vim.inspect(got)))
  end
end

-- add
case('ys word )', { 'hello world' }, { 1, 0 }, 'ysiw)', { '(hello) world' })
case('ys word ( spaced', { 'hello world' }, { 1, 0 }, 'ysiw(', { '( hello ) world' })
case('ys word quote', { 'hello world' }, { 1, 6 }, 'ysiw"', { 'hello "world"' })
case('ys multibyte', { '日本 語' }, { 1, 0 }, 'ysiw"', { '"日本" 語' })
case('ys tag', { 'hi' }, { 1, 0 }, 'ysiwtdiv class="x"<CR>', { '<div class="x">hi</div>' })
case('yss trims', { '  hello  ' }, { 1, 4 }, 'yss]', { '  [hello]  ' })
case('ys linewise multi', { 'a', 'b' }, { 1, 0 }, 'ysj}', { '{a', 'b}' })
case('visual S', { 'abc def' }, { 1, 0 }, 'viwS]', { '[abc] def' })
case('visual line S', { '  a', '  b' }, { 1, 0 }, 'VjS)', { '  (a', '  b)' })
case('ys dot repeat', { 'a b' }, { 1, 0 }, 'ysiw)W.', { '(a) (b)' })
case('ys cursor on open', { 'x abc' }, { 1, 3 }, 'ysiw]x', { 'x abc]' })

-- delete
case('ds )', { 'foo(bar)baz' }, { 1, 5 }, 'ds)', { 'foobarbaz' })
case('ds ( trims', { 'x = ( a )' }, { 1, 6 }, 'ds(', { 'x = a' })
case('ds on open bracket', { 'f(a)' }, { 1, 1 }, 'ds)', { 'fa' })
case('ds on close bracket', { 'f(a)' }, { 1, 3 }, 'ds)', { 'fa' })
case('ds nested picks inner', { '(a (b) c)' }, { 1, 4 }, 'ds)', { '(a b c)' })
case('ds nested picks outer', { '(a (b) c)' }, { 1, 1 }, 'ds)', { 'a (b) c' })
case('ds multiline', { '{', '  x', '}' }, { 2, 2 }, 'ds}', { '', '  x', '' })
case('ds quote', { "say 'hi' now" }, { 1, 5 }, "ds'", { 'say hi now' })
case('ds quote after cursor', { "x 'hi'" }, { 1, 0 }, "ds'", { 'x hi' })
case('ds no match', { 'abc' }, { 1, 1 }, 'ds)', { 'abc' })
case('ds dot repeat', { '((x))' }, { 1, 2 }, 'ds).', { 'x' })

-- change
case("cs ' \"", { "say 'hi' now" }, { 1, 5 }, [[cs'"]], { 'say "hi" now' })
case('cs ] )', { 'f(a, [b])' }, { 1, 6 }, 'cs])', { 'f(a, (b))' })
case('cs ( ] trims', { '( x )' }, { 1, 2 }, 'cs(]', { '[x]' })
case('cs ) ( adds spaces', { '(x)' }, { 1, 1 }, 'cs)(', { '( x )' })
case('cs to tag', { '(x)' }, { 1, 1 }, 'cs)tp<CR>', { '<p>x</p>' })
case('cs dot repeat', { '(a) (b)' }, { 1, 1 }, 'cs)]W.', { '[a] [b]' })

-- one undo step
case('undo is one step', { 'foo(bar)' }, { 1, 5 }, 'cs)]u', { 'foo(bar)' })

print(failed == 0 and 'ALL PASSED' or (failed .. ' FAILED'))
vim.cmd(failed == 0 and 'qa!' or 'cq!')
