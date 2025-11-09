#!/usr/bin/env bash
set -e  # para se o script falhar
set -u  # erro se variável não definida

echo "Instalando aplicativos do flatpak"

flatpak install -y --noninteractive flathub com.obsproject.Studio
flatpak install -y --noninteractive flathub com.google.Chrome
flatpak install -y --noninteractive flathub com.discordapp.Discord
flatpak install -y --noninteractive flathub com.valvesoftware.Steam 
flatpak install -y --noninteractive flathub org.videolan.VLC
flatpak install -y --noninteractive flathub it.mijorus.gearlever
flatpak install -y --noninteractive flathub cc.arduino.IDE2

echo "Aplicativos do flatpak instalados com sucesso!"

echo "Começando a instalar e configurar mysql"
bash mysql.sh
