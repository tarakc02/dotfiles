#!/usr/bin/env sh

# based on https://github.com/wincent/wincent/blob/master/roles/dotfiles/files/.mutt/scripts/view_mail.sh

COLUMNS=${COLUMNS:-`tput cols`}

if [ -z "$TMUX" ]; then
  nvim '+set filetype=mail' '+set syntax=markdown' '+set nofoldenable' '+Goyo' "$1"
elif [ "$COLUMNS" -gt 180 ]; then
    tmux split-window -l 50% -h \
        neomutt -F '~/.mutt/editor.muttrc' '-H' "$1"
else
    tmux split-window -l 50% -v \
        neomutt -F '~/.mutt/editor.muttrc' '-H' "$1"
fi

rm "$1"

# done.
