#!/usr/bin/env bash
set -e  # para se o script falhar
set -u  # erro se variável não definida

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

apt install android

apt install -y php php-cli php-common php-curl php-fpm php-gd php-mbstring php-mysql php-xml php-xmlrpc php-zip

echo "✅ Ferramentas de desenvolvimento configuradas! vamos instalar o fish"

echo "📱 Instalando Android Studio..."
curl -L -O https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2025.2.1.7/android-studio-2025.2.1.7-linux.tar.gz
tar -xvzf android-studio-2025.2.1.7-linux.tar.gz
sudo mv android-studio /opt/
echo 'export PATH=$PATH:/opt/android-studio/bin' >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
sudo chmod +x studio.sh
./studio.sh

echo "✅ Android Studio configurado!"

bash fish.sh
