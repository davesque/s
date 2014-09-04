# s, a simple shell script manager

## Acknowledgements

`s` was originally inspired by [f](https://github.com/colinta/f), the work of
[Colin T.A. Grey](http://colinta.com), an extraordinary former colleague of
mine.

## Purpose

Making quick edits to your shell scripts, adding new ones, adding the default
shebang line, etc. can get annoying.  A lot of us do this pretty often every
day, so why not make it as simple as possible?  `s` tries to do this.

Some use cases:

```bash
# If no script called "foo" exists, creates and edits it in $EDITOR.  If "foo"
# already exists, just edits it.  Uses the "default" template.  More about
# templates below.
$ s foo

# Lists all scripts in your bin directory
$ s

# Uses the "python" template to create and/or edit a new script "bar"
$ s -p bar

# Uses the "python_with_args" template to create and/or edit a new script 'baz'
$ s -t python_with_args baz
```

## Usage

    usage: s [options] [script name]

    info/manipulation:
      -l, --list
          List all scripts.  This is the default option if no arguments are
          passed.

      -m, --move <old name> <new name>
          Renames a script.

      -c, --copy <source script name> <new script name>
          Copies a script.

      -d, --delete <script name>
          Deletes a script.

    adding/editing:
      -t, --template <template name> <script name>
          Creates and edits a new script with the given template if no
          script exists with that name.  If a script does exist, opens that
          script for editing.

      -b, --bash <script>     Shorthand for `-t bash <script>`
      -z, --zsh <script>      Shorthand for `-t zsh <script>`
      -p, --python <script>   Shorthand for `-t python <script>`
      -r, --ruby <script>     Shorthand for `-t ruby <script>`
      -pe, --perl <script>    Shorthand for `-t perl <script>`

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

To create a new script with `s` called `lo`, issue the following
command:

```bash
$ s lo
```

This will open a new file using `$EDITOR`.  `s` will use the "default" template
in your templates directory if no other options are given.  This behavior can be
adjusted with the `-t`, `-z`, `-p`, `-r`, and `-pe` options.  Enter some code:

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

### Templates

`s` allows you to create scripts from templates.  Nothing fancy here.  All
that's happening is that the template is copied to the location of the new
script in the background before `s` opens it up for editing.  Here are some
examples of how to use templates:

```bash
$ s foo     # Uses the template "default" to add/edit a script "foo"
$ s -b bar  # Uses the template "bash" to add/edit a script "bar"
$ s -r baz  # Uses the template "ruby" to add/edit a script "baz"

# Uses the template "python_with_args" to add/edit a script "bing"
$ s -t python_with_args bing
```

`s` looks for templates in `$S_TEMPLATE_PATH`.  By default, this variable
points to the `templates` directory in the same location as `s.sh` when it was
sourced.  You can also manually specify the location of your templates
directory:

```bash
export S_TEMPLATE_PATH=<path to template directory>
```

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
