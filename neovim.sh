
#!/usr/bin/env bash
set -e

echo "📝 Instalando e configurando Neovim..."
add-apt-repository ppa:neovim-ppa/stable -y
apt update && apt install -y neovim

# Cria estrutura de config
mkdir -p ~/.config/nvim
git clone https://github.com/vitordsb/MyNeovim.git
mv ~/MyNeovim/* ~/.config/nvim

echo "✅ Neovim configurado! instalando apps"

bash apps.sh
