# dotfiles

Personal dotfiles, scripts, and configuration.

## Dependencies

Core tools (install via package manager):

- neovim
- tmux
- fzf
- zoxide
- ripgrep

## Installation

Clone the repository and create symlinks manually:

```bash
# Shell
ln -s ~/git/dotfiles/bash_profile ~/.bash_profile
ln -s ~/git/dotfiles/zshrc ~/.zshrc
ln -s ~/git/dotfiles/inputrc ~/.inputrc

# Neovim
mkdir -p ~/.config/nvim
ln -s ~/git/dotfiles/nvim/vimrc ~/.config/nvim/init.vim
ln -s ~/git/dotfiles/nvim/after ~/.config/nvim/after
ln -s ~/git/dotfiles/nvim/colors ~/.config/nvim/colors
ln -s ~/git/dotfiles/nvim/ftdetect ~/.config/nvim/ftdetect
ln -s ~/git/dotfiles/nvim/snippets ~/.config/nvim/snippets
ln -s ~/git/dotfiles/nvim/syntax ~/.config/nvim/syntax

# Tmux
ln -s ~/git/dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -s ~/git/dotfiles/tmux/tmux-<machine>.conf ~/.tmux-local.conf

# Git
ln -s ~/git/dotfiles/gitconfig ~/.gitconfig

# Scripts (add to PATH or symlink individually)
ln -s ~/git/dotfiles/scripts/my ~/bin/my
```

After symlinking neovim config, install plugins:

```bash
nvim +PlugInstall +qall
```

## Email

macOS-only setup for terminal-based email using Fastmail.

### Software Stack

| Tool | Purpose | Config file |
|------|---------|-------------|
| mbsync (isync) | IMAP sync to local Maildir | `email/mbsyncrc` |
| notmuch | Mail indexing and search | `email/notmuch-config` |
| neomutt | Mail client UI | `email/muttrc` |
| msmtp | SMTP for sending | `email/msmtprc` |

### Configuration

```bash
ln -s ~/git/dotfiles/email/mbsyncrc ~/.mbsyncrc
ln -s ~/git/dotfiles/email/muttrc ~/.muttrc
ln -s ~/git/dotfiles/email/mutt-colors.muttrc ~/.mutt-colors.muttrc
ln -s ~/git/dotfiles/email/msmtprc ~/.msmtprc
ln -s ~/git/dotfiles/email/notmuch-config ~/.notmuch-config
ln -s ~/git/dotfiles/email/mailcap ~/.mailcap

# Create mail directory
mkdir -p ~/Mail/hrdag
```

### Authentication

Passwords are stored GPG-encrypted and decrypted at runtime:

```
~/.mutt/passwords/fastmail.gpg
```

Both mbsync and msmtp retrieve the password via:
```bash
gpg --quiet --for-your-eyes-only --no-tty -d ~/.mutt/passwords/fastmail.gpg
```

To create the encrypted password file:
```bash
mkdir -p ~/.mutt/passwords
echo "your-app-password" | gpg -e -r your@email.com -o ~/.mutt/passwords/fastmail.gpg
```

Use a Fastmail app-specific password, not your main account password.

### Background Sync

A launchd service syncs mail every 2 minutes:

```bash
cp ~/git/dotfiles/email/services/org.tshah.mbsync.service.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/org.tshah.mbsync.service.plist
```

The service runs `mbsync -a` followed by `notmuch new` to sync and index.

### Usage

Search mail from command line:
```bash
notmuch search from:someone date:last_week subject:"topic"
```

View or reply using the `my` script:
```bash
my show thread:0000000000000abc
my reply thread:0000000000000abc
```

Or use neomutt directly for a full UI.
