#!/usr/bin/env bash

EX_CONFIG=78

source ./utils.sh


##|
##| utils.sh tests
##|
testErrPrintsLineToStdErr() {
  IFS= read -rd '' output < <(err 'arst' &2>&1)
  assertEquals $'arst\n' "$output"
}

testErrTakesArgumentsJustLikePrintf() {
  local output=$(err 'foo %s' 'bar')
  assertEquals 'foo bar' "$output"
}


if [[ -n "$SHUNIT_PATH" ]]; then
  source $SHUNIT_PATH
else
  printf "%s: must set SHUNIT_PATH env var to run tests\n" "$(basename "$0")" >&2
  exit $EX_CONFIG
fi
