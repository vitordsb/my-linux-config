#!/usr/bin/env bash
set -e  # para se o script falhar
set -u  # erro se variável não definida

echo "🧹 Limpando pacotes desnecessários..."
apt autoremove -y && apt clean

echo "🔁 Rebootando sistema em 5s..."
sleep 5 && reboot
