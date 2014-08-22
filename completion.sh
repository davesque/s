_s() {
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  if [[ $COMP_CWORD -eq 1 ]]; then
    # Get full paths for shell scripts
    opts=($S_BIN_PATH/*)

    # Get file basenames
    basenames="${opts[@]##*/}"

    COMPREPLY=( $(compgen -W "${basenames[@]}" -- $cur) )
  fi
}

complete -F _s s
