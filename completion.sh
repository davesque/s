_s() {
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts=($S_BIN_PATH/*)
  COMPREPLY=( $(compgen -W "${opts[*]##*/}" -- $cur) )
}

complete -F _s s
