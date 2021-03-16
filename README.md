# workflows

dotfiles, personal scripts, etc.

## general


## email

note: i only sync my email on my work machine, a macbook, so haven't tested the
setup with other types of OS.

i use [neomutt](https://neomutt.org/) for most of my email reading, searching,
sending, etc.. but it's configured using
[mbsync](http://isync.sourceforge.net/mbsync.html),
[notmuch](https://notmuchmail.org/), and [msmtp](https://marlam.de/msmtp/)

i use `mbsync` to sync my local mailbox with my mail server, and `notmuch` to
index and search the mail. `email/services` includes the service to sync
mailboxes and index new messages every 2 minutes.

from the command line, i can search for messages using notmuch, for example:

```
@ butterfly (0): notmuch search from:tarak date:last_week subject:"Week of"

thread:0000000000000c0e     March 16 [1/1] Tarak Shah; TS week of 16 March 2020 (new)
```

tmux is set up to use vim keybindings in paste mode, which makes it convenient
to quickly navigate the cursor and yank the thread id if i want to view the
message/thread:

- `my show` opens the thread in vim
- `my reply` creates a reply and opens it in vim. in this case, i use `msmtp`
  to send the resulting message


-----

i use [neomutt](https://neomutt.org/) to put everything together
