#!/usr/bin/env bash

fzf_command='fzf --reverse --margin 15%,0'
fd_command="fasd -type d"

folder="$($fd_command | $fzf_command)"

echo "push 's$folder'"
