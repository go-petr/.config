# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(
    kubectl
    fzf
    git
    git-auto-fetch
    tmux 
    zsh-autosuggestions 
)

#ZSH_TMUX_AUTOSTART=true
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=249'

# open fzf in a tmux floating pane
FZF_TMUX=1
FZF_TMUX_OPTS='-p'

source $ZSH/oh-my-zsh.sh
eval "$(starship init zsh)"

export PATH=$PATH:$(go env GOPATH)/bin
unsetopt correct_all
# export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# Aliases
alias grbm='b=$(git rev-parse --abbrev-ref HEAD); git checkout master && git pull origin master && git checkout "$b" && git rebase master'
alias cm="gco master && gl -p && clear"
