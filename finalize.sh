#!/usr/bin/env bash
set -e

echo "🧹 Limpando pacotes desnecessários..."
apt autoremove -y && apt clean

echo "🔁 Rebootando sistema em 5s..."
sleep 5 && reboot
