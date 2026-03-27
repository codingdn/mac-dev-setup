#!/bin/bash

# 1. Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "🚀 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Install all tools
echo "📦 Running brew bundle..."
brew bundle

# 3. Zsh Configurations (~/.zshrc)
echo "⚙️ Configuring shell environment..."

# Setup function to avoid duplicates
add_to_zshrc() {
    grep -q "$1" ~/.zshrc || echo "$2" >> ~/.zshrc
}

# pyenv
add_to_zshrc "pyenv init" 'export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"'

# nvm
mkdir -p ~/.nvm
add_to_zshrc "NVM_DIR" 'export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"'

# SDKMAN!
add_to_zshrc "sdkman-init.sh" 'export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"'

# fzf shell integration
add_to_zshrc "fzf --zsh" 'eval "$(fzf --zsh)"'

# 4. Node.js LTS via nvm
echo "📦 Installing Node.js LTS..."
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

if ! nvm ls lts/* &> /dev/null; then
    nvm install --lts
    nvm alias default lts/*
    echo "✅ Node.js LTS installed: $(node --version)"
else
    echo "✅ Node.js LTS already installed"
fi

# 5. Claude Code CLI via npm
echo "📦 Installing Claude Code CLI..."
if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code
    echo "✅ Claude Code installed"
else
    echo "✅ Claude Code already installed"
fi

# 6. Java via SDKMAN
echo "☕ Installing Java via SDKMAN..."
export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

# Install Java 21 LTS (most common for modern projects) and 17 LTS (most widely supported)
if command -v sdk &> /dev/null; then
    sdk install java 21-tem
    sdk install java 17-tem
    sdk default java 21-tem   # set 21 as default, 17 available to switch to
    echo "✅ Java 21 (default) and 17 installed"
else
    echo "⚠️  SDKMAN not available yet — run manually after restarting shell:"
    echo "    sdk install java 21-tem && sdk install java 17-tem"
fi

# 7. Git global config (skip if already set)
echo "🔧 Checking Git config..."
if [ -z "$(git config --global user.name)" ]; then
    read -p "Git username: " git_name
    read -p "Git email: " git_email
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    git config --global core.editor "code --wait"
    echo "✅ Git configured"
else
    echo "✅ Git already configured as: $(git config --global user.name)"
fi

# 8. macOS defaults worth setting
echo "🖥️  Applying macOS preferences..."
defaults write com.apple.dock autohide -bool true                    # Auto-hide dock
defaults write com.apple.finder ShowPathbar -bool true               # Finder path bar
defaults write com.apple.finder ShowStatusBar -bool true             # Finder status bar
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false   # Key repeat instead of accent menu
defaults write NSGlobalDomain KeyRepeat -int 2                       # Fast key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15               # Short delay before repeat
defaults write com.apple.screencapture location "$HOME/Desktop"      # Screenshots to Desktop
killall Dock Finder 2>/dev/null

echo ""
echo "✨ All systems go!"
echo "👉 Restart Warp or run 'source ~/.zshrc' to finalize."
echo ""
echo "📋 Post-setup reminders:"
echo "  - Sign into Bitwarden, Brave, Google Drive, Notion, Todoist"
echo "  - Authenticate: gh auth login"
echo "  - Authenticate: claude (Claude Code)"
echo "  - Configure Rectangle shortcuts"
echo "  - Configure Warp preferences"