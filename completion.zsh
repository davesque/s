function _s {
  reply=($(ls $S_BIN_PATH))
}
compctl -K _s s
