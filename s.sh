# Switch board
function s {
  if [[ -z $S_INITIALIZED ]]; then
    cat <<ERROR
\`s\` did not initialize properly.  Please open a new shell and inspect any error
messages which are displayed.
ERROR
    return 1
  fi

  case $1 in
    "-l"|"--list")
      __s_list
      ;;
    "-h"|"--help")
      __s_help
      ;;
    "-m"|"--move")
      __s_move $2 $3
      ;;
    "-c"|"--copy")
      __s_copy $2 $3
      ;;
    "-d"|"--delete")
      __s_delete $2
      ;;
    *)
      if [[ -z $1 ]]; then
        __s_list
      else
        __s_edit $1
      fi
      ;;
  esac
}

# Initializes s
function __s_init {
  # Ensure EDITOR is set
  if [[ -z $EDITOR ]]; then
    echo "Must set EDITOR environment variable to use s" >& 2
    return 1
  fi

  # Set default bin path
  if [[ -z $S_BIN_PATH ]]; then
    export S_BIN_PATH="$HOME/.bin"
  fi

  # Ensure $S_BIN_PATH is in PATH
  echo "$PATH" | grep "$S_BIN_PATH" &> /dev/null
  if [[ $? -eq 1 ]]; then
    export PATH=$S_BIN_PATH:$PATH
  fi

  export S_INITIALIZED="done"
}

# Edits or adds a script in $S_BIN_PATH
function __s_edit {
  [[ -z $1 ]] && return 1

  local s_loc=$S_BIN_PATH/$1

  if [[ ! -e $s_loc ]]; then
    echo "#!/usr/bin/env bash" >> $s_loc
    chmod 755 $s_loc
  fi

  if [[ -n $S_EDITOR_ARGS ]]; then
    eval $EDITOR $S_EDITOR_ARGS $s_loc
  else
    $EDITOR $s_loc
  fi
}

# Renames a function in $S_BIN_PATH
function __s_move {
  [[ -z $1 || -z $2 ]] && return 1

  local s_old=$S_BIN_PATH/$1
  local s_new=$S_BIN_PATH/$2

  if [[ -e $s_old && ! -e $s_new ]]; then
    echo "Renaming $1 to $2..."
    mv $s_old $s_new
  elif [[ ! -e $s_old ]]; then
    echo "$1 not found!" >& 2
  elif [[ -e $s_new ]]; then
    echo "$2 already exists!" >& 2
  else
    # Should never happen
    return 1
  fi
}

# Copies a function in $S_BIN_PATH
function __s_copy {
  [[ -z $1 || -z $2 ]] && return 1

  local s_old=$S_BIN_PATH/$1
  local s_new=$S_BIN_PATH/$2

  if [[ -e $s_old && ! -e $s_new ]]; then
    echo "Copying $1 to $2..."
    cp $s_old $s_new
  elif [[ ! -e $s_old ]]; then
    echo "$1 not found!" >& 2
  elif [[ -e $s_new ]]; then
    echo "$2 already exists!" >& 2
  else
    # Should never happen
    return 1
  fi
}

# Removes a function in $S_BIN_PATH
function __s_delete {
  [[ -z $1 ]] && return 1

  local s_loc=$S_BIN_PATH/$1

  if [[ -e $s_loc ]]; then
    echo "Deleting $1..."
    rm $s_loc
  else
    echo "$1 not found!" >& 2
  fi
}

# Lists all functions in $S_BIN_PATH
function __s_list {
  echo "${fg_bold[yellow]}List of scripts:${reset_color}"
  ls -1 $S_BIN_PATH
}

function __s_help {
  cat <<HELP
s, a simple shell script manager

usage: s [options] [script]

\`s\` is hosted on github at \`https://github.com/davesque/s\`.  It was
originally inspired by \`f\` (https://github.com/colinta/f).

Info/manipulation:
  -l, --list            List all scripts.
                        Default command if no arguments are passed.
  -m, --move foo bar    Renames a script 'foo' to 'bar'.
  -c, --copy foo bar    Copies a script 'foo' to 'bar'.
  -d, --delete <foo>    Deletes the script 'foo'.

Editing/creation:
  -b, --bash <foo>      Edit/create bash script 'foo'.
                        Default if a script name is given, but no script
                        type is specified.
  -z, --zsh <foo>       Edit/create zsh script 'foo'.
  -p, --python <foo>    Edit/create python script 'foo'.
  -r, --ruby <foo>      Edit/create ruby script 'foo'.
  -pe, --perl <foo>     Edit/create perl script 'foo'.

Etc:
  -h, --help            Show this help screen.

examples:

To create a new script using \`s\` called \`lo\`, issue the following command:

  $ s lo

This will open a new file using \`\$EDITOR\`.  By default, \`s\` will
automatically insert a bash shebang line at the top.  This behavior can be
adjusted with the \`-z\`, \`-p\`, \`-r\`, and \`-pe\` options.  Enter some
code:

  #!/usr/bin/env bash

  if [[ \$# -eq 0 ]]; then
    libreoffice --help
  else
    libreoffice \$@ &!
  fi

Save and exit.  \`s\` saves this code in the directory specified by
\`\$S_BIN_PATH\`, which should be added to your binary search path.  Try out
the new script:

  $ lo somefile.doc

What if you want to edit \`lo\` later?...

  $ s lo

...opens the code for \`lo\` in \`\$EDITOR\`.  Make your changes, save, and
quit.

HELP
}

__s_init
