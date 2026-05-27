[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "$(dirname "$HISTFILE")"
HISTSIZE=32768
SAVEHIST=32768
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
else
  alias ls='ls --color=auto -a'
fi

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

swl() {
    setsid "$@" >/dev/null 2>&1 &
    exit
}

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

typeset -g VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=false
typeset -g VI_MODE_SET_CURSOR=true

typeset -g VI_MODE_CURSOR_NORMAL=2
typeset -g VI_MODE_CURSOR_VISUAL=6
typeset -g VI_MODE_CURSOR_INSERT=6
typeset -g VI_MODE_CURSOR_OPPEND=0

typeset -g VI_KEYMAP=main

function _vi-mode-set-cursor-shape-for-keymap() {
  [[ "$VI_MODE_SET_CURSOR" = true ]] || return

  local _shape=0
  case "${1:-${VI_KEYMAP:-main}}" in
    main)    _shape=$VI_MODE_CURSOR_INSERT ;;
    viins)   _shape=$VI_MODE_CURSOR_INSERT ;;
    isearch) _shape=$VI_MODE_CURSOR_INSERT ;;
    command) _shape=$VI_MODE_CURSOR_INSERT ;;
    vicmd)   _shape=$VI_MODE_CURSOR_NORMAL ;;
    visual)  _shape=$VI_MODE_CURSOR_VISUAL ;;
    viopp)   _shape=$VI_MODE_CURSOR_OPPEND ;;
    *)       _shape=0 ;;
  esac
  printf $'\e[%d q' "${_shape}"
}

function _visual-mode {
  typeset -g VI_KEYMAP=visual
  _vi-mode-set-cursor-shape-for-keymap "$VI_KEYMAP"
  zle .visual-mode
}
zle -N visual-mode _visual-mode

function _vi-mode-should-reset-prompt() {
  if [[ -z "${VI_MODE_RESET_PROMPT_ON_MODE_CHANGE:-}" ]]; then
    [[ "${PS1} ${RPS1}" = *'$(vi_mode_prompt_info)'* ]]
    return $?
  fi
  [[ "${VI_MODE_RESET_PROMPT_ON_MODE_CHANGE}" = true ]]
}

function zle-keymap-select() {
  typeset -g VI_KEYMAP=$KEYMAP
  if _vi-mode-should-reset-prompt; then
    zle reset-prompt
    zle -R
  fi
  _vi-mode-set-cursor-shape-for-keymap "${VI_KEYMAP}"
}
zle -N zle-keymap-select

function zle-line-init() {
  local prev_vi_keymap="${VI_KEYMAP:-}"
  typeset -g VI_KEYMAP=main
  [[ "$prev_vi_keymap" != 'main' ]] && _vi-mode-should-reset-prompt && zle reset-prompt
  (( ! ${+terminfo[smkx]} )) || echoti smkx
  _vi-mode-set-cursor-shape-for-keymap "${VI_KEYMAP}"
}
zle -N zle-line-init

function zle-line-finish() {
  typeset -g VI_KEYMAP=main
  (( ! ${+terminfo[rmkx]} )) || echoti rmkx
  _vi-mode-set-cursor-shape-for-keymap default
}
zle -N zle-line-finish

bindkey -v

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'vv' edit-command-line

bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^r' history-incremental-search-backward