_s() {
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts=("$(s)"/*)
  COMPREPLY=( $(compgen -W "${opts[*]##*/}" -- $cur) )
}

complete -F _s s
