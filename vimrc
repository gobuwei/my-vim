syntax on
filetype plugin indent on


"===============================================================
" Plugins management.
" Use command ':PlugInstall' to install them.
"===============================================================
call plug#begin()
Plug 'itchyny/lightline.vim'
Plug 'ap/vim-buftabline'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'vivien/vim-linux-coding-style'
Plug 'mhinz/vim-grepper'
Plug 'ivechan/gtags.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
call plug#end()


"===============================================================
" vim-lsp setup
"===============================================================
let g:lsp_diagnostics_enabled = 0
let g:lsp_diagnostics_highlights_enabled = 0

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=no
    " if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

    let l:cs = execute("cs show")
    if matchstr(l:cs, "GTAGS") != ""
        " Use gtags-cscope key mappings if file 'GTAGS' exists.
        nmap <buffer> K <plug>(lsp-hover)
    else
        nmap <buffer> f <plug>(lsp-definition)
        " nmap <buffer> gd <plug>(lsp-definition)
        nmap <buffer> gr <plug>(lsp-references)
        nmap <buffer> gs <plug>(lsp-document-symbol-search)
        nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
        nmap <buffer> gi <plug>(lsp-implementation)
        nmap <buffer> gt <plug>(lsp-type-definition)
        " nmap <buffer> <leader>rn <plug>(lsp-rename)
        " nmap <buffer> [g <plug>(lsp-previous-diagnostic)
        " nmap <buffer> ]g <plug>(lsp-next-diagnostic)
        nmap <buffer> K <plug>(lsp-hover)
        nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
        nnoremap <buffer> <expr><c-d> lsp#scroll(-4)
    endif

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
    
    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END


"===============================================================
" Settings for other pluggins
"===============================================================
" tagbar settings
let g:tagbar_left = 1
let g:tagbar_sort = 0
let g:tagbar_width = 30
let g:tagbar_indent = 1
let g:tagbar_compact = 1
" let g:tagbar_autofocus = 1
let g:tagbar_singleclick = 1
let g:tagbar_iconchars = ['▸', '▾']

let g:buftabline_numbers=1
let g:buftabline_show=1

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
" let g:airline#extensions#tabline#buffer_idx_mode = 1

let g:NERDCustomDelimiters = {'c': {'left': '//', 'right': ''}}
let g:NERDTreeWinPos="right"
let g:linuxsty_patterns = [ "/linux", "/kernel", "u-boot", "edge-lkm" ]
let g:Gtags_Auto_Update = 1

" Show relative file path on lightline status line
let g:lightline = { 'component_function': { 'filename': 'LightlineFilename', } }
function! LightlineFilename()
    let root = fnamemodify(get(b:, 'git_dir'), ':h')
    let path = expand('%:p')
    if path[:len(root)-1] ==# root
        return path[len(root)+1:]
    endif
    return expand('%')
endfunction


set number
set relativenumber
" set noshowmode
set laststatus=2
set autowrite
"set background=dark
"set background=light
set showcmd         " Show (partial) command in status line.
set showmatch       " Show matching brackets.
" set ignorecase     " Do case insensitive matching
"set smartcase      " Do smart case matching
set incsearch       " Incremental search
set hlsearch        " Highlight search
"set autowrite      " Automatically save before commands like :next and :make
set hidden          " Hide buffers when they are abandoned
set mouse=nv        " Enable mouse usage (all modes)
set scrolloff=6
set updatetime=250
set cursorline
set listchars=tab:.\ 
" set colorcolumn=81
" hi ColorColumn ctermbg=grey
augroup vimrc_autocmds
    autocmd BufEnter * highlight OverLength ctermbg=darkgrey
    autocmd BufEnter *.[ch] match OverLength /\%>80v.\+/
augroup END

"===============================================================
" Theme and colors
"===============================================================
colorscheme wombat256
if !exists("g:colors_name")
hi Normal ctermbg=black
" hi ModeMsg ctermfg=yellow
hi LineNr ctermfg=darkgrey ctermbg=NONE
hi CursorLineNr ctermfg=black ctermbg=grey
" hi CursorLine cterm=BOLD ctermfg=NONE ctermbg=NONE
hi VertSplit cterm=NONE ctermfg=white ctermbg=NONE
endif
hi CursorLineNr cterm=BOLD ctermfg=black ctermbg=green

" BufTabLine colors
hi BufTabLineFill ctermbg=black
hi BufTabLineCurrent cterm=BOLD ctermfg=black ctermbg=green
hi BufTabLineActive ctermfg=black ctermbg=grey
hi BufTabLineHidden cterm=NONE ctermfg=grey ctermbg=black


"===============================================================
" Indention
"===============================================================
autocmd FileType go,ruby set sw=4 ts=4 noexpandtab
autocmd FileType sh,vim,java,python,xml,php,html,css,javascript set sw=4 ts=4 expandtab
if match(getcwd(), 'work')
    autocmd FileType c,cpp set sw=4 ts=4 expandtab
endif


"===============================================================
" Key mappings
"===============================================================

function! GetVisualSelection()
    let [s:lnum1, s:col1] = getpos("'<")[1:2]
    let [s:lnum2, s:col2] = getpos("'>")[1:2]
    let s:lines = getline(s:lnum1, s:lnum2)
    let s:lines[-1] = s:lines[-1][: s:col2 - (&selection == 'inclusive' ? 1 : 2)]
    let s:lines[0] = s:lines[0][s:col1 - 1:]
    " return join(s:lines, ' ')
    return s:lines
endfunction

let os=substitute(system('uname'), '\n', '', '')

" Clipboard
if os == 'Darwin'
    nmap <S-y> :.w !pbcopy<CR><CR>
    vmap <S-y> :w !pbcopy<CR><CR>
    nmap yp :r !pbpaste<CR><CR>
elseif os == 'Linux'
    nmap <S-y> :.w !xclip -i -sel clip<CR><CR>
    " vmap <S-y> :w !xclip -i -sel clip<CR><CR>
    vmap <S-y> :call system('xclip -i -sel clip', GetVisualSelection())<CR>
    nmap yp :set paste<CR>:r !xclip -o -sel clip<CR>:set nopaste<CR>
endif

fun! ToggleQuickfix()
    let l:nr = winnr("$")
    cwindow
    let l:nr2 = winnr("$")
    if l:nr == l:nr2
        cclose
    endif
endfunction

fun! ToggleWindowWidth()
    let l:w = winwidth(0)
    if l:w >= 100
        silent! execute 'wincmd ='
    else
        silent! execute 'vertical resize 100'
    endif
endfunction

fun! ToggleWindowHeight()
    let l:h = winheight(0)
    if l:h >= 28
        silent! execute 'wincmd ='
    else
        silent! execute 'resize 28'
    endif
endfunction

function! ToggleBuftabline()
    if g:buftabline_show == 0
        let g:buftabline_show = 1
    else
        let g:buftabline_show = 0
    endif
    call buftabline#update(0)
endfunction

fun! ToggleLineNumber()
    let l:n = &number
    let l:rn = &relativenumber

    if l:n == 0
        set nu rnu
    elseif l:n == 1 && l:rn == 0
        set nonu nornu
    elseif l:n == 1 && l:rn == 1
        set nu nornu
    endif
endfunction

func! ToggleIndention()
    if &ts == 2
        set ts=4 sw=4 expandtab
    elseif &ts == 4
        set ts=8 sw=8 noexpandtab
    elseif &ts == 8
        set ts=2 sw=2 expandtab
    endif
    echo &ts &expandtab
endfunction

func! ToggleExpandtab()
    if &expandtab == 0
        set expandtab
    else
        set noexpandtab
    endif
    echo &ts &expandtab
endfunction

" Window mappings
map <TAB> <C-W>w
map <S-TAB> <C-W>W
nnoremap <C-J> <C-I>
map sq :q<CR>
map ss :split<CR>
map sv :vsplit<CR>
map sh <C-W>H
map sj <C-W>J
map sk <C-W>K
map sl <C-W>L
map sr <C-W>r
map sR <C-W>R
map sx <C-W>x

map <C-k> :bp<CR>
map <C-l> :bn<CR>
map <C-n> :cn<CR>
map <C-p> :cp<CR>
nmap <C-S> :w<CR>
imap <C-S> <ESC>:w<CR>

map e :pop<CR>

" SPACE leading keys mappings
map <SPACE>cc :cclose<CR>
map <SPACE>co :copen<CR>
map <SPACE>tb :call ToggleBuftabline()<CR>
map <SPACE>tf :NERDTreeToggle<CR>
map <SPACE>th :call ToggleHighlightOverlength()<CR>
map <SPACE>ti :call ToggleIndention()<CR>
map <SPACE>tI :call ToggleExpandtab()<CR>
map <SPACE>tl :set list!<CR>
map <SPACE>tn :call ToggleLineNumber()<CR>
map <SPACE>tr :set wrap!<CR>
map <SPACE>tt :Tagbar<CR>
map <SPACE>tx :set expandtab!<CR>
map <SPACE>wf :call ToggleQuickfix()<CR>
map <SPACE>wh :call ToggleWindowHeight()<CR>
map <SPACE>ww :call ToggleWindowWidth()<CR>

" Operator-Pending Mappings
onoremap { i{
onoremap ( i(
onoremap [ i[

" remap * to highlight the cursor word but not move to the next same word
nnoremap * :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>


"===============================================================
" gtags-cscope setup
"===============================================================

function! CscopeKeyMapping()
    nmap  f :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap  t :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap gs :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap gt :cs find t <C-R>=expand("<cword>")<CR><CR>
    " nmap gd :cs find d <C-R>=expand("<cword>")<CR><CR>
    nmap gf :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap gi :cs find i <C-R>=expand("<cfile>")<CR><CR>
    nmap ge :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap gE :cs find e "<C-R>=expand("<cword>")<CR>"<CR>

    vmap  f <ESC>:cs find g <C-R>=GetVisualSelection()<CR><CR>
    vmap  t <ESC>:cs find c <C-R>=GetVisualSelection()<CR><CR>
    vmap gs <ESC>:cs find s <C-R>=GetVisualSelection()<CR><CR>
    vmap gt <ESC>:cs find t <C-R>=GetVisualSelection()<CR><CR>
    " vmap gd <ESC>:cs find d <C-R>=GetVisualSelection()<CR><CR>
    vmap gf <ESC>:cs find f <C-R>=GetVisualSelection()<CR><CR>
    vmap gi <ESC>:cs find i <C-R>=GetVisualSelection()<CR><CR>
    vmap ge <ESC>:cs find e <C-R>=GetVisualSelection()<CR><CR>
endfunction

function LoadTags()
    let l:dir = getcwd()

    " Lookup parent directory recurcivly if no tag file found
    " in current directory
    while l:dir != "/"
        let l:tagfile = l:dir . '/GTAGS'

        if filereadable(l:tagfile)
            set cscopetag
            set cscopeprg=gtags-cscope
            silent! execute 'cs add ' . l:tagfile
            call CscopeKeyMapping()
            map <S-f> :<C-U>GtagsUpdate<CR>
            break
        endif

        let l:dir = fnamemodify(l:dir, ':h')
    endwhile
endfunction

call LoadTags()


"===============================================================
" nerdcomment mappings and settings
"===============================================================
" Add space string after marker
let NERDSpaceDelims = 1
nmap mm :call nerdcommenter#Comment(0,"toggle")<CR>
nmap ms :call nerdcommenter#Comment(0,"sexy")<CR>
nmap mn :call nerdcommenter#Comment(0,"nested")<CR>
nmap mI :call nerdcommenter#Comment(0,"minimal")<CR>
nmap ma :call nerdcommenter#Comment(0,"append")<CR>
nmap mi :call nerdcommenter#Comment(0,"insert")<CR>
" nmap mn :call nerdcommenter#Comment(0,"norm")<CR>
" nmap mu :call nerdcommenter#Comment(0,"uncomment")<CR>
" nmap m$ :call nerdcommenter#Comment(0,"toEOL")<CR>
" map mv :call nerdcommenter#Comment(0,"invert")<CR>
" nmap my :call nerdcommenter#Comment(0,"yank")<CR>
" nmap ml :call nerdcommenter#Comment(0,"alignLeft")<CR>
" nmap mb :call nerdcommenter#Comment(0,"alignBoth")<CR>
vmap mm :call nerdcommenter#Comment(1,"toggle")<CR>
vmap ms :call nerdcommenter#Comment(1,"sexy")<CR>
vmap mn :call nerdcommenter#Comment(1,"nested")<CR>
vmap mI :call nerdcommenter#Comment(1,"minimal")<CR>


"===============================================================
" leader leading keys mappings
"===============================================================
let mapleader = ";"

" Bookmark mappings
nmap <Leader><Leader> <Plug>BookmarkToggle
nmap <Leader>k <Plug>BookmarkPrev
nmap <Leader>j <Plug>BookmarkNext
nmap <Leader>x <Plug>BookmarkClearAll
" nmap <Leader>c <Plug>BookmarkClear

" Grep mappings
nnoremap <leader>g :Grepper -tool git -open -switch -cword -noprompt<cr>
nnoremap " :Grepper<cr>


" Jump to the last position when reopening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
