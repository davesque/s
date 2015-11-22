#!/usr/bin/env bash

set -o errexit
set -o nounset

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

  if [[ $# -eq 0 ]]; then
    __s_list "$S_BIN_PATH" "scripts"
    return 0
  fi

  local cmd=$1
  shift 1

  case "$cmd" in
    "-h")
      __s_help;;

    "-b"|"-z"|"-p"|"-r"|"-e")
      if [[ $# -lt 1 ]]; then
        err 'usage: %s %s <script name>' "$S_SCRIPT_NAME" "$cmd"
        return $EX_USAGE
      fi

      case "$cmd" in
        "-b")
          __s_edit bash "$1";;
        "-z")
          __s_edit zsh "$1";;
        "-p")
          __s_edit python "$1";;
        "-r")
          __s_edit ruby "$1";;
        "-e")
          __s_edit perl "$1";;
      esac;;

    "-t")
      if [[ $# -eq 0 ]]; then
        __s_list "$S_TEMPLATES_PATH" "templates"
      elif [[ "$1" == "--" ]]; then
        __s_do "$S_TEMPLATES_PATH" "${@:2}"
      else
        __s_edit "$1" "${2:-}"
      fi;;

    "--")
      __s_do "$S_BIN_PATH" "$@";;
    *)
      __s_edit default "$cmd";;
  esac
}

# Edits or adds a script in S_BIN_PATH
function __s_edit {
  local t_name=$1
  local s_name=${2:-}
  local t_loc="$S_TEMPLATES_PATH/$1"
  local s_loc="$S_BIN_PATH/${2:-}"

  if [[ $# -eq 1 ]]; then
    # Edit template
    __s_open "$t_loc"
    return 0
  elif [[ ! -e "$t_loc" ]]; then
    serr 'template "%s" not found' "$1"
    return 1
  fi

  # Create script from template if it doesn't exist
  if [[ ! -e "$s_loc" ]]; then
    cp -- "$t_loc" "$s_loc"
    chmod -- 755 "$s_loc"
    local created=1
  fi

  # Edit script
  __s_open "$s_loc"

  # Remove script if not different from template
  if [[ "${created:-}" -eq 1 && "$(<"$s_loc")" == "$(<"$t_loc")" ]]; then
    rm -- "$s_loc"
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
