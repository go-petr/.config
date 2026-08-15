## Copy configs
```zsh
git clone https://github.com/go-petr/.config.git ~/.config
```
#### TMUX plugins
```zsh
git clone https://github.com/tmux-plugins/tmux-resurrect ~/.config/tmux/plugins/tmux-resurrect
git clone https://github.com/tmux-plugins/tmux-yank ~/.config/tmux/plugins/tmux-yank
```

## MacOS
#### Install homebrew
```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off
```

#### Install apps
Everything below (CLI tools + GUI apps) is tracked in `~/.config/Brewfile`.
```zsh
cd ~/.config
brew bundle install
```

Right-Cmd app-launch hotkeys (Claude/Brave/ChatGPT/Telegram/WezTerm/VS Code)
are handled by `karabiner-elements`, rules tracked in
`karabiner/assets/complex_modifications/app-launch-rcmd.json`. After
installing, launch Karabiner-Elements once, grant it Input Monitoring +
Accessibility when macOS prompts, then go to
**Complex Modifications → Add rule → "Right-Cmd app launcher" → Enable All**.
`bettercmdtab` is used for cmd-tab-style app switching only.

#### Install apps manually
1. [V2Box - V2ray Client - App Store - Apple](https://apps.apple.com/ru/app/v2box-v2ray-client/id6446814690)

#### MacOS settings
1. Accessibility -> Display -> Reduce motion -> off
2. Desktop & Dock -> Mission Control -> Automatically rearrange Spaces on most recent use -> off
3. Finder > View > Show Path Bar
4. Keyboard > Input Sources > add Unicode Hex Input

## Shell (zsh)
`.zshrc` and `.zprofile` live in the home directory and aren't tracked in this
repo. Run the commands below on a fresh machine (after `brew bundle install`
above) to build them up to the current setup.

#### Install Oh My Zsh
This creates `~/.zshrc` from the default template (`ZSH_THEME="robbyrussell"`,
`plugins=(git)`).
```zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### Zsh plugins
```zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
Enable them in `~/.zshrc` (theme stays the default `robbyrussell`):
```zsh
sed -i '' 's/^plugins=(git)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
```

#### fzf key bindings + starship prompt
Both `fzf` and `starship` come from the Brewfile above.
```zsh
cat <<'EOF' >> ~/.zshrc

# fzf key bindings (Ctrl-R, Ctrl-T, Alt-C) and fuzzy completion
[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ] && source /opt/homebrew/opt/fzf/shell/completion.zsh

eval "$(starship init zsh)"
EOF
```
(`~/.config/starship.toml` is already picked up automatically since it's in `$XDG_CONFIG_HOME`.)

#### zoxide (faster `cd`)
`zoxide` also comes from the Brewfile above; its init goes in `~/.zprofile`.
```zsh
echo 'eval "$(zoxide init zsh)"' >> ~/.zprofile
```

## Linux
```zsh
sudo apt install tmux zsh fzf
```
