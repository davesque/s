#!/usr/bin/env bash

# Switch board
case $1 in 
  "-l"|"--list")
    __f_list
    ;;
  "-h"|"--help")
    __f_help
    ;;
  "-i"|"--init")
    __f_init -i
    ;;
  "-m"|"--move")
    __f_move $2 $3
    ;;
  "-c"|"--copy")
    __f_copy $2 $3
    ;;
  "-d"|"--delete")
    __f_delete $2
    ;;
  *)
    if [[ -z $1 ]]; then
      __f_list
    else
      __f_edit $1
    fi
    ;;
esac

# Initializes zf
function __f_init() {
  # Ensure zf_path is set
  if [[ -z $zf_path ]]; then
    print "Must set zf_path environment variable before loading zf" >& 2
    return 1
  fi

  # Ensure EDITOR is set
  if [[ -z $EDITOR ]]; then
    print "Must set EDITOR environment variable before loading zf" >& 2
    return 1
  fi

  # Set default functions path
  if [[ -z $zf_unctions_path ]]; then
    zf_unctions_path="$zf_path/unctions"
  fi

  # Add $zf_unctions_path to fpath
  if [[ $fpath[(r)$zf_unctions_path] != $zf_unctions_path ]]; then
    fpath=($zf_unctions_path $fpath)
  fi

  if [[ $1 == "-i" ]]; then
    print "Restarting zf..."

    # Unload functions in $zf_unctions_path
    for func in $(ls $zf_unctions_path); do
      unfunction $func &> /dev/null
    done

    # Reload zf
    unfunction f && autoload -U f && f
  else
    # Set up all functions in $zf_unctions_path to be autoloaded
    for func in $(ls $zf_unctions_path); do
      autoload -U $func
    done

    # If functions have been marked as requiring initialization...
    if [[ -n $zf_init ]]; then
      for func in $zf_init; do
        if [[ -r $zf_unctions_path/$func ]]; then
          $func
        else
          print "Tried to initialize $func, but couldn't find or read it" >& 2
        fi
      done
    fi
  fi
}

# Edits or adds a function in $zf_unctions_path
function __f_edit {
  if [[ -n $1 ]]; then
    if [[ -n $zf_editor_args ]]; then
      eval $EDITOR $zf_editor_args $zf_unctions_path/$1
    else
      $EDITOR $zf_unctions_path/$1
    fi

    __f_init -i
  fi
}

# Renames a function in $zf_unctions_path
function __f_move {
  if [[ -n $1 && -n $2 ]]; then
    local f_old=$zf_unctions_path/$1
    local f_new=$zf_unctions_path/$2

    if [[ -e $f_old && ! -e $f_new ]]; then
      print "Renaming $1 to $2..."
      unfunction $1
      mv $f_old $f_new
      autoload -U $2
    elif [[ ! -e $f_old ]]; then
      print "$1 not found!" >& 2
    elif [[ -e $f_new ]]; then
      print "$2 already exists!" >& 2
    else
      # Should never happen
    fi
  fi
}

# Copies a function in $zf_unctions_path
function __f_copy {
  if [[ -n $1 && -n $2 ]]; then
    local f_old=$zf_unctions_path/$1
    local f_new=$zf_unctions_path/$2

    if [[ -e $f_old && ! -e $f_new ]]; then
      print "Copying $1 to $2..."
      unfunction $1
      cp $f_old $f_new
      autoload -U $2
    elif [[ ! -e $f_old ]]; then
      print "$1 not found!" >& 2
    elif [[ -e $f_new ]]; then
      print "$2 already exists!" >& 2
    else
      # Should never happen
    fi
  fi
}

# Removes a function in $zf_unctions_path
function __f_delete {
  if [[ -n $1 ]]; then
    local f_loc=$zf_unctions_path/$1

    if [[ -e $f_loc ]]; then
      print "Deleting $1..."
      unfunction $1
      rm $f_loc
    else
      print "$1 not found!" >& 2
    fi
  fi
}

# Lists all functions in $zf_unctions_path
function __f_list {
  print "${fg_bold[yellow]}List of functions:${reset_color}"
  ls -1 $zf_unctions_path
}

function __f_help {
  cat <<HELP
zf, a simple function tracking system for zshell

usage: f [options] [function]

Thanks goes to Colin Thomas-Arnold for writing the original f function tracking
system for bash (https://github.com/colinta/f).  zf is known as 'f' on the
command line for the purpose of abbreviation.

optional arguments:
  -l, --list          List all functions.
                      Default command if no arguments are passed to zf.
  -m, --move old new  Renames a function 'old' to 'new'.
  -c, --copy old new  Copies a function 'old' to 'new'.
  -d, --delete fn     Deletes the function 'fn'.
  -i, --init          Reload all functions.
  -h, --help          Show this help screen.

examples:

To create a new function using zf called 'lo', issue the following command:

  % f lo

This will open a new file using \$EDITOR.  Enter some code:

  if [[ \$# -eq 0 ]]; then
    libreoffice --help
  else
    libreoffice \$@ &!
  fi

Save and exit.  zf saves this code in the directory specified by
\$zf_unctions_path, which has been made part of your zsh \$fpath.  It then
marks it to be autoloaded.  Try out the new function:

  % lo somefile.doc

What if you want to edit 'lo' later?...

  % f lo

...opens the code for 'lo' in \$EDITOR.  Make your changes, save, and quit.

HELP
}

__f_init
