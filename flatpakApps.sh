#!/usr/bin/env bash
set -e  # para se o script falhar
set -u  # erro se variável não definida

echo "Instalando aplicativos do flatpak"

flatpak install flathub com.obsproject.Studio -y
flatpak install flathub com.google.Chrome -y
flatpak install flathub com.discordapp.Discord -y
flatpak install flathub com.valvesoftware.Steam -y 
flatpak install flathub org.videolan.VLC -y
flatpak install flathub it.mijorus.gearlever -y
flatpak install flathub cc.arduino.IDE2 -y

echo "Aplicativos do flatpak instalados com sucesso!"

echo "Começando a instalar e configurar mysql"
bash mysql.sh
