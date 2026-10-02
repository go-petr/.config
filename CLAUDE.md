# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is a personal macOS (+ minimal Linux) dotfiles repo, and it **is itself
`$XDG_CONFIG_HOME`** — it's meant to be cloned directly to `~/.config`, not
symlinked in from elsewhere. There is no build/stow/link step: any file
edited here takes effect the next time the corresponding tool reads its
config (new shell, new tmux session, Karabiner's file watcher, etc.). Keep
that in mind before suggesting a symlink-based dotfiles workflow — it doesn't
apply here.

There's no application code, no build, no lint, no test suite. "Commands"
for this repo are the bootstrap steps in `README.md`.

## Bootstrap / common commands

Full first-machine bootstrap (Oh My Zsh, zsh plugins, fzf/starship/zoxide
shell init, macOS System Settings tweaks) is documented step by step in
`README.md` — read it rather than re-deriving install commands.

## Architecture / non-obvious things

- **`Brewfile`** is the single source of truth for CLI tools and GUI apps.
  Casks are kept **alphabetically sorted** within the `# --- Apps ---`
  section — preserve that ordering when adding one.

- **`karabiner/`** and **`wezterm/`** have their own `CLAUDE.md` with
  editing gotchas (loaded when working in those dirs).

- **`tmux/plugins/tmux-resurrect` and `tmux/plugins/tmux-yank`** are tracked
  as bare gitlinks (`git ls-tree` shows mode `160000`) with **no
  `.gitmodules` file**. A plain `git clone` of this repo leaves those two
  directories empty — they must be populated with the explicit `git clone`
  commands from `README.md`, not `git submodule update`.

- **`RectangleConfig.json`** is a raw exported preference dump (import via
  Rectangle's own import feature), not meant to be hand-edited field by
  field.

- **`claude-statusline/statusline.sh`** — Claude Code status line script,
  referenced from `~/.claude/settings.json` (setup line in `README.md`).
  Deliberately not named `claude/`: Claude Code may treat
  `$XDG_CONFIG_HOME/claude` as its own config dir.

- **`cursor_extensions.txt`** is a plain list of extension IDs; there is no
  install script wired up to it yet.
