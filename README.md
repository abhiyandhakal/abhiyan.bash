# abhiyan.bash - A Bash Prompt Theme

A lightweight Bash prompt theme with the same two-line layout and Git and virtualenv context as [abhiyan.zsh](https://github.com/abhiyandhakal/abhiyan.zsh).

## Features

- Two-line prompt with user, host, and current directory
- Git work-tree info: branch, staged, unstaged, and untracked counts
- Bare-repo indicator with worktree count
- Python virtualenv name when active
- Right side shows the last exit status on error and the current time
- Vi editing mode with an outline circle in insert mode and a filled circle in command mode

## Requirements

Your terminal should support a Nerd Font or Powerline-compatible font for the prompt glyphs.

## Installation

Clone the repo and source the plugin file from your `~/.bashrc`:

```sh
git clone https://github.com/abhiyandhakal/abhiyan.bash.git ~/bash-theme
echo 'source ~/bash-theme/bash-theme.plugin.bash' >> ~/.bashrc
```
