#!/usr/bin/env bash
set -e

echo "📦 Atualizando sistema e instalando pacotes básicos..."
apt update && apt upgrade -y

echo "📦 Instalando pacotes essenciais..."
apt install -y curl wget git build-essential software-properties-common unzip neofetch htop preload

echo "📦 Instalando pacotes de fontes..."
apt install -y fonts-firacode fonts-jetbrains-mono

echo "📦 Instalando pacotes de desenvolvimento..."
apt install gnome-tweaks gnome-shell-extensions -y 

apt remove firefox -y --purge
apt remove -y libreoffice* --purge
