#!/bin/bash

# List of core packages
core_apps=(
    "tmux"
    "jq"
    "yq"
    "gnu-sed"
    "git"
    "go"
    "fzf"
    "starship"
    "kubectl"
    "koekeishiya/formulae/skhd"
    "font-meslo-lg-nerd-font"
)

# List of cask packages
cask_apps=(
    "brave-browser"
    "rectangle"
    "appcleaner"
    "rectangle"
    "wezterm"
    "logi-options-plus"
    "telegram"
    "calibre"
    "obs"
    "anki"
    "cursor"
    "obsidian"
    "alt-tab"
    "dbeaver-community"
    "chatgpt"
    "slack"
    "zoom"
    # "v2ray-client"
)

# Define ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to echo with yellow color and prefix
print_yellow() {
    local prefix_message="$1"
    echo -e "${YELLOW}${prefix_message}${NC}"
}

# Function to echo with green color and prefix
print_green() {
    local prefix_message="$1"
    echo -e "${GREEN}${prefix_message}${NC}"
}

# Function to echo with red color and prefix
print_red() {
    local prefix_message="$1"
    echo -e "${RED}${prefix_message}${NC}"
}

# Function to check if a Homebrew package is installed
is_installed() {
    brew list "$1" &>/dev/null
}

# Function to prompt user for confirmation
prompt_install() {
    read -p "$(print_yellow "Do you want to install $1? (y/n): ")" choice
    case "$choice" in
        y|Y )
            return 0;;
        * )
            return 1;;
    esac
}

# Function to install an app depending on its type (core or cask)
install_app() {
    local app_type="$1"
    local app_name="$2"

    if is_installed "$app_name"; then
        print_green "$app_name is already installed."
        return
    fi

    if prompt_install "$app_name"; then
        case "$app_type" in
            core)
                print_yellow "Installing: $app_name..."
                brew install "$app_name"
                ;;
            cask)
                print_yellow "Installing: $app_name..."
                brew install --cask "$app_name"
                ;;
            *)
                print_red "Error: Unsupported app type '$app_type'. Skipping installation of $app_name."
                ;;
        esac
    else
        print_yellow "Skipping installation of $app_name."
    fi
}

# Main function to install all apps
main() {
    print_yellow "Installing core packages..."
    for app in "${core_apps[@]}"; do
        install_app "core" "$app"
    done

    print_yellow "Installing cask packages..."
    for app in "${cask_apps[@]}"; do
        install_app "cask" "$app"
    done
}

main
