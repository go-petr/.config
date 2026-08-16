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

```zsh
# Install everything tracked in Brewfile (CLI tools + GUI apps)
cd ~/.config && brew bundle install

# Populate the tmux plugin submodule-like dirs (see gotcha below)
git clone https://github.com/tmux-plugins/tmux-resurrect ~/.config/tmux/plugins/tmux-resurrect
git clone https://github.com/tmux-plugins/tmux-yank ~/.config/tmux/plugins/tmux-yank
```

Full first-machine bootstrap (Oh My Zsh, zsh plugins, fzf/starship/zoxide
shell init, macOS System Settings tweaks) is documented step by step in
`README.md` — read it rather than re-deriving install commands.

## Architecture / non-obvious things

- **`Brewfile`** is the single source of truth for CLI tools and GUI apps.
  Casks are kept **alphabetically sorted** within the `# --- Apps ---`
  section — preserve that ordering when adding one.

- **`karabiner/`** — Right-Cmd (`rcmd`) app-launch hotkeys live here, e.g.
  `⌘right+I` → Brave, `⌘right+K` → VS Code (see
  `karabiner/assets/complex_modifications/app-launch-rcmd.json` for the
  current mapping). Two files matter and they are **not** kept in sync
  automatically:
  - `karabiner/assets/complex_modifications/*.json` — the hand-authored
    rule source, one `title`+`rules` file per feature.
  - `karabiner/karabiner.json` — Karabiner-Elements' live, app-managed
    state file. When a rule is "Enabled" via the GUI, its content is
    **copied** into this file's active profile. Editing the asset file
    afterwards does **not** retroactively update that copy — either patch
    the matching rule inside `karabiner.json` directly too, or the user
    has to re-toggle the rule in the app. `karabiner/automatic_backups/`
    is written by the app itself; don't hand-edit it.
  - Right-Cmd is used specifically because it's HID-distinguishable from
    plain `⌘` — that's what lets single letters like `I`/`O`/`P`/`J`/`K` be
    used as hotkeys without colliding with normal `⌘+letter` app shortcuts
    (`⌘O` Open, `⌘P` Print, etc). `bettercmdtab` (also in the Brewfile) is
    used only for cmd-tab-style app *switching*, not app-launch hotkeys —
    its hotkey recorder can't tell left/right `⌘` apart.

- **`tmux/plugins/tmux-resurrect` and `tmux/plugins/tmux-yank`** are tracked
  as bare gitlinks (`git ls-tree` shows mode `160000`) with **no
  `.gitmodules` file**. A plain `git clone` of this repo leaves those two
  directories empty — they must be populated with the explicit `git clone`
  commands from `README.md`, not `git submodule update`.

- **`wezterm/wezterm.lua`** — comments are written in Russian; match that
  when editing rather than switching to English mid-file. Session
  persistence is handled by the `resurrect.wezterm` plugin (autosave every
  60s, restore-on-startup via `gui-startup`), and the leader key is
  `Ctrl+b` (tmux-style), not wezterm's default.

- **`RectangleConfig.json`** is a raw exported preference dump (import via
  Rectangle's own import feature), not meant to be hand-edited field by
  field.

- **`cursor_extensions.txt`** is a plain list of extension IDs; there is no
  install script wired up to it yet.
