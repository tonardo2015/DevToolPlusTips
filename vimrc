set nocompatible

syntax enable
filetype off
set tabstop=4
set expandtab
set autoindent

set smartindent
set shiftwidth=4
set backspace=indent,eol,start
set ruler
set number
set showcmd
set wildmenu
set lazyredraw
set showmatch
set pastetoggle=<F9>

set encoding=utf8

set ignorecase
set incsearch
set hlsearch

set clipboard=unnamedplus
set mouse=r

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

"-------------- PLUGINS STARTS -----------------
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'edkolev/tmuxline.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'scrooloose/syntastic'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-easytags'
Plugin 'majutsushi/tagbar'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'vim-scripts/a.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'Raimondi/delimitMate'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'jez/vim-c0'
Plugin 'jez/vim-ispc'
Plugin 'kchmck/vim-coffee-script'
Plugin 'flazz/vim-colorschemes'
Plugin 'mileszs/ack.vim'
"Plugin 'artur-shaik/vim-javacomplete2'
Plugin 'ervandew/supertab'
"Plugin 'Shougo/neocomplete.vim'
"Plugin 'ajh17/VimCompletesMe'
Plugin 'benmills/vimux'
Plugin 'dracula/vim'
call vundle#end()  
"-------------- PLUGINS END --------------------

"filetype plugin on
filetype plugin indent on


"----- GENERAL SETTINGS-------
"set laststatus=2
"let g:airline_detect_paste=1
let g:airline_left_sep='>> '
let g:airline_right_sep='<< '
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#fnamemod=':t'
"let g:airline#extensions#tabline#formatter='unique_tail'
let g:airline_powerline_fonts=1
let g:airline_theme='powerlineish'
let g:solarized_termcolors=256
"let g:tmuxline_present='nightly_fox'

let g:tmuxline_preset = {
      \'a'    : '#S',
      \'c'    : ['#(whoami)', '#(uptime | cut -d " " -f 1,2,3)'],
      \'win'  : ['#I', '#W'],
      \'cwin' : ['#I', '#W', '#F'],
      \'x'    : '#(date)',
      \'y'    : ['%R', '%a', '%Y'],
      \'z'    : '#H'}

let t_Co=256
set background=dark
set guifont=PowerlineSymbols:h11
"colorscheme solarized
colorscheme hybrid

"---------NERD-TREE SETTINGS----------
nmap " :NERDTreeTabsToggle<CR>
"let g:nerdtree_tabs_open_on_console_startup=1


"-------- SYNTASTIC SETTINGS---------
let g:syntastic_error_symbol='✘'
let g:syntastic_warning_symbol="▲"

augroup mySyntastic
    au!
    au FileType tex let b:syntastic_mode="passive"
augroup END


"-------- TAGS SETTINGS --------------------------------
let g:easytags_events=['BufReadPost', 'BufWritePost']
let g:easytags_async=1
let g:easytags_dynamic_files=2
let g:easytags_resolve_links=1
let g:easytags_suppress_ctags_warning=1
let g:tagbar_autoclose=1

nmap <F8> :TagbarToggle<CR>
"autocmd BufEnter * nested :call tagbar#autoopen(0)


"---------GIT SETTINGS--------------
"hi clear SignColumn
"let g:airline#extensions#hunks#non_zero_only=1


"----------DELIMITEMATE SETTINGS-----------------
let delimitMate_expand_cr=1
augroup mydelimitMate
   au!
    au FileType markdown let b:delimitMate_nesting_quotes=["`"]
    au FileType tex let b:delimitMate_quotes=""
    au FileType tex let b:delimitMate_matchpairs="(:),[:],{:},`:'"
    au FileType python let b:delimitMate_nesting_quotes=['"', "'"]
augroup END

"-----------TMUX SETTINGS--------------
let g:tmux_navigator_save_on_switch=2

set foldenable "enable folding
set foldlevelstart=10 "Open most folds by default
set foldnestmax=10 "10 nested fold max
"nnoremap <space> za
set foldmethod=indent "fold based on indent level

autocmd FileType vim let b:vim_tab_complete = 'vim'
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 3

autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

autocmd FileType java setlocal omnifunc=javacomplete#Complete
"autocmd FileType java set completefunc=javacomplete#CompleteParamsInf
"nmap <F4> <Plug>(JavaComplete-Imports-AddSmart)
"imap <F4> <Plug>(JavaComplete-Imports-AddSmart)
"nmap <F5> <Plug>(JavaComplete-Imports-Add)
"imap <F5> <Plug>(JavaComplete-Imports-Add)
"nmap <F6> <Plug>(JavaComplete-Imports-AddMissing)
"imap <F6> <Plug>(JavaComplete-Imports-AddMissing)
"nmap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)
"imap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)


let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <C-H> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-J> :TmuxNavigateDown<cr>
nnoremap <silent> <C-K> :TmuxNavigateUp<cr>
nnoremap <silent> <C-L> :TmuxNavigateRight<cr>
nnoremap <silent> <C-O> :TmuxNavigatePrevious<cr>

let mapleader=','

" Write all buffers before navigating from Vim to tmux pane
let g:tmux_navigator_save_on_switch = 2

" Prompt for a command to run
map <Leader>p :VimuxPromptCommand<CR>

" Run last command executed by VimuxRunCommand
map <Leader>l :VimuxRunLastCommand<CR>

" Inspect runner pane
map <Leader>i :VimuxInspectRunner<CR>

" Zoom the tmux runner pane
map <Leader>z :VimuxZoomRunner<CR>


" vv to generate new vertical split
nnoremap <silent> vv <C-w>v

""""""""""""""""""""""
" Quickly Run
""""""""""""""""""""""
map <F5> :call CompileRunGcc()<CR>

func! CompileRunGcc()
        exec "w"
    if &filetype == 'c'
        exec "!g++ % -o %<"
        exec "!time ./%<"
    elseif &filetype == 'cpp'
        exec "!g++ % -o %<"
        exec "!time ./%<"
    elseif &filetype == 'java'
	exec "clear"
        exec "!javac %"
        exec "!time java %<"
    elseif &filetype == 'sh'
        :!time bash %
    elseif &filetype == 'python'
        exec "!time python %"
    elseif &filetype == 'html'
        exec "!firefox % &"
    elseif &filetype == 'go'
    "        exec "!go build %<"
            exec "!time go run %"
    elseif &filetype == 'mkd'
            exec "!~/.vim/markdown.pl % > %.html &"
            exec "!firefox %.html &"
    endif
endfunc

nnoremap th :tabfirst<CR>
nnoremap tk :tabnext<CR>
nnoremap tl :tablast<CR>
nnoremap tt :tabedit<Space>
nnoremap td :tabclose<CR>
