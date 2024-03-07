#!/usr/bin/env sh

# based on https://github.com/wincent/wincent/blob/master/roles/dotfiles/files/.mutt/scripts/view_mail.sh

COLUMNS=${COLUMNS:-`tput cols`}
TMPFILE="$1"
#ENCODING="${2:utf-8}"

# Need to copy the file because mutt will delete it before Vim can read it.
DIR=$(mktemp -d)
cp "$TMPFILE" "$DIR/preview"
TMPFILE="$DIR/preview"

if [ -z "$TMUX" ]; then
  nvim -R '+set filetype=mail' '+set nofoldenable' '+set nomodifiable' '+Goyo' "$TMPFILE"
elif [ "$COLUMNS" -gt 180 ]; then
  tmux split-window -l 50% -h \
    nvim -R '+set filetype=mail' '+set nofoldenable' '+set nomodifiable' '+Goyo' "$TMPFILE"
else
  tmux split-window -l 50% -v \
    nvim -R '+set filetype=mail' '+set nofoldenable' '+set nomodifiable' '+Goyo' "$TMPFILE"
fi
