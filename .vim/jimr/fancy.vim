" :W to sudo-write

command! W w !sudo tee % > /dev/null
set hlsearch

au WinLeave * set nocursorline nocursorcolumn
au WinEnter * set cursorline cursorcolumn
set cursorline cursorcolumn

highlight OverLength ctermbg=black ctermfg=red guibg=#592929
match OverLength /\%81v.\+/

"DoMatchParen
