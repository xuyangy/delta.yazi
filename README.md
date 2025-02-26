# delta.yazi

Plugin for [yazi](https://github.com/sxyazi/yazi) to diff selected and hovered files using [delta](https://github.com/dandavison/delta). 

## Features
This plugin is similar as [diff.yazi](https://github.com/yazi-rs/plugins/tree/main/diff.yazi) which uses `diff` to show the differences between the selected and hovered files.
This plugin however:
- Uses [delta](https://github.com/dandavison/delta) to show the difference between the selected and hovered files for better readability.
- If yazi was started inside a Tmux session, the diff will be shown in a new Tmux window where you can navigate the diff as inside `less`:
    * `j` and `k` to scroll down and up.
    * `SPACE` to forward one page.
    * `b` to scroll up one page.
    * `g` or `<` to go to the top.
    * `G` or `>` to go to the bottom.
    * `/` to search for a pattern.
    * `n` to go to the next match.
    * `N` to go to the previous match.
    * [...](https://man7.org/linux/man-pages/man1/less.1.html)
- `q` or `ZZ` to close the Tmux window and go back to yazi.
- If not inside a Tmux session, the diff will be copied to the clipboard. You can view the diff with
`less` in your terminal:
    * `pbpaste | less` on macOS.
    * `xclip -o -sel c | less` on Linux.


## Requirements
- [yazi](https://github.com/sxyazi/yazi) 
- [delta](https://github.com/dandavison/delta)


## Installation

```bash
ya pack -a xuyangy/delta
```
## Usage

Add this to your `~/.config/yazi/keymap.toml`:

```toml
[[manager.prepend_keymap]]
on   = "<C-d>"
run  = "plugin delta"
desc = "Diff the selected with the hovered file"
```

Make sure the <kbd>Ctrl</kbd> + <kbd>d</kbd> key is not used elsewhere.
