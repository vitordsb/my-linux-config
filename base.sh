#!/usr/bin/env bash
set -e  # para se o script falhar
set -u  # erro se variável não definida

echo "📦 Atualizando sistema e instalando pacotes básicos..."
apt update && apt upgrade -y

echo "📦 Instalando pacotes essenciais..."
apt install -y curl cmake wget build-essential software-properties-common unzip neofetch htop preload

echo "📦 Instalando pacotes de fontes..."
apt install -y fonts-firacode fonts-jetbrains-mono
sudo fc-cache -fv

echo "📦 Instalando pacotes de desenvolvimento..."
apt install gnome-tweaks gnome-shell-extensions -y 

apt remove firefox -y --purge
apt remove -y libreoffice* --purge

echo "📦 Instalando o flatpak..."
sudo apt install flatpak
sudo apt install gnome-software-plugin-flatpak
echo "📦 Instalando o Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "✅ Base configurada! vamos instalar as ferramentas de desenvolvimento"

bash dev.sh 
