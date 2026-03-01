# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download zinit if we don't have it yet
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/load zinit
source "${ZINIT_HOME}/zinit.zsh"

zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -v
bindkey '^y' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
# Make it case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Go things
export PATH=$PATH:$HOME/go/bin

# Aliases
alias ls='ls --color'
alias gs='git status'
alias gp='git push'
alias g='lazygit'

# mise (tool version manager) — must come before fzf so we can install fzf with mise
if [[ -x ~/.local/bin/mise ]]; then
  eval "$(~/.local/bin/mise activate zsh)"
else
  if [[ -o interactive ]]; then
    read -q "?Install mise? (y/n) "
    echo
    if [[ $REPLY =~ ^[yY]$ ]]; then
      curl -fsSL https://mise.run | sh
      eval "$(~/.local/bin/mise activate zsh)"
    fi
  else
    echo '[.zshrc] mise is not installed. Install it with: curl https://mise.run | sh'
  fi
fi

# Shell integrations for fzf
if command -v fzf &>/dev/null; then
  eval "$(fzf --zsh)"
else
  if [[ -x ~/.local/bin/mise ]]; then
    if [[ -o interactive ]]; then
      read -q "?Install fzf with mise? (y/n) "
      echo
      if [[ $REPLY =~ ^[yY]$ ]]; then
        ~/.local/bin/mise use -g fzf
        eval "$(~/.local/bin/mise activate zsh)"
        command -v fzf &>/dev/null && eval "$(fzf --zsh)"
      fi
    else
      echo '[.zshrc] fzf is not installed. Run: mise use -g fzf'
    fi
  else
    echo '[.zshrc] fzf is not installed. Install mise first, then run: mise use -g fzf'
  fi
fi
