### How to enable the new JDK after installation in MacOS?
Edit the ~/.zshrc to add below lines
```
export JAVA_HOME=$(/usr/libexec/java_home -v 25)
export PATH="$JAVA_HOME/bin:$PATH"
```
Then source the ~/.zshrc to make it effective
```
source ~/.zshrc
```

### How to debug Java code from command line
1. Compile your Java code with `-g` flag to generate debug information
```
javac -g Solution.java
```

2. Start the debuger
```
jdb Solution
```

3. Set/clear the breakpoint
```
stop at ClassName:line
stop in ClassName.method
clear ClassName:line
```

4. Run the program
```
run
```

5. Step through the code
```
next 
step
cont
out 
```

6. Inspect Variable/State
```
print varName
dump varName
eval expression
locals
```

### How to debug Java code remotely
1. On the server side
```
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005 Solution
```
Solution is the compiled java code with `javac -g Solution.java`

2. On the local machine
```
jdb -attach remote-ip:5005  # Replace remote-ip with the server's IP
```

### How to fix issue with google-java-format and vim integration
google-java-format will fail silently if the Java code has compilation errors, and the failed formatting will overwrite the original code (resulting in empty content or garbled text). The root cause is the lack of error checking for the formatting command execution. Use below .vimrc to fix and optimie it:

```
" Define a function to format Java code with google-java-format (fixed version)
function! FormatJavaWithGoogle()
  " Path to the google-java-format JAR (update this to your actual path)
  let g:google_java_format_jar = expand('~/.local/bin/google-java-format-1.28.0-all-deps.jar')

  " Check if the JAR exists
  if !filereadable(g:google_java_format_jar)
    echoerr "Error: google-java-format JAR not found at " . g:google_java_format_jar
    return
  endif

  " Step 1: Create a temporary backup of the current buffer (prevent data loss)
  let l:temp_backup = tempname()
  call writefile(getline(1, '$'), l:temp_backup)

  " Step 2: Save cursor position
  let l:winview = winsaveview()

  " Step 3: Run google-java-format and capture exit code + output
  let l:format_cmd = 'java -jar ' . shellescape(g:google_java_format_jar) . ' --skip-javadoc-formatting -'
  let l:formatted_content = systemlist(l:format_cmd, getline(1, '$'))
  let l:exit_code = v:shell_error

  " Step 4: Handle result based on exit code
  if l:exit_code != 0
    " Restore original content from backup (fix: no more overwriting!)
    call setline(1, readfile(l:temp_backup))
    call winrestview(l:winview)

    " Show error message to user
    echoerr "Google-java-format failed (compilation/syntax error):"
    echoerr join(l:formatted_content, "\n")  " Print the tool's error details
    call delete(l:temp_backup)  " Clean up temp file
    return
  endif

  " Step 5: Apply formatted content (only if successful)
  call setline(1, l:formatted_content)
  call winrestview(l:winview)

  " Step 6: Optional: Remove trailing whitespace
  %s/\s\+$//e

  " Step 7: Clean up temp backup
  call delete(l:temp_backup)
endfunction

" Auto-format Java files on save
autocmd BufWritePre *.java call FormatJavaWithGoogle()
```


```
