#!/usr/bin/env bash
set -e
echo "🐧 Baixando e executando setup Linux personalizado..."
git clone https://github.com/vitordsb/my-linux-config.git /tmp/linux-setup
cd /tmp/linux-setup
chmod +x *.sh
sudo ./install.sh
