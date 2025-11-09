#!/usr/bin/env bash
set -e  # para se o script falhar
set -u  # erro se variável não definida

echo "📦 Instalando pacotes essenciais..."
apt install -y curl cmake wget build-essential software-properties-common unzip neofetch htop preload

echo "📦 Instalando pacotes de fontes..."
apt install -y fonts-firacode fonts-jetbrains-mono
sudo fc-cache -fv

echo "📦 Instalando pacotes de desenvolvimento..."
apt install -y gnome-tweaks gnome-shell-extensions

apt remove firefox -y --purge
apt remove -y libreoffice* --purge

echo "📦 Instalando o flatpak..."
apt install -y flatpak
apt install -y gnome-software-plugin-flatpak
echo "📦 Instalando o Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "✅ Base configurada! (módulo base finalizado)"
