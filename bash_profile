#!/bin/bash
[ -r ~/.mac-specific ] && . ~/.mac-specific

fasd_cache="$HOME/.fasd-init-bash"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache

#eval "$(fasd --init auto)"

export EDITOR="nvim"
export VISUAL="nvim"
export HRDAG_GIT_HOME=~/git

#export NVIM_TUI_ENABLE_TRUE_COLOR=1
#export NVIM_TUI_ENABLE_CURSOR_SHAPE=1

export FZF_COMPLETION_TRIGGER='?'

PS1="\n\[\e[32m\]\w\n@ \h (\j): \[\e[0;00m\]"

if [[ -a $(which nvim) ]]
then
    alias vim="nvim"
fi

alias ll="ls -alG --color=always"
alias disks="df -x squashfs -x tmpfs --block-size=M"

function trls() {
    tree -C "$@" | less -R
}

PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# added by Anaconda3 5.3.0 installer
# >>> conda init >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$(CONDA_REPORT_ERRORS=false '/Users/tshah/anaconda3/bin/conda' shell.bash hook 2> /dev/null)"
if [ $? -eq 0 ]; then
    \eval "$__conda_setup"
else
    if [ -f "/Users/tshah/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/tshah/anaconda3/etc/profile.d/conda.sh"
        CONDA_CHANGEPS1=false conda activate base
    else
        \export PATH="/Users/tshah/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda init <<<
export PATH=/Library/Frameworks/GDAL.framework/Programs:$PATH

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# fasd & fzf change directory - jump using `fasd` if given argument, filter output of `fasd` using `fzf` else
j() {
    #[ $# -gt 0 ] && fasd_cd -d "$*" && return
    local dir
    dir="$(fasd -Rdl "$1 " | fzf --height=30% --min-height=3)" && cd "${dir}" || return 1
}
