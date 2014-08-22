# s, a simple shell script manager

## Acknowledgements

`s` was originally inspired by [f](https://github.com/colinta/f).

## Purpose

Making quick edits to your shell scripts, adding new ones, adding the default
shebang line, etc. can get annoying.  A lot of us do this pretty often every
day, so why not make it as simple as possible?  `s` tries to do this.

Some use cases:

```bash
$ s foo  # opens 'foo' in $EDITOR
$ s      # lists scripts in your bin directory
$ s bar  # if 'bar' does not exist, creates it in your bin directory and opens it
```

...nice, huh?

## Usage

    usage: s [options] [script]

    info/manipulation:
      -l, --list           List all scripts.
                           This is the default command if no arguments are
                           passed.
      -m, --move foo bar   Renames a script 'foo' to 'bar'.
      -c, --copy foo bar   Copies a script 'foo' to 'bar'.
      -d, --delete <foo>   Deletes the script 'foo'.

    adding/editing:
      -b, --bash <foo>     Add/edit bash script 'foo'.
                           This is the default if a script name is given, but
                           no script type is specified.
      -z, --zsh <foo>      Add/edit zsh script 'foo'.
      -p, --python <foo>   Add/edit python script 'foo'.
      -r, --ruby <foo>     Add/edit ruby script 'foo'.
      -pe, --perl <foo>    Add/edit perl script 'foo'.

    etc:
      -h, --help           Show this help screen.

## Installation

1. Clone the `s` repo into a directory
2. Add the following to your `bashrc` or `zshrc`:

```bash
source <path to s.sh>
```

If everything is working, `s` should be available on the command line.  `s`
will default to using `$HOME/.bin` as your script directory.  If you want to
change this, add the following somewhere in your `zshrc` or `bashrc`:

```bash
export S_BIN_PATH=<path to bin directory>
```

## Examples

To create a new script using `s` called `lo`, issue the following command:

```bash
$ s lo
```

This will open a new file using `$EDITOR`.  By default, `s` will automatically
insert a bash shebang line at the top.  This behavior can be adjusted with the
`-z`, `-p`, `-r`, and `-pe` options.  Enter some code:

```bash
#!/usr/bin/env bash

if [[ $# -eq 0 ]]; then
  libreoffice --help
else
  libreoffice "$@" &
fi
```

Save and exit.  The code is saved in the directory specified by `$S_BIN_PATH`.
Try out the new script:

```bash
$ lo somefile.doc
```

What if you want to edit `lo` later?...

```bash
$ s lo
```

...opens the code for `lo` in `$EDITOR`.  Make your changes, save, and quit.

## Other features

### Arguments to the $EDITOR command

If you want to specify any arguments which will be passed to the `$EDITOR`
command when it is used to edit a script, you can do so with the
`$S_EDITOR_ARGS` variable.  For example, if your `$EDITOR` was set to "vim" and
you wanted vim to always set the file type to "zsh" when editing scripts with
`s`, you could add the following to your zshrc:

```bash
export S_EDITOR_ARGS="-c 'set ft=zsh'"
```

This will cause the command `s` uses to open the script file to effectively be
the following:

```bash
vim -c 'set ft=zsh' <path to script file>
```
