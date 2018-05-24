""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Options

set encoding=utf-8
set background=dark
set ruler
set backspace=indent,eol,start
set nohlsearch noincsearch
set mouse=
set nofoldenable
set hidden
set history=1000
set wildmenu wildmode=list:longest
set shortmess=aoOtTI
set undofile undodir=~/.local/share/nvim/undodir,.
set nomodeline " security
set re=1 " fix a bug with the Ruby syntax highlighting

colorscheme desert

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Mappings

let mapleader = ','

" Abbreviations
iabbrev <expr> isodate strftime('%Y-%m-%d')
iabbrev <expr> isotime strftime('%Y-%m-%dT%H:%M:%S%z')

" Command mode
cnoremap <C-B> <Left>
cnoremap <C-F> <Right>
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>
cnoremap <C-D> <Delete>
cnoremap <Esc>b <S-Left>
cnoremap <Esc>f <S-Right>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Advanced features

" When editing a file, always jump to the last cursor position
augroup cursor_position
  autocmd!
  autocmd BufReadPost *
        \ if line("'\"") ># 0 && line("'\"") <=# line('$') |
        \   exe "normal! g'\"" |
        \ endif
augroup END

" SudoWrite
" Source: https://github.com/tpope/vim-eunuch
command! -bar SudoWrite :
      \ setlocal nomodified |
      \ silent exe 'write !sudo tee % >/dev/null' |
      \ let &modified = v:shell_error
cabbrev <silent> w!! SudoWrite

" Show trailing characters, but not in insert mode
highlight ExtraneousWhitespace ctermbg=DarkRed
" match whitespace at the end of a line and spaces before a tab
match ExtraneousWhitespace /\s\+$\| \+\ze\t/
augroup trailing
  autocmd!
  autocmd InsertEnter * :highlight ExtraneousWhitespace NONE
  autocmd InsertLeave * :highlight ExtraneousWhitespace ctermbg=DarkRed
augroup END

" Unlimited inteprocess paste buffer
nnoremap <silent> <Leader>y :.!tee ~/.vimipc<CR>
vnoremap <silent> <Leader>y :!tee ~/.vimipc<CR>
nnoremap <silent> <Leader>d :.!> ~/.vimipc<CR>
vnoremap <silent> <Leader>d :!> ~/.vimipc<CR>
nnoremap <silent> <Leader>p :r ~/.vimipc<CR>
nnoremap <silent> <Leader>P :-1r ~/.vimipc<CR>

" Blame
nnoremap <silent> <Leader>B :echo system('git blame -L'.line('.').',+1 '.expand('%'))<CR>
" Yank from HEAD (aka per-line checkout from HEAD)
nnoremap <silent> <Leader>Y :exe 'norm! 0C'.system('git blame -pL'.line('.').',+1 HEAD '.expand('%').'<Bar>tail -n1 <Bar>cut -c2-<Bar>tr -d "\n"')<CR>0

" diary
nmap <silent> <Leader>_ G<Leader>pO<Esc><Gjsisodate<Esc>ztVG:s/  /    /g<CR>

" php-cs-fixer
nmap <Leader>f :!php-cs-fixer fix %<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Syntax, indenting, etc.

" Indenting
set autoindent nocindent smarttab
set shiftwidth=2 softtabstop=2 expandtab

" Syntax
syntax on
filetype plugin indent on
autocmd VimEnter * colorscheme default

" Python
augroup python
  autocmd!
  autocmd FileType python setlocal shiftwidth=4 softtabstop=4
  autocmd FileType python syntax match Error "\t"
augroup END

" SCSS
augroup scss
  autocmd!
  autocmd FileType scss setlocal shiftwidth=2 softtabstop=2
augroup END

" PHP
augroup php
  autocmd!
  autocmd FileType php setlocal shiftwidth=4 softtabstop=4
  " The below doesn't work, see .vim/after/ftplugin/php.vim
  " autocmd FileType php setlocal commentstring=//\ %s
augroup END

" Go
augroup go
  autocmd!
  autocmd BufRead,BufNewFile *.go setlocal filetype=go
  autocmd FileType go setlocal shiftwidth=8 softtabstop=8 noexpandtab
  " This doesn't work, see .vim/after/ftplugin/go.vim
  " autocmd FileType go setlocal commentstring=//\ %s
augroup END

" git commit
augroup gitcommit
  autocmd!
  autocmd FileType gitcommit setlocal spell
augroup END


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Encryption

augroup encryption
  autocmd!
  autocmd BufReadPre *
        \ if system('head -c 9 ' . expand('<afile>')) ==# 'VimCrypt~' |
        \   setlocal noswapfile nobackup nowritebackup viminfo= |
        \ endif
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Imports

" % also works on if/endif etc
runtime macros/matchit.vim

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Plugins

" Commentary
xmap <Leader>c <Plug>Commentary
nmap <Leader>c <Plug>CommentaryLine

" Rainbow Parentheses
augroup rainbow_parentheses
  autocmd!
  " Highlights (), [], and {}
  autocmd VimEnter *
        \ if exists(':RainbowParenthesesToggle') |
        \   execute 'RainbowParenthesesLoadSquare' |
        \   execute 'RainbowParenthesesLoadBraces' |
        \   execute 'nnoremap <silent> <Leader>r :RainbowParenthesesToggle<CR>' |
        \ endif
augroup END

" vim-go
let g:go_disable_autoinstall = 1
let g:go_fmt_command = "goimports"
let g:go_list_type = "quickfix"

" syntastic
let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }

" JS
let g:syntastic_javascript_checkers = ['standard']

" neoterm
" let g:neoterm_position = 'vertical'
" let g:neoterm_size = 80
" augroup neoterm_test_php
"   autocmd!
"   if filereadable('vendor/bin/phpunit')
"     autocmd BufRead,BufNewFile *.php execute 'T vendor/bin/phpunit'
"     autocmd BufWritePost *.php execute 'T vendor/bin/phpunit'
"     autocmd BufWinLeave *.php execute 'Tclose'
"   end
" augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" .vimrc.local

if filereadable(expand($MYVIMRC.'.local'))
  source $MYVIMRC.local
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Unbundle

runtime bundle/vim-unbundle/plugin/unbundle.vim
