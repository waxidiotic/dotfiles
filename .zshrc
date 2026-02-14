# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="spaceship"
SPACESHIP_PROMPT_ASYNC=false

plugins=(
    gh
    git
    macos
    npm
    you-should-use
    zsh-autosuggestions
    zsh-bat
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# pnpm
export PNPM_HOME="/Users/alex/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# postgresql
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

# bun completions
[ -s "/Users/alex/.bun/_bun" ] && source "/Users/alex/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
eval "$(~/.local/bin/mise activate)"
eval "$(/Users/alex/.local/bin/mise activate zsh)"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

export EDITOR="zed --wait"
export VISUAL="zed --wait"
