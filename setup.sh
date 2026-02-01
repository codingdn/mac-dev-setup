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

echo "✨ All systems go!"
echo "👉 Restart Warp or run 'source ~/.zshrc' to finalize."