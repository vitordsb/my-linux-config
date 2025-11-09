#!/usr/bin/env bash
set -e  # para se o script falhar
set -u  # erro se variável não definida

echo "🧹 Limpando pacotes desnecessários..."
apt autoremove -y && apt clean

if [ "${LINUX_SETUP_SKIP_REBOOT:-0}" = "1" ]; then
    echo "ℹ️  Reboot automático adiado (será tratado pelo instalador principal)."
else
    echo "🔁 Rebootando sistema em 5s..."
    sleep 5 && reboot
fi
