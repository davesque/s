#!/usr/bin/env bash

EX_CONFIG=78

source ./utils.sh
source ./s.sh


faketty() {
  if [[ $(uname) == Darwin ]]; then
    script -q /dev/null bash -c "$1"
  else
    script -qc "bash -c '$1'" /dev/null
  fi
}


# err tests
testErrPrintsLineToStdErr() {
  IFS= read -rd '' output < <(err 'arst' 2>&1)
  assertEquals $'arst\n' "$output"
}

testErrTakesArgumentsJustLikePrintf() {
  local output=$(err 'foo %s' 'bar' 2>&1)
  assertEquals 'foo bar' "$output"
}


# serr tests
testSerrPrintsLineWithScriptName() {
  local output=$(S_SCRIPT_NAME=s serr 'foo' 2>&1)
  assertEquals 's: foo' "$output"
}


# __s_init tests
testSInitAbortsWhenEditorNotSet() {
  local EDITOR=

  __s_init &> /dev/null
  assertEquals $EX_CONFIG $?

  local output=$(__s_init 2>&1)
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

  local output=$(__s_init 2>&1)
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

  local output=$(__s_init 2>&1)
  assertTrue 'output does not match regex' \
    "[[ '$output' =~ does\ not\ exist$ ]]"
}

testSInitAbortsIfSBinPathNotInPath() {
  local EDITOR=foo S_TEMPLATES_PATH=. S_BIN_PATH=$(mktemp -d)

  __s_init &> /dev/null
  assertEquals $EX_CONFIG $?

  local output=$(__s_init 2>&1)
  assertTrue 'output does not match regex' \
    "[[ '$output' =~ not\ in\ PATH$ ]]"

  rmdir "$S_BIN_PATH"
}


# __s_list tests
testSListPrintsArgIfStdOutNotATerminal() {
  local output=$(__s_list arst)
  assertEquals 'arst' "$output"
}

testSListPrintsFilesAtPath() {
  local tmp_dir=$(mktemp -d)
  touch "$tmp_dir/tmp_file"

  local output=$( \
    faketty "source utils.sh && source s.sh && __s_list $tmp_dir 2>/dev/null" | \
    tr -d '\r' \
    )
  assertEquals 'tmp_file' "$output"

  rm "$tmp_dir/tmp_file"
  rmdir "$tmp_dir"
}


# __s_open tests
testSOpenPrintsArgIfStdOutNotATerminal() {
  local output=$(__s_open arst)
  assertEquals 'arst' "$output"
}

testSOpenUsesEditorToOpenFiles() {
  local EDITOR=printf

  export S_EDITOR_ARGS=
  local output=$(faketty 'source s.sh && __s_open args')
  assertEquals 'args' "$output"

  export S_EDITOR_ARGS='("lots of %s %s" extra)'
  local output=$(faketty 'source s.sh && __s_open args')
  assertEquals 'lots of extra args' "$output"
}


if [[ -n "$SHUNIT_PATH" ]]; then
  source $SHUNIT_PATH
else
  printf "%s: must set SHUNIT_PATH var to run tests\n" "$(basename "$0")" >&2
  exit $EX_CONFIG
fi
