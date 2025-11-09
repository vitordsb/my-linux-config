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

run_as_user() {
  sudo -u "$TARGET_USER" -- bash -lc "$1"
}

echo "💻 Instalando ferramentas de desenvolvimento..."
apt install -y python3 python3-pip python3-venv python3-dev python3-setuptools

echo "🐍 Python instalado"

echo "⬇️ Instalando NVM/Node para $TARGET_USER..."
run_as_user 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
run_as_user 'source "$HOME/.nvm/nvm.sh" && nvm install 24 && nvm alias default 24 && nvm use 24 && npm install -g pnpm yarn bun'

echo "✅ Node.js e ferramentas JavaScript configuradas"

echo "☕ Instalando Java, Maven e Gradle..."
apt install -y openjdk-17-jdk maven gradle

echo "🐘 Instalando PHP e extensões..."
apt install -y php php-cli php-common php-curl php-fpm php-gd php-mbstring php-mysql php-xml php-xmlrpc php-zip

echo "📱 Instalando Android Studio..."
ANDROID_STUDIO_VERSION="2025.2.1.7"
ANDROID_STUDIO_TAR="android-studio-${ANDROID_STUDIO_VERSION}-linux.tar.gz"
ANDROID_STUDIO_URL="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${ANDROID_STUDIO_VERSION}/${ANDROID_STUDIO_TAR}"
ANDROID_TMP_DIR="$(mktemp -d)"
pushd "$ANDROID_TMP_DIR" >/dev/null
curl -fLo "$ANDROID_STUDIO_TAR" "$ANDROID_STUDIO_URL"
tar -xzf "$ANDROID_STUDIO_TAR"
rm -rf /opt/android-studio
mv android-studio /opt/
ln -sf /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio
popd >/dev/null
rm -rf "$ANDROID_TMP_DIR"

echo "✅ Ferramentas de desenvolvimento configuradas! vamos instalar o fish"

bash fish.sh
