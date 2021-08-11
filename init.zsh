#!/usr/bin/env zsh
# vim:fdm=marker:foldlevel=0:sw=2:ts=2:sts=2
#
# Copyright 2021, laggardkernel and the zsh-gpg-agent contributors
# SPDX-License-Identifier: MIT

# Auto start gpg-agent, auto remove socket before logout
#
# Authors:
#   laggardkernel <laggardkernel@gmail.com>
#

# Return if requirements are not found.
if ! (( $+commands[gpg-agent] )); then
  return 1
fi

# Standardized $0 handling
# 0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"

# path=("${0:h}/bin" "${path[@]}")
# fpath=("${0:h}/functions" "${fpath[@]}")

# export GPG_KEY=$(tty)
export GPG_KEY=$TTY

# Set the default paths to gpg-agent files.
_gpg_agent_conf="${GNUPGHOME:-$HOME/.gnupg}/gpg-agent.conf"

# Integrate with the SSH module.
if { [[ -z "$SSH_TTY" ]] && zstyle -T ':prezto:module:gpg-agent:auto-start' local } || \
  { [[ -n "$SSH_TTY" ]] && zstyle -t ':prezto:module:gpg-agent:auto-start' remote }; then
  if [[ -r $_gpg_agent_conf ]]; then
    # cache detection for ssh agent support
    _cache_file="${TMPDIR:-/tmp}/gpg-agent-cache.$UID.zsh"
    if [[ ! -s "$_cache_file" \
      || "$_gpg_agent_conf" -nt "$_cache_file" ]]; then
      if command grep -q '^enable-ssh-support' "$_gpg_agent_conf"; then 
        echo "_GPG_AGENT_SSH_SUPPORT=1" >| "$_cache_file" 2>/dev/null
      else
        echo "_GPG_AGENT_SSH_SUPPORT=0" >| "$_cache_file" 2>/dev/null
      fi
    fi
    source "$_cache_file"
    unset _cache_file

    if [[ $_GPG_AGENT_SSH_SUPPORT == 1 ]]; then
      # use custom env var _GPG_AGENT_SOCK to remember socket location
      # gpgconf --list-dirs agent-socket, or agent-ssh-socket
      if [[ -z $_GPG_AGENT_SOCK ]]; then
        export _GPG_AGENT_SOCK=$(gpgconf --list-dirs agent-socket)
      fi

      # launch gpg-agent manually, in case it's used as agent for SSH
      if [[ ! -S $_GPG_AGENT_SOCK ]]; then
        gpgconf --launch gpg-agent 2>/dev/null
      fi

      # export socket for agent
      unset SSH_AGENT_PID 2>/dev/null
      # test for the case when the agent is started as `gpg-agent --daemon /bin/sh`
      # https://wiki.archlinux.org/index.php/GnuPG#Set_SSH_AUTH_SOCK
      if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
        if [[ -z $_GPG_AGENT_SSH_SOCK ]]; then
          export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
        else
          export SSH_AUTH_SOCK="$_GPG_AGENT_SSH_SOCK"
        fi
      fi

      # Updates the gpg-agent TTY before every command since
      # there's no way to detect this info in the ssh-agent protocol
      function _gpg-agent-update-tty {
        gpg-connect-agent UPDATESTARTUPTTY /bye &>/dev/null
      }

      autoload -Uz add-zsh-hook
      add-zsh-hook preexec _gpg-agent-update-tty
    fi
  fi
fi

if [[ -n $SSH_TTY ]]; then
  # Force use ncurses-based prompt inside SSH
  export PINENTRY_USER_DATA="USE_CURSES=1"

  # Remove socket file for next gpg-agent remote forwarding
  # in case that `StreamLocalBindUnlink yes` is not set in sshd_config
  if [[ $SHLVL == 1 ]]; then
    function _gpg-agent-clean-socket {
      if [[ -z $_GPG_AGENT_SOCK ]]; then
        export _GPG_AGENT_SOCK=$(gpgconf --list-dirs agent-socket)
      fi

      if [[ -S $_GPG_AGENT_SOCK ]]; then
        gpgconf --kill gpg-agent 2>/dev/null
        command rm -f "$_GPG_AGENT_SOCK" 2>/dev/null
      fi
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook zshexit _gpg-agent-clean-socket
  fi
fi

# Clean up.
unset _gpg_agent_conf
