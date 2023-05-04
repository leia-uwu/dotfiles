function preexec() {
    timer=$(($(date +%s%0N)/1000000))
}
preexec

HISTFILE=~/.local/share/zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt NO_HUP
setopt correct

zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit -d ~/.cache/zcompdump

eval "$(dircolors)"

zstyle ':completion:*' rehash true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cmd'
zstyle ':completion:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*' menu select

autoload bashcompinit
bashcompinit

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -f ~/.shell_aliases ]; then
    . ~/.shell_aliases
fi

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

# prompt
setopt promptsubst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn

vcs_info_wrapper() {
    vcs_info
    if [ -n "$vcs_info_msg_0_" ]; then
        echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
    fi
}

function precmd() {
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
}

PROMPT="[%F{yellow}%?%f](%F{cyan}%v%f)%F{red}%n%f@%F{blue}%m%F{green} %B%~%b%f"' $(vcs_info_wrapper)'$'\n%# '

if [[ -f "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
if [[ -f "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'

export PAGER="most -w"
export LC_MONETARY=pt_BR.UTF-8
export EDITOR=vim

# compiler stuff
export CC="clang"
export CXX="clang++"
export CFLAGS="-fcolor-diagnostics"
export CXXFLAGS="$CFLAGS"
#export LDFLAGS="-fuse-ld=mold"
export CMAKE_EXPORT_COMPILE_COMMANDS=1
export CMAKE_COLOR_DIAGNOSTICS=1
export CMAKE_GENERATOR="Kate - Ninja"
export QMAKESPEC=linux-clang

if [ -d "/usr/lib/ccache/bin" ] ; then
    export PATH="/usr/lib/ccache/bin/:$PATH"
fi

export RUSTUP_HOME="$HOME/.local/share/rustup"
export CARGO_HOME="$HOME/.local/share/cargo"
export CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

# npm stuff
export NODE_PATH="$HOME/.local/lib/node_modules:$NODE_PATH"
export npm_config_prefix="$HOME/.local"
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# edit the command line with $EDITOR

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# kdesrc-build #################################################################

## Add kdesrc-build to PATH
export PATH="$HOME/kde/src/kdesrc-build:$PATH"

## Autocomplete for kdesrc-run
function _comp_kdesrc_run {
    local cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Complete only the first argument
    if [[ $COMP_CWORD != 1 ]]; then
        return 0
    fi

    # Retrieve build modules through kdesrc-run
    # If the exit status indicates failure, set the wordlist empty to avoid
    # unrelated messages.
    local modules
    if ! modules=$(kdesrc-run --list-installed);
    then
        modules=""
    fi

    # Return completions that match the current word
    COMPREPLY=( $(compgen -W "${modules}" -- "$cur") )

    return 0
}

## Register autocomplete function
complete -o nospace -F _comp_kdesrc_run kdesrc-run

################################################################################

precmd
