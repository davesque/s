#!/usr/bin/env bash

set -o errexit
set -o nounset

S_SCRIPT_PATH=$(dirname "$0")
S_SCRIPT_NAME=$(basename "$0")

source "$S_SCRIPT_PATH/utils.sh"
source "$S_SCRIPT_PATH/s.sh"

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
