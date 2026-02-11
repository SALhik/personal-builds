FROM debian:bookworm-slim AS base

ENV \
  DEBIAN_FRONTEND=noninteractive \
  CCACHE_DIR=/var/cache/ccache

RUN mkdir -p \
  /var/cache/ccache

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    build-essential \
    cmake \
    ccache \
    ninja-build \
    bash && \
  rm -rf /var/lib/apt/lists/*

RUN cat <<'EOF' >> /etc/bash.bashrc
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTCONTROL=ignoredups:erasedups
export HISTIGNORE='&:[ ]*:exit:clear'
shopt -s histappend
shopt -s cmdhist
PROMPT_COMMAND='history -a; history -n'
EOF

FROM base AS node

ENV NPM_CONFIG_CACHE=/var/cache/npm

RUN mkdir -p \
  /var/cache/npm \
  /var/cache/pnpm

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
  apt-get update && \
  apt-get install -y --no-install-recommends nodejs && \
  rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm tsx typescript ovsx @vscode/vsce

RUN npm config set cache /var/cache/npm --global && \
  pnpm config set store-dir /var/cache/pnpm --global

FROM node AS final

WORKDIR /main
