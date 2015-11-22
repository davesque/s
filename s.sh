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
  serr 'did `%s` in `%s`' "${cmd[*]}" "$path"
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
