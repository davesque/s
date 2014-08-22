# Switch board
function s {
  if [[ -z "$S_INITIALIZED" ]]; then
    if ! __s_init; then
      echo "s: failed to initialize!" >& 2
      return 1
    fi
  fi

  case "$1" in
    # info/manipulation
    "-l"|"--list")
      __s_list;;
    "-m"|"--move")
      __s_move "$2" "$3";;
    "-c"|"--copy")
      __s_copy "$2" "$3";;
    "-d"|"--delete")
      __s_delete "$2";;

    # adding/editing
    "-b"|"--bash")
      __s_edit bash "$2";;
    "-z"|"--zsh")
      __s_edit zsh "$2";;
    "-p"|"--python")
      __s_edit python "$2";;
    "-r"|"--ruby")
      __s_edit ruby "$2";;
    "-pe"|"--perl")
      __s_edit perl "$2";;

    # etc
    "-h"|"--help")
      __s_help;;

    *)
      if [[ -z "$1" ]]; then
        __s_list
      else
        __s_edit bash "$1"
      fi;;
  esac
}

# Initializes s
function __s_init {
  # Ensure EDITOR is set
  if [[ -z "$EDITOR" ]]; then
    echo "s: EDITOR environment variable is not set!" >& 2
    return 1
  fi

  # Set default bin path
  if [[ -z "$S_BIN_PATH" ]]; then
    export S_BIN_PATH="$HOME/.bin"
  fi

  # Ensure directory at $S_BIN_PATH exists
  if [[ ! -d "$S_BIN_PATH" ]]; then
    echo "s: directory specified by S_BIN_PATH ($S_BIN_PATH) does not exist!" >& 2
    return 1
  fi

  # Ensure $S_BIN_PATH is in PATH
  echo "$PATH" | grep "$S_BIN_PATH" &> /dev/null
  if [[ $? -eq 1 ]]; then
    export PATH="$S_BIN_PATH:$PATH"
  fi

  export S_INITIALIZED="done"
}

# Edits or adds a script in $S_BIN_PATH
function __s_edit {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "s: must invoke as follows \`s [-b|-z|-p|-r|-pe] <script name>\`" >& 2
    return 1
  fi

  local s_type="$1"
  local s_loc="$S_BIN_PATH/$2"
  local default_content="#!/usr/bin/env $s_type"

  # Create script with default content if it doesn't exist
  if [[ ! -e "$s_loc" ]]; then
    echo "$default_content" >> "$s_loc"
    chmod 755 "$s_loc"
  fi

  # Edit script
  if [[ -n "$S_EDITOR_ARGS" ]]; then
    eval "$EDITOR $S_EDITOR_ARGS $s_loc"
  else
    "$EDITOR" "$s_loc"
  fi

  # Remove script if nothing was added
  if [[ "$(cat $s_loc)" == "$default_content" ]]; then
    rm "$s_loc"
  fi
}

# Renames a script in $S_BIN_PATH
function __s_move {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "s: must invoke as follows \`s -m <source> <destination>\`" >& 2
    return 1
  fi

  local s_old="$S_BIN_PATH/$1"
  local s_new="$S_BIN_PATH/$2"

  if [[ -e "$s_old" && ! -e "$s_new" ]]; then
    echo "Renaming $1 to $2..."
    mv "$s_old" "$s_new"
  elif [[ ! -e "$s_old" ]]; then
    echo "$1 not found!" >& 2
  elif [[ -e "$s_new" ]]; then
    echo "$2 already exists!" >& 2
  else
    # Should never happen
    return 1
  fi
}

# Copies a script in $S_BIN_PATH
function __s_copy {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "s: must invoke as follows \`s -c <source> <destination>\`" >& 2
    return 1
  fi

  local s_old="$S_BIN_PATH/$1"
  local s_new="$S_BIN_PATH/$2"

  if [[ -e "$s_old" && ! -e "$s_new" ]]; then
    echo "Copying $1 to $2..."
    cp "$s_old" "$s_new"
  elif [[ ! -e "$s_old" ]]; then
    echo "$1 not found!" >& 2
  elif [[ -e "$s_new" ]]; then
    echo "$2 already exists!" >& 2
  else
    # Should never happen
    return 1
  fi
}

# Removes a script in $S_BIN_PATH
function __s_delete {
  if [[ -z "$1" ]]; then
    echo "s: must invoke as follows \`s -d <script name>\`" >& 2
    return 1
  fi

  local s_loc="$S_BIN_PATH/$1"

  if [[ -e "$s_loc" ]]; then
    echo "Deleting $1..."
    rm "$s_loc"
  else
    echo "$1 not found!" >& 2
  fi
}

# Lists all scripts in $S_BIN_PATH
function __s_list {
  echo "${fg_bold[yellow]}List of scripts:${reset_color}"
  ls -1 "$S_BIN_PATH/"
}

function __s_help {
  cat <<HELP
s, a simple shell script manager

usage: s [options] [script]

info/manipulation:
  -l, --list           List all scripts.
                       This is the default command if no arguments are
                       passed.
  -m, --move foo bar   Renames a script 'foo' to 'bar'.
  -c, --copy foo bar   Copies a script 'foo' to 'bar'.
  -d, --delete <foo>   Deletes the script 'foo'.

adding/editing:
  -b, --bash <foo>     Add/edit bash script 'foo'.
                       This is the default if a script name is given, but
                       no script type is specified.
  -z, --zsh <foo>      Add/edit zsh script 'foo'.
  -p, --python <foo>   Add/edit python script 'foo'.
  -r, --ruby <foo>     Add/edit ruby script 'foo'.
  -pe, --perl <foo>    Add/edit perl script 'foo'.

etc:
  -h, --help           Show this help screen.

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
    libreoffice "\$@" &
  fi

Save and exit.  The code is saved in the directory specified by
\`\$S_BIN_PATH\`.  Try out the new script:

  $ lo somefile.doc

What if you want to edit \`lo\` later?...

  $ s lo

...opens the code for \`lo\` in \`\$EDITOR\`.  Make your changes, save, and
quit.

HELP
}

__s_init
