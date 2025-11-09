#!/usr/bin/env bash
set -e  # para se o script falhar
set -u  # erro se variável não definida

echo "🚀 Iniciando configuração do sistema..."

# Garantir que está com sudo ativo
if [ "$EUID" -ne 0 ]; then
  echo "❌ Execute com: sudo ./install.sh"
  exit 1
fi

if [ -z "${SUDO_USER:-}" ] || [ "$SUDO_USER" = "root" ]; then
  echo "❌ Execute com sudo a partir de um usuário não-root (ex.: sudo ./install.sh)."
  exit 1
fi

# Executa módulos
bash base.sh

echo "✅ Instalação completa!"
