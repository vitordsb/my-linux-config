#!/usr/bin/env bash
set -e  # para se o script falhar
set -u  # erro se variável não definida

if [ "$EUID" -ne 0 ]; then
  echo "❌ Execute este script como root (via sudo)."
  exit 1
fi

TARGET_USER="${SUDO_USER:-}"
if [ -z "$TARGET_USER" ] || [ "$TARGET_USER" = "root" ]; then
  echo "❌ Defina um usuário não-root ao executar (ex.: sudo ./install.sh)."
  exit 1
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [ -z "$TARGET_HOME" ]; then
  echo "❌ Não foi possível descobrir o diretório home de $TARGET_USER."
  exit 1
fi

echo "📝 Instalando dependências para compilar o Neovim..."
apt install -y ninja-build gettext libtool libtool-bin autoconf automake pkg-config cmake g++ unzip

echo "🛠️  Compilando Neovim a partir da fonte oficial..."
BUILD_DIR="$(mktemp -d)"
git clone --depth 1 https://github.com/neovim/neovim.git "$BUILD_DIR/neovim"
pushd "$BUILD_DIR/neovim" >/dev/null
make CMAKE_BUILD_TYPE=RelWithDebInfo
make install
popd >/dev/null
rm -rf "$BUILD_DIR"

echo "🧩 Aplicando configuração personalizada..."
NVIM_CONFIG_DIR="$TARGET_HOME/.config/nvim"
install -d -o "$TARGET_USER" -g "$TARGET_USER" "$(dirname "$NVIM_CONFIG_DIR")"
if [ -d "$NVIM_CONFIG_DIR" ]; then
  BACKUP_DIR="${NVIM_CONFIG_DIR}.bak.$(date +%s)"
  echo "📁 Config antiga detectada. Backup em $BACKUP_DIR"
  mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
fi
sudo -u "$TARGET_USER" git clone --depth 1 https://github.com/vitordsb/MyNeovim.git "$NVIM_CONFIG_DIR"
chown -R "$TARGET_USER":"$TARGET_USER" "$NVIM_CONFIG_DIR"

echo "✅ Neovim configurado! instalando apps"

bash apps.sh
