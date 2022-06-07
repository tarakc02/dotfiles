#!/bin/bash

# env setups for homebrew, conda, etc. that include hardcoded paths
[ -r "$HOME/.local-bash-env" ] && . "$HOME/.local-bash-env"

fasd_cache="$HOME/.fasd-init-bash"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache

export LC_ALL="en_US.UTF-8"
export EDITOR="nvim"
export VISUAL="nvim"
export HRDAG_GIT_HOME=~/git

# note: on newer macs, if you use bash you get a message about the default
# shell being zsh
export BASH_SILENCE_DEPRECATION_WARNING=1

export FZF_COMPLETION_TRIGGER='?'

PS1="\n\[\e[32m\]\w\n@ \h (\j): \[\e[0;00m\]"

if [[ -a $(which nvim) ]]
then
    alias vim="nvim"
fi

alias ll="ls -alhG --color=always"
alias disks="df -h -x squashfs -x tmpfs"
alias lynx="lynx -cfg=$HOME/.lynxrc -lss=$HOME/.lynx.lss"
alias csv="column -s'|' -t"

function trls() {
    tree -C "$@" | less -R
}

PATH="$HOME/bin:$HOME/.local/bin:$PATH"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# fasd & fzf change directory - jump using `fasd` if given argument, filter output of `fasd` using `fzf` else
j() {
    #[ $# -gt 0 ] && fasd_cd -d "$*" && return
    local dir
    dir="$(fasd -Rdl "$1 " | fzf --height=30% --min-height=3)" && cd "${dir}" || return 1
}
