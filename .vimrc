" Configuration file for vim
set modelines=0     " CVE-2007-2438
set encoding=utf-8
set fileencodings=utf-8,gbk,gb2312  " Fix Chinese garbled

" Compatibility
set nocompatible    " Use Vim defaults instead of 100% vi compatibility
set backspace=2     " More powerful backspacing

" Backup for sensitive files
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
au BufWrite /private/etc/pw.* set nowritebackup nobackup

let skip_defaults_vim=1
syntax on
set nu!             " Show line numbers
set autoindent      " Auto-indent new lines
set tabstop=4       " Tab = 4 spaces
set shiftwidth=4    " Auto-indent width = 4 spaces
set expandtab       " Convert tab to spaces

" Define a function to format Java code with google-java-format (fixed version)
function! FormatJavaWithGoogle()
  let g:google_java_format_jar = expand('~/.local/bin/google-java-format-1.28.0-all-deps.jar')

  " Check JAR existence
  if !filereadable(g:google_java_format_jar)
    echoerr "Error: google-java-format JAR not found at " . g:google_java_format_jar
    return
  endif

  " Optional: Syntax check before formatting
  let l:syntax_check_cmd = 'javac -Xlint -sourcepath . -d /tmp ' . shellescape(expand('%'))
  let l:syntax_check_output = system(l:syntax_check_cmd)
  if v:shell_error != 0
    echoerr "❌ Java syntax error (abort formatting):"
    echoerr l:syntax_check_output
    return
  endif

  " Critical Fix 1: Create temporary backup of original content
  let l:temp_backup = tempname()
  call writefile(getline(1, '$'), l:temp_backup)

  " Save cursor position
  let l:winview = winsaveview()

  " Critical Fix 2: Capture exit code and output (avoid silent failure)
  let l:format_cmd = 'java -jar ' . shellescape(g:google_java_format_jar) . ' --skip-javadoc-formatting -'
  let l:formatted_content = systemlist(l:format_cmd, getline(1, '$'))
  let l:exit_code = v:shell_error

  " Critical Fix 3: Handle success/failure
  if l:exit_code != 0
    " Restore original code from backup
    call setline(1, readfile(l:temp_backup))
    call winrestview(l:winview)
    
    " Show clear error message
    echoerr "❌ Google-java-format failed (check syntax/compilation):"
    echoerr join(l:formatted_content, "\n")
    call delete(l:temp_backup)
    return
  endif

  " Apply formatting only if successful
  call setline(1, l:formatted_content)
  call winrestview(l:winview)

  " Optional: Remove trailing whitespace
  %s/\s\+$//e

  " Clean up backup
  call delete(l:temp_backup)
  echo "✅ Java code formatted successfully (Google style)"
endfunction

" Auto-format on save
autocmd BufWritePre *.java call FormatJavaWithGoogle()

" Optional: Manual format shortcut (F3)
nnoremap <F3> :call FormatJavaWithGoogle()<CR>
