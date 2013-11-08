_s() {
  COMPREPLY=();
  cur="${COMP_WORDS[COMP_CWORD]}";

  if [ $COMP_CWORD -eq 1 ]; then
    opts=$(ls $S_BIN_PATH/ | tr -d '*@');
    COMPREPLY=( $(compgen -W "$opts" -- $cur) );
  fi
}

complete -F _s s
