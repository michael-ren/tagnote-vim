" Copyright 2019 Michael Ren <michael.ren@mailbox.org>
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <https://www.gnu.org/licenses/>.


" tagnote.vim: Vim plugin to create and organize notes with tagnote

command -nargs=* WriteAsDate :call WriteAsDate(<f-args>)
command -nargs=* AddTagAsDate :call AddTagAsDate(<f-args>)

if (exists("g:TagnoteConfigFile"))
  let g:TagnoteConfigFile = simplify(expand(g:TagnoteConfigFile))
else
  let g:TagnoteConfigFile = simplify($HOME . '/.tag.config.json')
endif

function s:get_config_value(config, name, default)
  " Return configuration value or default
  " If configuration is not readable, return the default
  if ! filereadable(a:config)
    return a:default
  endif
  let l:result = system(
    \'python3 -c "import json; import sys; print(json.load(open(sys.argv[1])).get(sys.argv[2]))"'
    \. ' ' . shellescape(a:config) . ' ' . shellescape(a:name)
    \)
  let l:result = substitute(l:result, '\n\+$', '', '')
  if v:shell_error || l:result ==# 'None'
    return a:default
  elseif l:result ==# 'True'
    return 1
  elseif l:result ==# 'False'
    return 0
  else
    return l:result
  endif
endfunction

let s:TagnoteNotesDirectory = simplify($HOME . '/' . s:get_config_value(
    \g:TagnoteConfigFile, 'notes_directory', 'notes'
    \)
  \)

let s:TagnoteUtc = s:get_config_value(g:TagnoteConfigFile, 'utc', 0)

let s:TAGNOTE_NOTE_REGEX = '[0-9]\{4}-[0-9]\{2}-[0-9]\{2}_[0-9]\{2}-[0-9]\{2}-[0-9]\{2}.txt'


function s:run_with_error_output(command, error)
  let result = system(a:command)
  if v:shell_error
    echo a:error . l:result
  endif
  return v:shell_error
endfunction

function s:is_note(directory, file)
  return a:directory ==# s:TagnoteNotesDirectory
      \ && a:file =~ '^' . s:TAGNOTE_NOTE_REGEX . '$'
endfunction

function WriteAsDate(...)
  if s:TagnoteUtc
    let filename = system(
      \'python3 -c "import datetime; print(datetime.datetime.now(datetime.timezone.utc).strftime(''%Y-%m-%d_%H-%M-%S.txt''))"'
      \)
  else
    let filename = system(
      \'python3 -c "import datetime; print(datetime.datetime.now().strftime(''%Y-%m-%d_%H-%M-%S.txt''))"'
      \)
  endif
  if v:shell_error
    echo "Could not get timestamp\n\n" . l:filename
    return v:shell_error
  endif

  let old_directory = simplify(expand('%:p:h'))
  let old_file = expand('%:t')
  if s:is_note(l:old_directory, l:old_file)
    let prototype = '-p ' . shellescape(l:old_file)
  else
    let prototype = ''
  endif

  let tags = ''
  for arg in a:000
    let tags = l:tags . ' ' . shellescape(l:arg)
  endfor

  execute 'saveas ' . s:TagnoteNotesDirectory . '/' . l:filename
  return s:run_with_error_output(
    \'tag -r :0 add ' . l:prototype . ' ' . l:filename . l:tags,
    \"Could not add note\n\n"
    \)
endfunction

function AddTagAsDate(...)
  let tags = ''
  for arg in a:000
    let tags = l:tags . ' ' . shellescape(l:arg)
  endfor

  let directory = simplify(expand('%:p:h'))
  let file = expand('%:t')
  if s:is_note(l:directory, l:file)
    return s:run_with_error_output(
      \'tag -r :0 add ' . l:file . ' ' . l:tags,
      \"Could not add tag to note\n\n"
      \)
  else
    echo "File is not a note; run :W first\n"
    return 1
  endif
endfunction
