autoload -Uz promptinit && promptinit
# prompt adam1

setopt sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Use modern completion system
autoload -Uz compinit && compinit

# ---------------- zsh-autosuggestions ---------------- #
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

bindkey '^Y' autosuggest-accept


zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# If not running interactively, return
[[ $- != *i* ]] && return

# ~/.zshrc: executed by zsh for interactive shells
# ---------------------- Soham's Extra ------------------------

# ---------------- History ---------------- #
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt APPEND_HISTORY          # append to history file, don't overwrite
setopt HIST_IGNORE_DUPS        # no duplicate commands
setopt HIST_IGNORE_SPACE       # ignore lines starting with space
setopt SHARE_HISTORY           # share history between sessions

# ---------------- Locale ---------------- #
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# ---------------- Prompt ---------------- #
autoload -Uz colors && colors
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '

# ---------------- Aliases ---------------- #
alias grep='grep --color=auto'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
  "$(history | tail -n1 | sed -e "s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//")"'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'

# Lazygit & git
alias lg='lazygit'
alias gs='git status'
alias gd='git diff'
alias gl='git log'
alias glo='git log --oneline --graph'

# Python venv helpers
alias act='source .venv/bin/activate'
alias dct='deactivate'

# eza
alias ls='eza -a --icons --group-directories-first --no-quotes'
alias la='eza -la --icons --group-directories-first --no-quotes --header'

alias sc=streamcal
alias n=nvim

# ---------------- Zed ---------------- #
alias c="WGPU_BACKEND=vulkan zeditor"

# ---------------- Functions ---------------- #
bt() { sudo brightnessctl set "$1"% }
pr() { source ~/dotfiles/pr.sh "$@" }
rg() { command rg --json "$@" | delta }

# ---------------- PATH ---------------- #
export PATH=$PATH:/home/soham/.local/bin
export PATH=$PATH:/snap/bin
export PATH=$PATH:$HOME/go/bin
eval "$(mise env -s zsh go)"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# ---------------- FZF ---------------- #
# Find and source fzf keybindings
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
  source /usr/share/fzf/key-bindings.zsh
elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
elif [ -f ~/.fzf/shell/key-bindings.zsh ]; then
  source ~/.fzf/shell/key-bindings.zsh
fi
export FZF_DEFAULT_COMMAND="fd . $HOME"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd -t d . $HOME"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Function to launch fd with fzf and open selection in nvim
fzf_edit_file() {
    local file
    file=$(fd --type f . ~ | fzf --bind "esc:abort")
    if [[ -n "$file" ]]; then
        nvim "$file"
        zle reset-prompt
    fi
}
zle -N fzf_edit_file
bindkey '^f' fzf_edit_file

# ---------------- OhMyPosh ---------------- #
# eval "$(oh-my-posh init zsh --config /home/soham/.oh-my-posh-themes/catppuccin_mocha.omp.json)"

# ---------------- starship ---------------- #
eval "$(starship init zsh)"

# ---------------- Tmux ---------------- #
# if [[ -n $PS1 && -z $TMUX ]]; then
#   tmux new-session -A -s soham -c "$(pwd)"
# fi

# ---------------- Bun ---------------- #
export BUN_INSTALL="$HOME/.bun"

# ---------------- UV ---------------- #
# export UV_NO_MANAGED_PYTHON=1
# export UV_PYTHON_DOWNLOADS=never
export UV_VENV_SEED=1

# ---------------- zoxide ---------------- #
eval "$(zoxide init zsh)"
alias cd=z

# ---------------- mise ---------------- #
eval "$(mise activate zsh)"
mise() { command mise "$@" $([[ $1 == u || $1 == use ]] && echo -g); }
export MISE_NPM_BUN=true
eval "$(mise completion zsh)"

# ---------------- Yazi ---------------- #
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# --------------- .inputrc -----------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

zstyle ':completion:*' menu select
bindkey '^I' menu-complete        # Tab
bindkey '^[Z' reverse-menu-complete  # Shift+Tab

setopt auto_list
setopt auto_menu

# Fix Home/End keys
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line

# Fix Alt+Left/Right (Word Movement)
bindkey "^[[1;3D" backward-word
bindkey "^[[1;3C" forward-word

# Fix Delete key (often needed as well)
bindkey "\e[3~" delete-char

# --- History prefix search with ↑/↓ ---
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[OA' history-beginning-search-backward
bindkey '^[OB' history-beginning-search-forward

autoload -U select-word-style
select-word-style bash
bindkey  "^[[1~"   beginning-of-line
bindkey  "^[[4~"   end-of-line
bindkey "^[[1;3D" backward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[3~" delete-char
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word
