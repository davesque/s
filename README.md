# s, a simple shell script manager

## Acknowledgements

`s` was originally inspired by [f](https://github.com/colinta/f).

## Usage

    usage: s [options] [script]

    Info/manipulation:
      -l, --list            List all scripts.
                            Default command if no arguments are passed.
      -m, --move foo bar    Renames a script 'foo' to 'bar'.
      -c, --copy foo bar    Copies a script 'foo' to 'bar'.
      -d, --delete <foo>    Deletes the script 'foo'.

    Editing/creation:
      -b, --bash <foo>      Edit/create bash script 'foo'.
                            Default if a script name is given, but no script
                            type is specified.
      -z, --zsh <foo>       Edit/create zsh script 'foo'.
      -p, --python <foo>    Edit/create python script 'foo'.
      -r, --ruby <foo>      Edit/create ruby script 'foo'.
      -pe, --perl <foo>     Edit/create perl script 'foo'.

    Etc:
      -h, --help            Show this help screen.

## Installation

1. Clone the `s` repo into a directory
2. Add the following to your bashrc or zshrc:

```bash
export S_PATH="<path to s repo>"
export S_BIN_PATH="<path to bin folder>"
export PATH=$S_PATH:$PATH
```

If everything is set up correctly, `s` should be available on the command line.

**Note** - If you already have a bin directory in your search path, just export
`S_BIN_PATH` with its location.

## Basics

To create a new script using `s` called `lo`, issue the following command:

```bash
% s lo
```

This will open a new file using `$EDITOR`.  By default, `s` will automatically
insert a bash shebang line at the top.  This behavior can be adjusted with the
`-z`, `-p`, `-r`, and `-pe` options.  Enter some code:

```bash
#!/usr/bin/env bash

if [[ $# -eq 0 ]]; then
  libreoffice --help
else
  libreoffice $@ &!
fi
```

Save and exit.  `s` saves this code in the directory specified by
`$S_BIN_PATH`, which should be added to your binary search path.  Try out the
new script:

```bash
% lo somefile.doc
```

What if you want to edit `lo` later?...

```bash
% s lo
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
