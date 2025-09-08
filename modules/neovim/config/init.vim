set nu
set clipboard=unnamedplus
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab

let g:vimtex_view_method = 'zathura'
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

let g:tex_flavor = 'latex'
let g:vimtex_quickfix_mode=1
set conceallevel=2
let g:tex_conceal='abdmgs'
colorscheme darcula
let g:lightline = { 'colorscheme': 'darculaOriginal' }
let g:UltiSnipsSnippetDirectories = ["~/.config/nvim/UltiSnips"]

autocmd VimEnter * :silent exec "!kill -s SIGWINCH $PPID"

" Дополнительные настройки для лучшей работы в Xorg
if has('clipboard')
set clipboard^=unnamed,unnamedplus
endif

" Настройки для корректного отображения в Xorg
set guifont=Monospace\ 12

" Дополнительные настройки vimtex
let g:vimtex_compiler_latexmk = {
    \ 'build_dir' : 'build',
    \ 'callback' : 1,
    \ 'continuous' : 1,
    \ 'executable' : 'latexmk',
    \ 'hooks' : [],
    \ 'options' : [
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \}