
#!/usr/bin/env bash
set -e

echo "📝 Instalando neovim pelo github"
git clone https://github.com/neovim/neovim.git && cd neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install

cd ..

# Cria estrutura de config
mkdir -p ~/.config/nvim
git clone https://github.com/vitordsb/MyNeovim.git
sudo mv ~/MyNeovim/* ~/.config/nvim

echo "✅ Neovim configurado! instalando apps"

bash apps.sh
