# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download zinit if we don't have it yet
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
# On Linux/WSL, system vendor-completions can reference missing files (e.g. _docker when Docker isn't installed).
# Remove that path before compinit to avoid "no such file or directory" errors. Safe on macOS (path usually not in fpath).
if [[ "$OSTYPE" == linux* ]] && (( ${fpath[(I)/usr/share/zsh/vendor-completions]} )); then
  fpath=("${(@)fpath:#/usr/share/zsh/vendor-completions}")
fi
autoload -Uz compinit && compinit

zinit cdreplay -q

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

# --- mise + tools (install on first run if missing) ---
MISE_BIN=~/.local/bin/mise

_zshrc_ensure_mise() {
  if [[ -x $MISE_BIN ]]; then
    eval "$($MISE_BIN activate zsh)"
    return
  fi
  if [[ -o interactive ]]; then
    read -q "?Install mise? (y/n) "
    echo
    if [[ $REPLY =~ ^[yY]$ ]]; then
      curl -fsSL https://mise.run | sh
      eval "$($MISE_BIN activate zsh)"
    fi
  else
    echo '[.zshrc] mise is not installed. Install it with: curl https://mise.run | sh'
  fi
}

# Usage: _zshrc_ensure_via_mise <cmd> "Prompt? (y/n) " 'init command to eval'
_zshrc_ensure_via_mise() {
  local cmd=$1
  local prompt_msg=$2
  local init_cmd=$3
  if command -v $cmd &>/dev/null; then
    eval "$init_cmd"
    return
  fi
  if [[ ! -x $MISE_BIN ]]; then
    echo "[.zshrc] $cmd is not installed. Install mise first, then run: mise use -g $cmd"
    return
  fi
  if [[ -o interactive ]]; then
    read -q "?$prompt_msg"
    echo
    if [[ $REPLY =~ ^[yY]$ ]]; then
      $MISE_BIN use -g $cmd
      eval "$($MISE_BIN activate zsh)"
      command -v $cmd &>/dev/null && eval "$init_cmd"
    fi
  else
    echo "[.zshrc] $cmd is not installed. Run: mise use -g $cmd"
  fi
}

_zshrc_ensure_mise
_zshrc_ensure_via_mise fzf "Install fzf with mise? (y/n) " 'eval "$(fzf --zsh)"'
_zshrc_ensure_via_mise starship "Install starship with mise? (y/n) " 'eval "$(starship init zsh)"'

unfunction _zshrc_ensure_mise _zshrc_ensure_via_mise
