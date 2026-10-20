FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# fixe uma versão (ex: --build-arg CLAUDE_CODE_VERSION=2.1.0) pra builds reproduzíveis
ARG CLAUDE_CODE_VERSION=latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    openssh-client \
    build-essential \
    clang \
    clangd \
    cmake \
    ninja-build \
    pkg-config \
    python3 \
    python3-venv \
    python3-pip \
    jq \
    less \
    file \
    unzip \
    xz-utils \
    zip \
    procps \
    ripgrep \
    fd-find \
    nodejs \
    npm \
    golang-go \
    nano \
    vim \
    bubblewrap \
    socat \
    && npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# política de sandbox do Bash: managed settings têm precedência máxima e,
# por serem de root, o agente não consegue afrouxá-las
COPY managed-settings.json /etc/claude-code/managed-settings.json

# cria os diretórios com dono ubuntu pra que volumes novos herdem a permissão
RUN id ubuntu \
    && mkdir -p /workspace /home/ubuntu/.claude /home/ubuntu/.npm-global \
    && chown -R ubuntu:ubuntu /workspace /home/ubuntu

# CLAUDE_CONFIG_DIR faz o .claude.json e as credenciais ficarem dentro do volume
ENV CLAUDE_CONFIG_DIR=/home/ubuntu/.claude \
    DISABLE_AUTOUPDATER=1 \
    NPM_CONFIG_PREFIX=/home/ubuntu/.npm-global \
    PATH=/home/ubuntu/.local/bin:/home/ubuntu/.npm-global/bin:/home/ubuntu/go/bin:/usr/local/bin:/usr/bin:/bin

WORKDIR /workspace

USER ubuntu

CMD ["claude"]
