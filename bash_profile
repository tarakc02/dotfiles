#!/bin/bash

export EDITOR="nvim"
export VISUAL="nvim"
export HRDAG_GIT_HOME=~/git

PS1="\n\[\e[32m\]\w\n@ \h (\j): \[\e[0;00m\]"

if [[ -a $(which nvim) ]]
then
    alias vim="nvim"
fi

alias ll="ls -alG"
alias less="less -R"
alias tree="tree -C"

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
