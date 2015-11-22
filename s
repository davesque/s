#!/usr/bin/env bash

set -o errexit

S_SCRIPT_PATH=$(dirname "$0")
S_SCRIPT_NAME=$(basename "$0")

source "$S_SCRIPT_PATH/utils.sh"
source "$S_SCRIPT_PATH/s.sh"

# Switch board
function __s {
  if ! __s_init; then
    serr "failed to initialize"
    return $EX_CONFIG
  fi

  case "$1" in
    # info/manipulation
    "-l"|"--list")
      __s_list "$S_BIN_PATH" "scripts";;
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
    "-t"|"--template")
      __s_edit "$2" "$3";;

    # etc
    "-h"|"--help")
      __s_help;;

    *)
      if [[ -z "$1" ]]; then
        __s_list "$S_BIN_PATH" "scripts"
      else
        __s_edit default "$1"
      fi;;
  esac
}

# Edits or adds a script in S_BIN_PATH
function __s_edit {
  if [[ -z "$1" ]]; then
    __s_list "$S_TEMPLATES_PATH" "templates"
    return 0
  fi

  local t_loc="$S_TEMPLATES_PATH/$1"
  local s_loc="$S_BIN_PATH/$2"

  if [[ -z "$2" ]]; then
    # Edit template
    __s_open "$t_loc"
    return 0
  fi

  if [[ ! -e "$t_loc" ]]; then
    serr 'template "%s" not found' "$1"
    return 1
  fi

  # Create script from template if it doesn't exist
  if [[ ! -e "$s_loc" ]]; then
    cp -- "$t_loc" "$s_loc"
    chmod -- 755 "$s_loc"
  fi

  # Edit script
  __s_open "$s_loc"

  # Remove script if not different from template
  if [[ "$(<"$s_loc")" == "$(<"$t_loc")" ]]; then
    rm -- "$s_loc"
  fi
}

# Renames a script in S_BIN_PATH
function __s_move {
  if [[ -z "$1" || -z "$2" ]]; then
    serr 'must invoke as follows `s -m <source> <destination>`'
    return $EX_USAGE
  fi

  local s_old="$S_BIN_PATH/$1"
  local s_new="$S_BIN_PATH/$2"

  if [[ ! -e "$s_old" ]]; then
    serr '"%s" not found' "$1"
  elif [[ -e "$s_new" ]]; then
    serr '"%s" already exists' "$2"
  else
    mv -- "$s_old" "$s_new"
    serr 'renamed "%s" to "%s"' "$1" "$2"
  fi
}

# Copies a script in S_BIN_PATH
function __s_copy {
  if [[ -z "$1" || -z "$2" ]]; then
    serr 'must invoke as follows `s -c <source> <destination>`'
    return $EX_USAGE
  fi

  local s_old="$S_BIN_PATH/$1"
  local s_new="$S_BIN_PATH/$2"

  if [[ ! -e "$s_old" ]]; then
    serr '"%s" not found' "$1"
  elif [[ -e "$s_new" ]]; then
    serr '"%s" already exists' "$2"
  else
    cp -- "$s_old" "$s_new"
    serr 'copied "%s" to "%s"' "$1" "$2"
  fi
}

# Removes a script in S_BIN_PATH
function __s_delete {
  if [[ -z "$1" ]]; then
    serr 'must invoke as follows `s -d <script name>`'
    return $EX_USAGE
  fi

  local s_loc="$S_BIN_PATH/$1"

  if [[ ! -e "$s_loc" ]]; then
    serr '"%s" not found' "$1"
  else
    rm -- "$s_loc"
    serr 'deleted "%s"' "$1"
  fi
}

function __s_help {
  cat <<'EOF'
s, a simple shell script manager

usage: s [options] [script name]

info/manipulation:
  -l, --list
      List all scripts.  This is the default option if no arguments are
      passed.  In a non-terminal environment, prints $S_BIN_PATH to
      stdout.

  -m, --move <old name> <new name>
      Renames a script.

  -c, --copy <source script name> <new script name>
      Copies a script.

  -d, --delete <script name>
      Deletes a script.

adding/editing:
  -t, --template [template name] [script name]
      If no extra arguments are given, lists available templates.  In a
      non-terminal environment, prints $S_TEMPLATES_PATH to stdout.

      If only a template name is given, edits or creates and edits that
      template in $EDITOR.  In a non-terminal environment, prints the
      path of the template to stdout.

      If a template name and script name are given, edits or creates and
      edits the script with the given template.  In a non-terminal
      environment, prints the path of the script to stdout.

  -b, --bash [script]     Shorthand for `-t bash [script]`
  -z, --zsh [script]      Shorthand for `-t zsh [script]`
  -p, --python [script]   Shorthand for `-t python [script]`
  -r, --ruby [script]     Shorthand for `-t ruby [script]`
  -pe, --perl [script]    Shorthand for `-t perl [script]`

etc:
  -h, --help              Show this help screen.

examples:

To list available scripts with `s`:

  $ s

To create a new script with `s` called `lo`, issue the following
command:

  $ s lo

This will open a new file using `$EDITOR`.  `s` will use the
"default" template in your templates directory if no other options are
given.  This behavior can be adjusted with the `-t`, `-z`, `-p`, `-r`,
and `-pe` options.  Enter some code:

  #!/usr/bin/env bash

  if [[ $# -eq 0 ]]; then
    libreoffice --help
  else
    libreoffice "$@" &
  fi

Save and exit.  The code is saved in the directory specified by
`$S_BIN_PATH`.  Try out the new script:

  $ lo somefile.doc

What if you want to edit `lo` later?...

  $ s lo

...opens the code for `lo` in `$EDITOR`.  Make your changes, save,
and quit.

Maybe you forgot what your script "lo" does:

  $ cat $(s lo)

...prints the contents of "lo" to stdout.

non-terminal invocation recipes:

  cd $(s)       # Change directory to $S_BIN_PATH
  cat $(s foo)  # Print the contents of script "foo" to stdout

  cd $(s -t)          # Change directory to $S_TEMPLATES_PATH
  cat $(s -t python)  # Print the contents of template "python" to stdout

  # Verbose versions of 's -m', 's -c', and 's -d'
  mv $(s foo) $(s bar)  # Rename a script "foo" to "bar"
  cp $(s foo) $(s bar)  # Create a new script "bar" using script "foo"
  rm $(s bar)           # Remove a script "bar"

  mv $(s -t foo) $(s -t bar)  # Rename a template "foo" to "bar"
  cp $(s -t foo) $(s -t bar)  # Copy a template "foo" to "bar"
  rm $(s -t bar)              # Remove a template "bar"

EOF
}

__s "$@"
