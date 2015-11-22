#!/usr/bin/env bash

EX_CONFIG=78

source ./utils.sh
source ./s.sh


# err tests
testErrPrintsLineToStdErr() {
  IFS= read -rd '' output < <(err 'arst' &2>&1)
  assertEquals $'arst\n' "$output"
}

testErrTakesArgumentsJustLikePrintf() {
  local output=$(err 'foo %s' 'bar')
  assertEquals 'foo bar' "$output"
}


# serr tests
testSerrPrintsLineWithScriptName() {
  local output=$(S_SCRIPT_NAME=s serr 'foo')
  assertEquals 's: foo' "$output"
}


# __s_init tests
testSInitAbortsWhenEditorNotSet() {
  local EDITOR=

  __s_init &> /dev/null
  assertEquals $EX_CONFIG $?

  local output=$(__s_init)
  assertTrue 'output does not match regex' \
    "[[ '$output' =~ ^.+EDITOR\ environment ]]"
}

testSInitSetsDefaultTemplatesPathIfNoneFound() {
  local EDITOR=foo S_TEMPLATES_PATH= S_SCRIPT_PATH=bar

  __s_init &> /dev/null
  assertEquals 'bar/templates' "$S_TEMPLATES_PATH"
}

testSInitAbortsIfTemplatesPathIsNotDir() {
  local EDITOR=foo S_TEMPLATES_PATH=./foo_bar_probably_doesnt_exist_dir_9871937298712394874

  __s_init &> /dev/null
  assertEquals $EX_CONFIG $?

  local output=$(__s_init)
  assertTrue 'output does not match regex' \
    "[[ '$output' =~ does\ not\ exist$ ]]"
}

testSInitSetsDefaultBinPathIfNoneFound() {
  local EDITOR=foo S_TEMPLATES_PATH=. S_BIN_PATH= HOME=bar

  __s_init &> /dev/null
  assertEquals 'bar/.bin' "$S_BIN_PATH"
}

testSInitAbortsIfBinPathIsNotDir() {
  local EDITOR=foo S_TEMPLATES_PATH=. S_BIN_PATH=./foo_bar_probably_doesnt_exist_dir_9871937298712394874

  __s_init &> /dev/null
  assertEquals $EX_CONFIG $?

  local output=$(__s_init)
  assertTrue 'output does not match regex' \
    "[[ '$output' =~ does\ not\ exist$ ]]"
}


if [[ -n "$SHUNIT_PATH" ]]; then
  source $SHUNIT_PATH
else
  printf "%s: must set SHUNIT_PATH env var to run tests\n" "$(basename "$0")" >&2
  exit $EX_CONFIG
fi
