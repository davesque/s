# Prints line to stderr with script name
serr() {
  err "%s: $1" "$S_SCRIPT_NAME" "${@:2}"
}

# Initializes s
function __s_init {
  # Ensure EDITOR is set
  if [[ -z "$EDITOR" ]]; then
    serr 'EDITOR environment variable is not set'
    return $EX_CONFIG
  fi

  # Set default template path
  if [[ -z "$S_TEMPLATES_PATH" ]]; then
    S_TEMPLATES_PATH="$S_SCRIPT_PATH/templates"
  fi

  # Ensure directory at S_TEMPLATES_PATH exists
  if [[ ! -d "$S_TEMPLATES_PATH" ]]; then
    serr 'directory specified by S_TEMPLATES_PATH (%s) does not exist' "$S_TEMPLATES_PATH"
    return $EX_CONFIG
  fi

  # Set default bin path
  if [[ -z "$S_BIN_PATH" ]]; then
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

# Opens a file with any specified editor args
function __s_open {
  # Print if not a terminal
  if [[ ! -t 1 ]]; then
    printf '%s' "$1"
    return 0
  fi

  if [[ -n "$S_EDITOR_ARGS" ]]; then
    eval 'local -a args='"$S_EDITOR_ARGS"
    "$EDITOR" "${args[@]}" "$1"
  else
    "$EDITOR" "$1"
  fi
}
