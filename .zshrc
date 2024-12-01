preexec() {
    timer=$(($(date +%s%0N)/1000000))
}
preexec

HISTFILE=~/.local/share/zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt inc_append_history
setopt prompt_subst
setopt share_history
setopt hist_verify
setopt NO_HUP
setopt correct

#
# COMPLETIONS
#

typeset -gaU fpath=($fpath ~/.local/share/zsh/completions)
typeset -gaU fpath=($fpath ~/.local/share/kde-builder/data/completions/zsh/)
zstyle :compinstall filename "$HOME/.zshrc"

local zdump="$HOME/.cache/zdump"

zmodload zsh/zutil
zmodload zsh/complist

eval "$(dircolors)"

zstyle ':completion:*' rehash true
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cmd'
zstyle ':completion:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*' menu select
zstyle ':completion::*' use-cache 'true'
zstyle ':completion::*' cache-path "$HOME/.cache"

# compile completion
autoload -Uz bashcompinit compinit
compinit -d "$zdump"
bashcompinit

if [[ ! "${zdump}.zwc" -nt "$zdump" ]]
then
	zcompile "$zdump"
fi
unset zdump

if [ -f ~/.shell_aliases ]; then
    . ~/.shell_aliases
fi

#
# BINDINGS
#

bindkey '\e[1~'   beginning-of-line  # Linux console
bindkey '\e[H'    beginning-of-line  # xterm
bindkey '\eOH'    beginning-of-line  # gnome-terminal
bindkey '\e[2~'   overwrite-mode     # Linux console, xterm, gnome-terminal
bindkey '\e[3~'   delete-char        # Linux console, xterm, gnome-terminal
bindkey '\e[4~'   end-of-line        # Linux console
bindkey '\e[F'    end-of-line        # xterm
bindkey '\eOF'    end-of-line        # gnome-terminal

bindkey -M emacs '^[[3;5~' kill-word #gnome-terminal and xterm

bindkey -M emacs '^[[3^' kill-word #urxvt

autoload -U select-word-style
select-word-style bash

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
# edit the command line with $EDITOR

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

#
# PROMPT
#

setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git

precmd() {
    if [ $timer ]; then
        local now=$(date +%s%3N)
        local d_ms=$(($now-$timer))
        local d_s=$((d_ms / 1000))
        local ms=$((d_ms % 1000))
        local s=$((d_s % 60))
        local m=$(((d_s / 60) % 60))
        local h=$((d_s / 3600))
        if ((h > 0)); then elapsed=${h}h${m}m
        elif ((m > 0)); then elapsed=${m}m${s}s
        elif ((s >= 10)); then elapsed=${s}.$((ms / 100))s
        elif ((s > 0)); then elapsed=${s}.$((ms / 10))s
        else elapsed=${ms}ms
        fi

        psvar[1]=$elapsed

        unset timer
    fi
    vcs_info
}
local pink="#ff87ff"

PROMPT="%K{blue}[%?]%F{blue}%K{$pink}%f🕛%v%K{#ffffff}%F{$pink}%n%f%K{$pink}%K{$pink}%m%F{$pink}%K{blue}%F{#ffffff}%~%f%F{blue}%k"' ${vcs_info_msg_0_}'"
%K{$pink}%F{#ffffff}%#%k%F{$pink}%k%f"
unset pink

#
# PLUGINS
#

loadPlugin() {
    plugin="/usr/share/zsh/plugins/$1/$1.zsh"
    if [[ -f $plugin ]]; then
        source $plugin
    fi
}

loadPlugin zsh-syntax-highlighting
loadPlugin zsh-autosuggestions

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'

#
# ENV VARS
#

addToPath() {
    if [ -d "$1" ] ; then
        export PATH="$1:$PATH"
    fi
}

export PAGER="most -w"
export EDITOR=nvim

# compiler stuff
export CC="gcc"
export CXX="g++"
# export CFLAGS="-fcolor-diagnostics"
# export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=mold"
export CMAKE_EXPORT_COMPILE_COMMANDS=1
# export CMAKE_COLOR_DIAGNOSTICS=1
# export CMAKE_GENERATOR="Kate - Ninja"
# export QMAKESPEC=linux-clang

export RUSTUP_HOME="$HOME/.local/share/rustup"
export CARGO_HOME="$HOME/.local/share/cargo"
export CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

# npm stuff
export NODE_PATH="$HOME/.local/lib/node_modules:$NODE_PATH"
export npm_config_prefix="$HOME/.local"
export PNPM_HOME="$HOME/.local/share/pnpm"

# path
addToPath "$HOME/.local/bin"
addToPath "/usr/lib/ccache/bin"
addToPath "$PNPM_HOME"
addToPath "$HOME/.deno/bin"

precmd
