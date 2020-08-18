#!/usr/bin/env sh

COLUMNS=${COLUMNS:-`tput cols`}

dir=$(mktemp -d)
tmpfile="$dir/preview"

cat > $tmpfile

if [ -z "$TMUX" ]; then
  nvim -R '+set filetype=mail' '+set nofoldenable' '+set nomodifiable' '+Goyo' "$tmpfile"
elif [ "$COLUMNS" -gt 180 ]; then
  tmux split-window -p 50 -h \
    nvim -R '+set filetype=article' '+set nomodifiable' '+Goyo' "$tmpfile"
else
  tmux split-window -p 50 -v \
    nvim -R '+set filetype=article' '+set nomodifiable' '+Goyo' "$tmpfile"
fi
