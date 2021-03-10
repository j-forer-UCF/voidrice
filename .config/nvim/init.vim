let mapleader =","

if ! filereadable(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim"'))
	echo "Downloading junegunn/vim-plug to manage plugins..."
	silent !mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/
	silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim
	autocmd VimEnter * PlugInstall
endif

call plug#begin(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugged"'))
Plug 'tpope/vim-surround'
Plug 'preservim/nerdtree'
Plug 'junegunn/goyo.vim'
Plug 'jreybert/vimagit'
Plug 'lukesmithxyz/vimling'
Plug 'vimwiki/vimwiki'
Plug 'bling/vim-airline'
Plug 'tpope/vim-commentary'
Plug 'ap/vim-css-color'
call plug#end()

set title
set bg=light
set go=a
set mouse=a
set nohlsearch
set clipboard+=unnamedplus
set noshowmode
set noruler
set laststatus=0
set noshowcmd

" Some basics:
	nnoremap c "_c
	set nocompatible
	filetype plugin on
	syntax on
	set encoding=utf-8
	set number relativenumber
" Enable autocompletion:
	set wildmode=longest,list,full
" Disables automatic commenting on newline:
	autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
" Perform dot commands over visual blocks:
	vnoremap . :normal .<CR>
" Goyo plugin makes text more readable when writing prose:
	map <leader>f :Goyo \| set bg=light \| set linebreak<CR>
" Spell-check set to <leader>o, 'o' for 'orthography':
	map <leader>o :setlocal spell! spelllang=en_us<CR>
" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
	set splitbelow splitright

" Nerd tree
	map <leader>n :NERDTreeToggle<CR>
	autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
    if has('nvim')
        let NERDTreeBookmarksFile = stdpath('data') . '/NERDTreeBookmarks'
    else
        let NERDTreeBookmarksFile = '~/.vim' . '/NERDTreeBookmarks'
    endif

" vimling:
	nm <leader><leader>d :call ToggleDeadKeys()<CR>
	imap <leader><leader>d <esc>:call ToggleDeadKeys()<CR>a
	nm <leader><leader>i :call ToggleIPA()<CR>
	imap <leader><leader>i <esc>:call ToggleIPA()<CR>a
	nm <leader><leader>q :call ToggleProse()<CR>

" Shortcutting split navigation, saving a keypress:
	map <C-h> <C-w>h
	map <C-j> <C-w>j
	map <C-k> <C-w>k
	map <C-l> <C-w>l

" Replace ex mode with gq
	map Q gq

" Check file in shellcheck:
	map <leader>s :!clear && shellcheck -x %<CR>

" Open my bibliography file in split
	map <leader>b :vsp<space>$BIB<CR>
	map <leader>r :vsp<space>$REFER<CR>

" Replace all is aliased to S.
	nnoremap S :%s//g<Left><Left>

" Compile document, be it groff/LaTeX/markdown/etc.
	map <leader>c :w! \| !compiler "<c-r>%"<CR>

" Open corresponding .pdf/.html or preview
	map <leader>p :!opout <c-r>%<CR><CR>

" Runs a script that cleans out tex build files whenever I close out of a .tex file.
	autocmd VimLeave *.tex !texclear %

" Ensure files are read as what I want:
	let g:vimwiki_ext2syntax = {'.Rmd': 'markdown', '.rmd': 'markdown','.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
	map <leader>v :VimwikiIndex
	let g:vimwiki_list = [{'path': '~/vimwiki', 'syntax': 'markdown', 'ext': '.md'}]
	autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown
	autocmd BufRead,BufNewFile *.ms,*.me,*.mom,*.man set filetype=groff
	autocmd BufRead,BufNewFile *.tex set filetype=tex

" Save file as sudo on files that require root permission
	cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Enable Goyo by default for mutt writing
	autocmd BufRead,BufNewFile /tmp/neomutt* let g:goyo_width=80
	autocmd BufRead,BufNewFile /tmp/neomutt* :Goyo | set bg=light
	autocmd BufRead,BufNewFile /tmp/neomutt* map ZZ :Goyo\|x!<CR>
	autocmd BufRead,BufNewFile /tmp/neomutt* map ZQ :Goyo\|q!<CR>

" Automatically deletes all trailing whitespace and newlines at end of file on save.
	autocmd BufWritePre * %s/\s\+$//e
	autocmd BufWritePre * %s/\n\+\%$//e

" When shortcut files are updated, renew bash and ranger configs with new material:
	autocmd BufWritePost bm-files,bm-dirs !shortcuts
" Run xrdb whenever Xdefaults or Xresources are updated.
	autocmd BufRead,BufNewFile xresources,xdefaults set filetype=xdefaults
	autocmd BufWritePost Xresources,Xdefaults,xresources,xdefaults !xrdb %
" Recompile dwmblocks on config edit.
	autocmd BufWritePost ~/.local/src/dwmblocks/config.h !cd ~/.local/src/dwmblocks/; sudo make install && { killall -q dwmblocks;setsid -f dwmblocks }

" Turns off highlighting on the bits of code that are changed, so the line that is changed is highlighted but the actual text that has changed stands out on the line and is readable.
if &diff
    highlight! link DiffText MatchParen
endif

" Function for toggling the bottom statusbar:
let s:hidden_all = 1
function! ToggleHiddenAll()
    if s:hidden_all  == 0
        let s:hidden_all = 1
        set noshowmode
        set noruler
        set laststatus=0
        set noshowcmd
    else
        let s:hidden_all = 0
        set showmode
        set ruler
        set laststatus=2
        set showcmd
    endif
endfunction
nnoremap <leader>h :call ToggleHiddenAll()<CR>

" -- FORTRAN stuff

set ts=2 sw=2
let fortran_free_source=1
let fortran_have_tabs=1
let fortran_more_precise=1
let fortran_do_enddo=1
set autoindent
set number relativenumber
set nu rnu
syntax on

set tags=tags

" == Markdown stuff ==

autocmd FileType markdown inoremap ;p <lt>p><lt>/p><Esc>3hi

" == LaTeX stuff ==

autocmd FileType tex noremap <Space><Space> /(<>)<CR>3xr\s

" -- Symbols --

autocmd FileType tex inoremap	;R 		 \rm I \!R
autocmd FileType tex inoremap	;C 		 \mathbb{C}
autocmd FileType tex inoremap	;q 		 \quad
autocmd FileType tex inoremap	;qq		 \qq
autocmd FileType tex inoremap	;vd    \vdots
autocmd FileType tex inoremap	;cd		 \cdots
autocmd FileType tex inoremap	;dd 	 \ddots
autocmd FileType tex inoremap ;int   \int\limits_{  }^{(<>)}<Esc>8hi
autocmd FileType tex inoremap ;sum   \sum\limits_{  }^{(<>)}<Esc>8hi


" -- Environments --

autocmd FileType tex inoremap ;item  \begin{itemize}<Enter><Tab>\item<Enter><BS>\end{itemize}<Esc>kA<Space>
autocmd FileType tex inoremap ;enum  \begin{enumerate}[(<>)]<Enter><Tab>\item (<>)<Enter><BS>\end{enumerate}<Esc>2k
autocmd FileType tex inoremap ;eq 	 \begin{equation}<CR><CR>\end{equation}<Esc>kI<Tab>
autocmd FileType tex inoremap ;eqs 	 \begin{equation*}<CR><Tab><CR><BS>\end{equation*}<Esc>kA<Space>
autocmd FileType tex inoremap ;ga 	 \begin{gather}<CR><CR>\end{gather}<Esc>kI<Tab>
autocmd FileType tex inoremap ;gas 	 \begin{gather*}<CR><CR>\end{gather*}<Esc>kI<Tab>
autocmd FileType tex inoremap ;al 	 \begin{align}<CR><CR>\end{align}<Esc>kI<Tab>
autocmd FileType tex inoremap ;als 	 \begin{align*}<CR><CR>\end{align*}<Esc>kI<Tab>
autocmd FileType tex inoremap ;fl 	 \begin{flalign}<CR><Tab><CR><BS>\end{flalign}<Esc>kA<Space>
autocmd FileType tex inoremap ;fls 	 \begin{flalign*}<CR><Tab><CR><BS>\end{flalign*}<Esc>kA<Space>
autocmd FileType tex inoremap ;mp    \begin{minipage}{(<>)}<CR><Tab>(<>)<CR><BS>\end{minipage}<esc>2k
autocmd FileType tex inoremap ;fig   \begin{figure}[(<>)]<CR><Tab>\centering<CR>\includegraphics[(<>)]{(<>)}<CR>\caption{(<>)}<CR>\label{(<>)}<CR><BS>\end{figure}<Esc>5k
autocmd FileType tex inoremap ;fram  \begin{frame}{(<>)}<CR>\end{frame}<Esc>k
autocmd FileType tex inoremap ;txt   \text{}(<>)<Esc>4hi
autocmd FileType tex inoremap ;prf   \begin{proof}[\unskip\nopunct]<CR>\end{proof}<Esc>O

" -- Operators --

autocmd FileType tex inoremap ;abs 	 \abs{}(<>)<Esc>4hi
autocmd FileType tex inoremap ;mat 	 \mat{<Enter><Enter>}(<>)<Esc>ki
autocmd FileType tex inoremap	;innr  \inner{  }{ (<>) }(<>)<Esc>13hi
autocmd FileType tex inoremap ;exp   \left\langle  \left\lvert (<>) \right\rvert (<>) \right\rangle(<>)<Esc>52hi
autocmd FileType tex inoremap	;bf 	 \textbf{}(<>)<Esc>4hi
autocmd FileType tex inoremap ;ital	 \textit{}(<>)<Esc>4hi
autocmd FileType tex inoremap ;bs 	 \boldsymbol{}(<>)<Esc>4hi
autocmd FileType tex inoremap ;frac  \frac{}{(<>)}(<>)<Esc>10hi
autocmd FileType tex inoremap ;ml    \mathlarger{}(<>)<Esc>4hi
autocmd FileType tex inoremap ;ms    \mathsmaller{}(<>)<Esc>4hi
autocmd FileType tex inoremap ;[]    \left[  \right](<>)<Esc>11hi
autocmd FileType tex inoremap ;{}    \left{  \right}(<>)<Esc>11hi
autocmd FileType tex inoremap ;()    \left(  \right)(<>)<Esc>11hi
autocmd FileType tex inoremap ;si    \SI{}{(<>)}(<>)<Esc>10hi
