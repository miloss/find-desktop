# find-desktop

Quickly switch between multiple desktops.

If you use Emacs _desktop_, this library allows you to "jump" quickly
between multiple saved desktops by autocompleting or selecting desktop
name. If there is any desktop currently loaded it is previously saved
using `session-save`.

![Screenshot](https://raw.githubusercontent.com/miloss/find-desktop/master/find-desktop-screenshot.png)

Inspired by an awesome
[find-file-in-project](https://github.com/technomancy/find-file-in-project).

## Requirements

* Linux or OS X

This library depends on GNU find for initial desktop list search. You
can get around this requirement if you have
[`fd-desktops-file`](#fd-desktops-file) file ready in place.

* Tested on Emacs >= 24

It will probably work on earlier versions too.

## Install

Drop the [`find-desktop.el`](find-desktop.el) file somewhere in your
Emacs lisp path (eg. site-lisp) and add to your .emacs file:
```lisp
  (require 'find-desktop)
```

## Usage

### `M-x find-desktop`

Run `find-desktop` to see it in action. If you have many files, first
run might be slow since `find` will scan your `$HOME` directory for
`.emacs.desktop` files. Results are then cached to `fd-desktops-file`
file so subsequent runs are much faster. Recommended binding:
```lisp
  (global-set-key (kbd "C-x C-d") 'find-desktop)
```

Directory name is used for a desktop name. If there are duplicated
desktop names, parent directory name is used to distinguish between
them.

### `fd-desktops-file`

Desktop list is saved to `fd-desktops-file` file, which is
`~/.emacs.desktop.list` by default. To add or remove desktops, edit
this file. File content is a simple list of directory paths, for
example:
```bash
/Users/milos/projects/mapc
/Users/milos/github/dotfiles
/Users/milos/github/find-desktop
/Users/milos/github/jquery-geolocation-edit
/Users/milos/github/mapc
```

## Development

Bug reports and pull requests welcome.
