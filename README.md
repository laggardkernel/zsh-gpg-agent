# gpg-agent

[![License: MIT][license icon]][license]

## Features
Manually start `gpg-agent` in case it's used as agent for SSH.

Set the startup TTY and X-DISPLAY variables to direct future pinentry invocations to another screen. (Needed when `gpg-agent` is used for SSH auth.)

Clean the agent socket when logout from SSH, cause overwriting an existing
socket file in remote forwarding is disabled by default.

This plugin is designed as a replacement for existing gpg plugins
from Oh-My-ZSH and Prezto are outdated.
1. `gpg` command auto starts the `gpg-agent`. There's no need to start it
manually unless `gpg-agent` is used for SSH
2. `GPG_AGENT_INFO` is removed in GnuPG 2.1.0
3. New subcommands are introduced to detect socket location

## Settings
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

## License

The MIT License (MIT)

Copyright (c) 2019 laggardkernel

[license icon]: https://img.shields.io/badge/License-MIT-blue.svg
[license]: https://opensource.org/licenses/MIT
