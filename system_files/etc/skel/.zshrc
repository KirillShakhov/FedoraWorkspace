# fedora-workspace zsh defaults

autoload -Uz compinit colors
colors
compinit

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt share_history
setopt prompt_subst

HISTFILE="${HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{cyan}git:%b%f'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}git:%b|%a%f'

precmd() {
  vcs_info
}

prompt_status() {
  local code=$?
  if [[ $code -ne 0 ]]; then
    print -n "%F{red}x${code}%f "
  fi
}

PROMPT='$(prompt_status)%F{green}%n%f@%F{blue}%m%f %F{magenta}%~%f${vcs_info_msg_0_}
%F{cyan}>%f '

alias ll='ls -lah'
alias la='ls -A'
alias gs='git status --short --branch'
alias gl='git log --oneline --decorate --graph --all -20'
alias dc='docker compose'

export EDITOR="${EDITOR:-nano}"
export VISUAL="${VISUAL:-nano}"
