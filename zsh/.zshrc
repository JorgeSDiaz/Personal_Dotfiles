# ── Guard: solo interactivo ────────────────────────────────
[[ $- != *i* ]] && return

# ── Historial ──────────────────────────────────────────────
[[ -d "${XDG_STATE_HOME}/zsh" ]] || mkdir -p "${XDG_STATE_HOME}/zsh"
HISTFILE="${XDG_STATE_HOME}/zsh/history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # compartir historial entre terminales
setopt EXTENDED_HISTORY       # guardar timestamp de cada comando
setopt HIST_IGNORE_DUPS       # no guardar duplicados consecutivos
setopt HIST_IGNORE_ALL_DUPS   # eliminar duplicados anteriores del historial
setopt HIST_IGNORE_SPACE      # no guardar comandos que empiecen con espacio
setopt HIST_REDUCE_BLANKS     # eliminar blancos redundantes
setopt HIST_EXPIRE_DUPS_FIRST # expirar duplicados primero al truncar
setopt HIST_VERIFY            # confirmar expansión de historial antes de ejecutar

# ── Comportamiento del shell ────────────────────────────────
setopt AUTO_CD               # escribe un directorio y entra en él directamente
setopt CORRECT               # sugiere corrección de typos en comandos
setopt NO_BEEP               # silencia el pitido del terminal
setopt GLOB_DOTS             # incluye dotfiles en los globs (*, **)
setopt EXTENDED_GLOB         # habilita patrones glob avanzados (^, ~, #)
setopt INTERACTIVE_COMMENTS  # permite # comentarios en shell interactivo

# ── Autocompletado ──────────────────────────────────────────
autoload -Uz compinit
_comp_dump="${XDG_CACHE_HOME}/zsh/zcompdump"
[[ -d "${XDG_CACHE_HOME}/zsh" ]] || mkdir -p "${XDG_CACHE_HOME}/zsh"
if [[ -f "$_comp_dump" ]] && [[ -z "$_comp_dump"(#qN.mh+24) ]]; then
  compinit -C -d "$_comp_dump"  # skip security check: dump < 24h
else
  compinit -d "$_comp_dump"
fi
unset _comp_dump

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/compcache"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|=*' 'l:|=* r:|=*'  # case-insensitive + fuzzy
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"                      # colores en la lista
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'            # descripciones
zstyle ':completion:*:warnings' format '%F{red}sin coincidencias para: %d%f'
zstyle ':completion::complete:*' gain-privileges 1                           # completado con sudo

# ── Plugins (pacman) ───────────────────────────────────────
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── fzf ────────────────────────────────────────────────────
if (( $+commands[fzf] )); then
  source <(fzf --zsh)  # Ctrl+R historial fuzzy, Ctrl+T archivos, Alt+C directorios
  export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --info=inline"
fi

# ── Keybindings ─────────────────────────────────────────────
bindkey '^[[A'    history-search-backward   # ↑ busca en historial por prefijo
bindkey '^[[B'    history-search-forward    # ↓
bindkey '^H'      backward-kill-word        # Ctrl+Backspace borra palabra
bindkey '^[[3;5~' kill-word                 # Ctrl+Delete borra palabra adelante
bindkey '^[[1;5C' forward-word              # Ctrl+→ salta palabra adelante
bindkey '^[[1;5D' backward-word             # Ctrl+← salta palabra atrás
bindkey '^[f'     forward-word              # Alt+f  salta palabra adelante
bindkey '^[b'     backward-word             # Alt+b  salta palabra atrás
bindkey '^A'      beginning-of-line         # Ctrl+A va al inicio
bindkey '^E'      end-of-line               # Ctrl+E va al final

# Palabras delimitadas solo por espacios y /  (Ctrl+W/Backspace más predecible)
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# ── Aliases: navegación ─────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ── Aliases: utilidades ─────────────────────────────────────
alias ls='lsd --color=auto'
alias ll='lsd -lah --color=auto'
alias lt='lsd --tree --color=auto'
alias grep='grep --color=auto'
alias cp='cp -iv'        # confirmación + verbose
alias mv='mv -iv'        # confirmación + verbose
alias rm='rm -iv'        # confirmación + verbose
alias mkdir='mkdir -pv'  # crea directorios intermedios + verbose
alias df='df -h'
alias du='du -sh'
alias free='free -h'

# ── Aliases: herramientas ───────────────────────────────────
alias v='nvim'
alias cat='bat --style=plain'
alias lg='lazygit'
alias lzd='lazydocker'
alias top='btop'
alias c='claude'
alias csp='claude --dangerously-skip-permissions'
alias o='opencode'

# ── Funciones ───────────────────────────────────────────────

# mkcd: crea un directorio y entra en él
mkcd() { mkdir -p "$1" && cd "$1" }

# extract: descomprime cualquier archivo
extract() {
  if [[ ! -f "$1" ]]; then
    echo "extract: '$1' no es un archivo válido"
    return 1
  fi
  case "$1" in
    *.tar.bz2)  tar xjf "$1"          ;;
    *.tar.gz)   tar xzf "$1"          ;;
    *.tar.xz)   tar xJf "$1"          ;;
    *.tar.zst)  tar --zstd -xf "$1"   ;;
    *.bz2)      bunzip2 "$1"          ;;
    *.gz)       gunzip "$1"           ;;
    *.zip)      unzip "$1"            ;;
    *.7z)       7z x "$1"             ;;
    *.rar)      unrar x "$1"          ;;
    *.xz)       unxz "$1"             ;;
    *.zst)      zstd -d "$1"          ;;
    *)          echo "extract: formato no reconocido: '$1'"; return 1 ;;
  esac
}

# ── Herramientas externas ──────────────────────────────────
(( $+commands[mise] ))     && eval "$(mise activate zsh)"
(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[zoxide] ))   && eval "$(zoxide init zsh)"

. "$HOME/.local/share/../bin/env"

# opencode
export PATH=/home/david/.opencode/bin:$PATH
