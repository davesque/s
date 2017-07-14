# Prints line to stderr with script name
serr() {
  err "%s: $1" "$S_SCRIPT_NAME" "${@:2}"
}

# Initializes s
__s_init() {
  # Ensure EDITOR is set
  if [[ -z "${EDITOR:-}" ]]; then
    serr 'EDITOR environment variable is not set'
    return $EX_CONFIG
  fi

  # Set default template path
  if [[ -z "${S_TEMPLATES_PATH:-}" ]]; then
    S_TEMPLATES_PATH="$S_SCRIPT_PATH/templates"
  fi

  # Ensure directory at S_TEMPLATES_PATH exists
  if [[ ! -d "$S_TEMPLATES_PATH" ]]; then
    serr 'directory specified by S_TEMPLATES_PATH (%s) does not exist' "$S_TEMPLATES_PATH"
    return $EX_CONFIG
  fi

  # Set default bin path
  if [[ -z "${S_BIN_PATH:-}" ]]; then
    S_BIN_PATH="$HOME/.bin"
  fi

  # Ensure directory at S_BIN_PATH exists
  if [[ ! -d "$S_BIN_PATH" ]]; then
    serr 'directory specified by S_BIN_PATH (%s) does not exist' "$S_BIN_PATH"
    return $EX_CONFIG 
  fi

  # Ensure S_BIN_PATH is in PATH
  printf '%s' "$PATH" | grep -qF -- "$S_BIN_PATH"
  if [[ $? -eq 1 ]]; then
    serr 'directory specified by S_BIN_PATH (%s) is not in PATH' "$S_BIN_PATH"
    return $EX_CONFIG
  fi
}

# Does something at given path
__s_do() {
  if [[ $# -lt 2 ]]; then
    serr 'path or command not specified'
    return $EX_USAGE
  fi

  local path=$1
  local cmd=("${@:2}")

  pushd "$path" &> /dev/null
  "${cmd[@]}"
  err 'did `%s` in %s' "${cmd[*]}" "$path"
  popd &> /dev/null
}

# Lists files at path or prints path
__s_list() {
  # Print if not a terminal
  if [[ ! -t 1 ]]; then
    printf '%s' "$1"
    return 0
  fi

  err 'Available %s:' "$2"
  ls -- "$1"
}

# Opens a file at path or prints path
__s_open() {
  # Print if not a terminal
  if [[ ! -t 1 ]]; then
    printf '%s' "$1"
    return 0
  fi

  local cmd=("$EDITOR")

  if [[ -n "${S_EDITOR_ARGS:-}" ]]; then
    eval 'local -a s_editor_args='"$S_EDITOR_ARGS"
    cmd+=("${s_editor_args[@]}")
  fi

  "${cmd[@]}" "$1"
}

# Edits/adds a script or template
__s_edit() {
  local t_name=$1
  local s_name=${2:-}
  local t_loc="$S_TEMPLATES_PATH/$t_name"
  local s_loc="$S_BIN_PATH/${s_name:-}"

  if [[ -z "${s_name:-}" ]]; then
    # Edit template
    __s_open "$t_loc"
    return 0
  elif [[ ! -e "$t_loc" ]]; then
    serr 'template "%s" not found' "$t_name"
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

# Switch board
__s() {
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
    "-h"|"--help")
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
