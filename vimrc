syntax on
filetype plugin indent on


"
" Plugins from github.com
" Use command ':PlugInstall' to install them
"
call plug#begin()
" Plug 'vim-airline/vim-airline'
Plug 'itchyny/lightline.vim'
Plug 'ap/vim-buftabline'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'fatih/vim-go'
Plug 'vivien/vim-linux-coding-style'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'iamcco/markdown-preview.vim'
Plug 'iamcco/mathjax-support-for-mkdp'
call plug#end()


"
" Plugins settings
"
let g:NERDTreeWinPos="right"
" let g:Gtags_Auto_Update = 1
let g:linuxsty_patterns = [ "/linux", "/kernel" ]

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
" let g:airline#extensions#tabline#buffer_idx_mode = 1

let g:buftabline_numbers=1
let g:buftabline_show=1

" tagbar settings
let g:tagbar_left = 1
let g:tagbar_sort = 0
let g:tagbar_width = 30
let g:tagbar_indent = 1
let g:tagbar_compact = 1
" let g:tagbar_autofocus = 1
let g:tagbar_singleclick = 1
let g:tagbar_iconchars = ['▸', '▾']


set number
set relativenumber
" set noshowmode
" set laststatus=2
set autowrite
"set background=dark
"set background=light
set showcmd         " Show (partial) command in status line.
set showmatch       " Show matching brackets.
"set ignorecase     " Do case insensitive matching
"set smartcase      " Do smart case matching
set incsearch       " Incremental search
set hlsearch        " Highlight search
"set autowrite      " Automatically save before commands like :next and :make
set hidden          " Hide buffers when they are abandoned
set mouse=nv        " Enable mouse usage (all modes)
set scrolloff=3
set updatetime=250
set cursorline
set listchars=tab:.\ 


" Theme and colors
colorscheme wombat256
if !exists("g:colors_name")
" hi Normal ctermbg=black
" hi ModeMsg ctermfg=yellow
hi LineNr ctermfg=darkgrey ctermbg=NONE
hi CursorLineNr ctermfg=black ctermbg=grey
hi CursorLine cterm=BOLD ctermfg=NONE ctermbg=NONE
hi VertSplit cterm=NONE ctermfg=white ctermbg=NONE
endif

" BufTabLine colors
hi BufTabLineFill ctermbg=black
hi BufTabLineCurrent cterm=BOLD ctermfg=black ctermbg=green
hi BufTabLineActive ctermfg=black ctermbg=grey
hi BufTabLineHidden cterm=NONE ctermfg=grey ctermbg=black


" Indent setup
autocmd FileType go set sw=4 ts=4 noexpandtab
autocmd FileType sh,vim,java,python,xml,php,html,css,javascript set sw=4 ts=4 expandtab
if match(getcwd(), 'work')
    autocmd FileType c,cpp set sw=4 ts=4 expandtab
endif


"
" Key mappings
"

let os=substitute(system('uname'), '\n', '', '')

" Clipboard
if os == 'Darwin'
    nmap <S-y> :.w !pbcopy<CR><CR>
    vmap <S-y> :w !pbcopy<CR><CR>
    nmap yp :r !pbpaste<CR><CR>
elseif os == 'Linux'
    nmap <S-y> :.w !xclip -i -sel clip<CR><CR>
    vmap <S-y> :w !xclip -i -sel clip<CR><CR>
    nmap yp :set paste<CR>:r !xclip -o -sel clip<CR>:set nopaste<CR>
endif

fun! QuickfixToggle()
    let l:nr = winnr("$")
    cwindow
    let l:nr2 = winnr("$")
    if l:nr == l:nr2
        cclose
    endif
endfunction

fun! ToggleWindowWidth()
    let l:w = winwidth(0)
    if l:w >= 120
        silent! execute 'wincmd ='
    else
        silent! execute 'vertical resize 120'
    endif
endfunction

fun! ToggleWindowHeight()
    let l:h = winheight(0)
    if l:h >= 32
        silent! execute 'wincmd ='
    else
        silent! execute 'resize 32'
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

" Fn keys
nmap <F2> :Tagbar<CR>
nmap <F3> :NERDTreeToggle<CR>
nmap <F4> :call QuickfixToggle()<CR>
nmap <F5> :set ts=2 sw=2<CR>
nmap <F6> :set ts=4 sw=4<CR>
nmap <F7> :set ts=8 sw=8 noexpandtab<CR>
nmap <F12> :call LoadTags()<CR>

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

" Toggle mappings
map <SPACE>tt :Tagbar<CR>
map <SPACE>tn :set nu!<CR>
map <SPACE>tN :set rnu!<CR>
map <SPACE>tl :set list!<CR>
map <SPACE>tr :set wrap!<CR>
map <SPACE>tx :set expandtab!<CR>
map <SPACE>tf :NERDTreeToggle<CR>
map <SPACE>tb :call ToggleBuftabline()<CR>
map <SPACE>cc :cclose<CR>
map <SPACE>co :copen<CR>
map <SPACE>ww :call ToggleWindowWidth()<CR>
map <SPACE>wh :call ToggleWindowHeight()<CR>

map <C-k> :bp<CR>
map <C-l> :bn<CR>
map <C-n> :cn<CR>
map <C-m> :cp<CR>

map e :pop<CR>
nmap \| :Gtags 

" Operator-Pending Mappings
onoremap { i{
onoremap ( i(
onoremap [ i[

" remap * to highlight the cursor word but not move to the next same word
nnoremap * :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>


function! GetVisualSelection()
    let [s:lnum1, s:col1] = getpos("'<")[1:2]
    let [s:lnum2, s:col2] = getpos("'>")[1:2]
    let s:lines = getline(s:lnum1, s:lnum2)
    let s:lines[-1] = s:lines[-1][: s:col2 - (&selection == 'inclusive' ? 1 : 2)]
    let s:lines[0] = s:lines[0][s:col1 - 1:]
    return join(s:lines, ' ')
endfunction


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

    let l:tagfile = l:dir . '/cscope.out'
    if filereadable(l:tagfile)
        set cscopetag
        silent! execute 'cs add ' . l:tagfile
        call CscopeKeyMapping()
        " remap <F12> to tags update
        map <F12> :<C-U>cs reset<CR>
        break
    endif

    " Lookup parent directory recurcivly if no tag file found
    " in current directory
    while l:dir != "/"
        let l:tagfile = l:dir . '/GTAGS'

        if filereadable(l:tagfile)
            set cscopetag
            set cscopeprg=gtags-cscope
            silent! execute 'cs add ' . l:tagfile
            call CscopeKeyMapping()
            " remap <F12> to tags update
            map <F12> :<C-U>GtagsUpdate<CR>
            break
        endif

        let l:dir = fnamemodify(l:dir, ':h')
    endwhile
endfunction

call LoadTags()


"
" nerdcomment mappings and settings
"
nmap mm :call NERDComment(0,"toggle")<CR>
nmap ms :call NERDComment(0,"sexy")<CR>
nmap mn :call NERDComment(0,"nested")<CR>
nmap mI :call NERDComment(0,"minimal")<CR>
nmap ma :call NERDComment(0,"append")<CR>
nmap mi :call NERDComment(0,"insert")<CR>
" nmap mn :call NERDComment(0,"norm")<CR>
" nmap mu :call NERDComment(0,"uncomment")<CR>
" nmap m$ :call NERDComment(0,"toEOL")<CR>
" map mv :call NERDComment(0,"invert")<CR>
" nmap my :call NERDComment(0,"yank")<CR>
" nmap ml :call NERDComment(0,"alignLeft")<CR>
" nmap mb :call NERDComment(0,"alignBoth")<CR>
vmap mm :call NERDComment(1,"toggle")<CR>
vmap ms :call NERDComment(1,"sexy")<CR>
vmap mn :call NERDComment(1,"nested")<CR>
vmap mI :call NERDComment(1,"minimal")<CR>

" Add space string after marker
let NERDSpaceDelims = 1


let mapleader = ";"


"
" vim-go mappings and settings
"
au FileType go nmap f <Plug>(go-def)
au FileType go nmap e <Plug>(go-def-pop)
au FileType go nmap <Leader>gn <Plug>(go-rename)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
au FileType go nmap <Leader>gs <Plug>(go-implements)
au FileType go nmap <Leader>gi <Plug>(go-info)
au FileType go nmap <leader>gr <Plug>(go-run)
au FileType go nmap <leader>gt <Plug>(go-test)
au FileType go nmap <leader>ga <Plug>(go-alternate)
au FileType go nmap <leader>gb <Plug>(go-build)
au FileType go nmap <leader>gc <Plug>(go-coverage-toggle)
" au FileType go nmap <Leader>gdt <Plug>(go-def-tab)
" au FileType go nmap <Leader>gds <Plug>(go-def-split)
" au FileType go nmap <Leader>gdv <Plug>(go-def-vertical)

" Alternate switch between f.go and f_test.go
au Filetype go command! -bang A  call go#alternate#Switch(<bang>0, 'edit')
au Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
au Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
au Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')

let g:go_fmt_command = "goimports"


"
" Bookmark mappings
"
nmap <Leader><Leader> <Plug>BookmarkToggle
nmap <Leader>bi <Plug>BookmarkAnnotate
nmap <Leader>ba <Plug>BookmarkShowAll
nmap <Leader>bb <Plug>BookmarkNext
nmap <Leader>bn <Plug>BookmarkNext
nmap <Leader>bp <Plug>BookmarkPrev
nmap <Leader>bc <Plug>BookmarkClear
nmap <Leader>bx <Plug>BookmarkClearAll
" nmap <Leader>kk <Plug>BookmarkMoveUp
" nmap <Leader>jj <Plug>BookmarkMoveDown
nmap <Leader>bg <Plug>BookmarkMoveToLine


"
" Grep mappings
"
map  <Leader>g  :Grep -rn 
nmap <Leader>gg :Grep -rn --include='*.[chS]' --include='*.cpp' <C-R>=expand("<cword>")<CR> .<CR>
nmap <Leader>ga :Grep -rn <C-R>=expand("<cword>")<CR> .<CR>
vmap <Leader>gg :<C-U>Grep -rn --include='*.[chS]' --include='*.cpp' <C-R>=escape(GetVisualSelection(), ' ')<CR> .<CR>
vmap <Leader>ga :<C-U>Grep -rn <C-R>=escape(GetVisualSelection(), ' ')<CR> .<CR>
map  <Leader>gs :cs f e 
map  <Leader>gt :Gtags 


" Jump to the last position when reopening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
