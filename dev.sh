#!/usr/bin/env bash
set -e

echo "💻 Instalando ferramentas de desenvolvimento..."
apt install -y python3 python3-pip python3-venv python3-dev python3-setuptools

echo "Python instalado"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 24
npm install -g pnpm yarn bun

echo "Node, nvm, npm, pnpm, yarn e bun instalado"

apt install -y maven gradle

echo "java, maven e gradle instalado"

apt install -y php php-cli php-common php-curl php-fpm php-gd php-mbstring php-mysql php-xml php-xmlrpc php-zip

echo "✅ Ferramentas de desenvolvimento configuradas! vamos instalar o fish"

bash fish.sh
