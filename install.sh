#!/usr/bin/env bash
set -e  # para se o script falhar
set -u  # erro se variável não definida

echo "🚀 Iniciando configuração do sistema..."

# Garantir que está com sudo ativo
if [ "$EUID" -ne 0 ]; then
  echo "❌ Execute com: sudo ./install.sh"
  exit
fi

# Executa módulos
bash base.sh
bash dev.sh
bash ui.sh
bash apps.sh
bash neovim.sh
bash zsh.sh
bash finalize.sh

echo "✅ Instalação completa!"
