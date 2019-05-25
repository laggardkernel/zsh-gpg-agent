# gpg-agent

[![License: MIT][license icon]][license]

ZSH plugin. Goodies for `gpg-agent` like autostart, `SSH_AUTH_SOCK` `export` and
remote socket cleanup, etc.

The plugin is designed as a [Prezto][prezto] module, but it's also
compatible with other plugin managers.

## Features
Manually start `gpg-agent` in case it's used as agent for SSH.

Set the startup `TTY` and `X-DISPLAY` variables to direct future pinentry invocations
to another screen. (The settings are needed when `gpg-agent` is used for SSH auth.)

On remote machine (SSH connection), force ncurses-based prompt for paraphrase input.

The plugin also remove the agent socket when logout from SSH, cause overwriting an existing
socket file in remote forwarding is disabled by default.

The plugin is designed as a replacement for existing gpg plugins
from Oh-My-ZSH and Prezto, both of which are outdated:
1. `gpg` command auto starts the `gpg-agent`. There's no need to start it
manually unless `gpg-agent` is used for SSH
2. `GPG_AGENT_INFO` is removed in GnuPG 2.1.0
3. New subcommands are introduced to detect socket location

## Installation

### [Zplugin][zplugin]

The only ZSH plugin manager solves the time-consuming init for
`nvm`, `nodenv`, `pyenv`, `rvm`, `rbenv`, `thefuck`, `fasd`, etc,
with its amazing async [Turbo Mode][turbo mode].

```zsh
zplugin ice wait'1' lucid
zplugin light laggardkernel/zsh-gpg-agent
```

### [Prezto][prezto]

The only framework does **optimizations** in plugins with sophisticated coding skill:
- [refreshing `.zcompdump` every 20h][prezto zcompdump 1]
- [compiling `.zcompdump` as bytecode in the background][prezto zcompdump 2]
- [caching init script for fasd][prezto fasd]
- saving `*env` startup time with [`init - --no-rehash` for `rbenv`, `pyenv`, `nodenv`][prezto *env]
- [removing the horribly time-consuming `brew command` from `command-not-found`][prezto brew command]

```zsh
mkdir -p ${ZDOTDIR:-$HOME}/.zprezto/contrib 2>/dev/null
git clone https://github.com/laggardkernel/zsh-gpg-agent.git ${ZDOTDIR:-$HOME}/.zprezto/contrib/gpg-agent
```

## Settings
### Socket Location
Using `gpgconf --list-dir agent-socket` to get the socket location is not the
fastest, but the most compatible. To speed up the location detection for
sockets, you may wanna set the following variables before the plugin is loaded.

```zsh
if [[ $OSTYPE == darwin* ]]; then
  _GPG_AGENT_SOCK="${HOME}/.gnupg/S.gpg-agent"
  _GPG_AGENT_SSH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
elif [[ $OSTYPE == linux* ]]; then
  _GPG_AGENT_SOCK="${XDG_RUNTIME_DIR}/.gnupg/S.gpg-agent"
  _GPG_AGENT_SSH_SOCK="${XDG_RUNTIME_DIR}/.gnupg/S.gpg-agent.ssh"
fi
```

### Auto Start
`gpg-agent` auto start and `SSH_AUTH_SOCK` `export` could be controlled by `zstyle` settings,

```zsh
zstyle ':prezto:module:gpg-agent:auto-start' local 'yes' # default yes
zstyle ':prezto:module:gpg-agent:auto-start' remote 'no' # default no
```

**Note**: `gpg-agent` autostart is disabled by default on remote machine.

## TODO
- [ ] Cache `ssh-agent-support` detection for GnuPG

## License

The MIT License (MIT)

Copyright (c) 2019 laggardkernel

[license icon]: https://img.shields.io/badge/License-MIT-blue.svg
[license]: https://opensource.org/licenses/MIT

[zplugin]: https://github.com/zdharma/zplugin
[turbo mode]: https://github.com/zdharma/zplugin#turbo-mode-zsh--53

[prezto]: https://github.com/sorin-ionescu/prezto
[prezto zcompdump 1]: https://github.com/sorin-ionescu/prezto/blob/4abbc5572149baa6a5e7e38393a4b2006f01024f/modules/completion/init.zsh#L31-L41
[prezto zcompdump 2]: https://github.com/sorin-ionescu/prezto/blob/4abbc5572149baa6a5e7e38393a4b2006f01024f/runcoms/zlogin#L9-L15
[prezto fasd]: https://github.com/sorin-ionescu/prezto/blob/4abbc5572149baa6a5e7e38393a4b2006f01024f/modules/fasd/init.zsh#L22-L36
[prezto *env]: https://github.com/sorin-ionescu/prezto/blob/4abbc5572149baa6a5e7e38393a4b2006f01024f/modules/python/init.zsh#L22
[prezto brew command]: https://github.com/sorin-ionescu/prezto/blob/4abbc5572149baa6a5e7e38393a4b2006f01024f/modules/command-not-found/init.zsh
