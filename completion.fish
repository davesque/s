function _s_complete
  set opts (s)/*
  for i in $opts
    echo (basename $i)
  end
end

complete -c s -f -a '(_s_complete)'
