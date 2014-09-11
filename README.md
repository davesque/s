# s, a simple shell script manager

## Acknowledgements

`s` was originally inspired by [f](https://github.com/colinta/f), the work of
[Colin T.A. Gray](http://colinta.com), an extraordinary former colleague of
mine.

## Purpose

Making quick edits to your shell scripts, adding new ones, adding the default
shebang line and other boiler plate, remembering where you keep your scripts,
etc. can get annoying.  A lot of us do this pretty often every day, so why not
make it as simple as possible?  `s` tries to do this.

Some examples of what `s` does:

```bash
# Lists available scripts in $S_BIN_PATH
s

# If no script called "foo" exists, creates and edits it in $EDITOR.  If "foo"
# already exists, just edits it.  Uses the "default" template.  More about
# templates below.
s foo

# Uses the "python" template to create and/or edit a script "bar"
s -p bar

# Uses the "python_with_args" template to create and/or edit a script "baz"
s -t python_with_args baz

# Lists available templates
s -t

# Creates and/or edits a template "python"
s -t python

# Maybe you forgot what a script "foo" does
cat $(s foo)  # Prints the contents of "foo" to stdout

# Or you have a template called "foo" and forgot what's in it
cat $(s -t foo)

# Or you want to delete a script called "foo"
s -d foo  # -or-
rm $(s foo)

# Or delete a template called "foo"
rm $(s -t foo)

# Maybe you just want to jump into your bin directory and do things the
# old-fashioned way
cd $(s)

# Or into your templates directory
cd $(s -t)
```

## Usage

    usage: s [options] [script name]

    info/manipulation:
      -l, --list
          List all scripts.  This is the default option if no arguments are
          passed.  In a non-terminal environment, prints $S_BIN_PATH to
          stdout.

      -m, --move <old name> <new name>
          Renames a script.

      -c, --copy <source script name> <new script name>
          Copies a script.

      -d, --delete <script name>
          Deletes a script.

    adding/editing:
      -t, --template [template name] [script name]
          If no extra arguments are given, lists available templates.  In a
          non-terminal environment, prints $S_TEMPLATE_PATH to stdout.

          If only a template name is given, edits or creates and edits that
          template in $EDITOR.  In a non-terminal environment, prints the
          path of the template to stdout.

          If a template name and script name are given, edits or creates and
          edits the script with the given template.  In a non-terminal
          environment, prints the path of the script to stdout.

      -b, --bash [script]     Shorthand for `-t bash [script]`
      -z, --zsh [script]      Shorthand for `-t zsh [script]`
      -p, --python [script]   Shorthand for `-t python [script]`
      -r, --ruby [script]     Shorthand for `-t ruby [script]`
      -pe, --perl [script]    Shorthand for `-t perl [script]`

## Installation

1. Clone the `s` repo into a directory
2. Add the following somewhere in your `.bashrc`:

```bash
export S_BIN_PATH=<path to your script directory>
export PATH="<path to s repo directory>:$S_BIN_PATH:$PATH"
```

If everything is working, `s` should be available on the command line.  You can
also forego exporting `S_BIN_PATH` and `s` will default to using `$HOME/.bin`
as the location of your scripts directory.  If you do this, just make sure you
include `$HOME/.bin` in your `PATH`.

## Other features

### Templates

`s` allows you to create scripts from templates.  Nothing fancy here.  All
that's happening is that the template is copied to the location of the new
script in the background before `s` opens it up for editing.  Here are some
examples of how to use templates:

```bash
s foo     # Uses the template "default" to add/edit a script "foo"
s -b bar  # Uses the template "bash" to add/edit a script "bar"
s -r baz  # Uses the template "ruby" to add/edit a script "baz"

# Uses the template "python_with_args" to add/edit a script "bing"
s -t python_with_args bing

# Lists available templates
s -t

# Creates and/or edits a template "foo"
s -t foo

# Prints the content of template "foo" to stdout
cat $(s -t foo)

# Removes a template "foo"
rm $(s -t foo)

# Makes a copy of a template "foo" called "bar"
cp $(s -t foo) $(s -t bar)

# Renames a template "foo" to "bar"
mv $(s -t foo) $(s -t bar)
```

`s` looks for templates in `$S_TEMPLATE_PATH`.  By default, this variable
points to `templates` in the `s` repo directory.  You can also manually specify
the location of your templates directory:

```bash
export S_TEMPLATE_PATH=<path to template directory>
```

### Non-terminal invocation

Certain `s` commands behave differently if not executed in a terminal.  Here are
some examples of how this is useful:

```bash
cd $(s)       # Change directory to $S_BIN_PATH
cat $(s foo)  # Print the contents of script "foo" to stdout

cd $(s -t)          # Change directory to $S_TEMPLATE_PATH
cat $(s -t python)  # Print the contents of template "python" to stdout

# Verbose versions of 's -m', 's -c', and 's -d'
mv $(s foo) $(s bar)  # Rename a script "foo" to "bar"
cp $(s foo) $(s bar)  # Create a new script "bar" using script "foo"
rm $(s bar)           # Remove a script "bar"

mv $(s -t foo) $(s -t bar)  # Rename a template "foo" to "bar"
cp $(s -t foo) $(s -t bar)  # Copy a template "foo" to "bar"
rm $(s -t bar)              # Remove a template "bar"
```

### Arguments to the $EDITOR command

If you want to specify any arguments which will be passed to the `$EDITOR`
command when it is used to edit a script, you can do so with the
`$S_EDITOR_ARGS` variable.  For example, if your `$EDITOR` was set to "vim" and
you wanted vim to always set the file type to "zsh" when editing scripts with
`s`, you could add the following to your `bashrc`:

```bash
export S_EDITOR_ARGS=(-c 'set ft=zsh')
```

...or in your `zshrc`:

```bash
S_EDITOR_ARGS=(-c 'set ft=zsh')
```

This will cause the command `s` uses to open the script file to effectively be
the following:

```bash
vim -c 'set ft=zsh' <path to script file>
```
