if vim.fn.exists(vim.g.neovide) == 1 then
  vim.cmd [[
    set guifont=Monospace:h11
    let g:neovide_cursor_vfx_mode="wireframe"
    let g:neovide_transparency=0.6
    let g:neovide_cursor_vfx_mode = "railgun"
    function! FontSizePlus()
      let l:gf_size_whole = matchstr(&guifont, 'h\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole + 1
      let l:new_font_size = l:gf_size_whole
      let &guifont = substitute(&guifont, 'h\d\+$', 'h' . l:new_font_size, '')
    endfunction
    function! FontSizeMinus()
      let l:gf_size_whole = matchstr(&guifont, 'h\@<=\d\+$')
      let l:gf_size_whole = l:gf_size_whole - 1
      let l:new_font_size = l:gf_size_whole
      let &guifont = substitute(&guifont, 'h\d\+$', 'h' . l:new_font_size, '')
    endfunction
    function! FontSizeReset()
      let &guifont = substitute(&guifont, 'h\d\+$', 'h11', '')
    endfunction
    nnoremap <C-=> :call FontSizePlus()<CR>
    nnoremap <C--> :call FontSizeMinus()<CR>
    nnoremap <C-0> :call FontSizeReset()<CR>
  ]]
end
