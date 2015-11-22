EX_USAGE=64
EX_CONFIG=78

# Prints line to stderr
err() {
  printf "$1\n" "${@:2}" &1>&2
}
