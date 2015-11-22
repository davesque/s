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

usage: s [-t [template name] [script name]]
         [-bzpre [script name]]
         [-- cmd [arg ...]]
         [-t -- cmd [arg ...]]
         [-h]

With no args, `s` lists all scripts in $S_BIN_PATH.  In a non-terminal
environment, $S_BIN_PATH is printed to stdout.

adding/editing:
  -t [template name] [script name]
      If no extra arguments are given, lists available templates.  In a
      non-terminal environment, prints $S_TEMPLATES_PATH to stdout.

      If only a template name is given, edits or creates and edits that
      template in $EDITOR.  In a non-terminal environment, prints the path of
      the template to stdout.

      If a template name and script name are given, edits or creates and edits
      the script with the given template.

  -b [script]    Shorthand for `-t bash [script]`
  -z [script]    Shorthand for `-t zsh [script]`
  -p [script]    Shorthand for `-t python [script]`
  -r [script]    Shorthand for `-t ruby [script]`
  -e [script]    Shorthand for `-t perl [script]`

info/manipulation:
  -- cmd [arg ...]
      Performs a command with given args in directory specified by $S_BIN_PATH.

  -t -- cmd [arg ...]
      Performs a command with given args in directory specified by $S_TEMPLATES_PATH.

etc:
  -h, --help              Show this help screen.

EOF
}

__s "$@"
