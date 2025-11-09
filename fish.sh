#!/usr/bin/env bash
set -e
echo "🐠 Instalando e configurando Fish Shell..."

sudo apt install -y fish
chsh -s $(which fish) "$SUDO_USER"

# Instala o gerenciador de plugins Fisher
su - "$SUDO_USER" -c "fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'"

# Instala plugins úteis via Fisher
su - "$SUDO_USER" -c "fish -c 'fisher install jorgebucaran/nvm.fish PatrickF1/fzf.fish jethrokuan/z exa junegunn/fzf'"

# Cria configuração inicial personalizada
FISH_CONFIG="/home/$SUDO_USER/.config/fish/config.fish"
mkdir -p "$(dirname "$FISH_CONFIG")"

cat <<'EOF' > "$FISH_CONFIG"

# ======================
# 🐟 Fish Config
# ======================


set -g fish_greeting ""
# ==========================
# 🐠 Fish Shell Config - vitor
# ==========================

# ---- Tema / Prompt bonito ----
if type -q starship
    starship init fish | source
end

# ---- Zoxide (atalho de diretórios) ----
if type -q zoxide
    zoxide init fish | source
    alias cd='z'
end

# ---- Path e variáveis de ambiente ----
set -gx NVM_DIR $HOME/.nvm
set -gx BUN_INSTALL $HOME/.bun
set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64
set -gx ANDROID_SDK_ROOT $HOME/Android/Sdk
set -gx ANDROID_HOME $ANDROID_SDK_ROOT
set -gx FLUTTER_HOME $HOME/dev/flutter
set -gx ZED_ALLOW_EMULATED_GPU 1
set -gx PHP_INI_SCAN_DIR "$HOME/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"

# PATHs combinados
set -gx PATH $HOME/bin $BUN_INSTALL/bin /usr/local/go/bin $JAVA_HOME/bin \
    $ANDROID_SDK_ROOT/cmdline-tools/latest/bin $ANDROID_SDK_ROOT/platform-tools \
    $ANDROID_SDK_ROOT/emulator $FLUTTER_HOME/bin \
    $HOME/.dotnet $HOME/.dotnet/tools $HOME/.config/herd-lite/bin $PATH

# ---- Lazy load NVM e Bun (carrega só quando usados) ----
function __lazy_nvm
    if test -s "$NVM_DIR/nvm.sh"
        bass source "$NVM_DIR/nvm.sh" --no-use ';' nvm use default
    end
end
function node; __lazy_nvm; command node $argv; end
function npm; __lazy_nvm; command npm $argv; end
function npx; __lazy_nvm; command npx $argv; end

function __lazy_bun
    if test -s "$HOME/.bun/_bun"
        bass source "$HOME/.bun/_bun"
    end
end
function bun; __lazy_bun; command bun $argv; end

# ---- Ativação automática de venv Python ----
function auto_venv_activate --on-variable PWD
    if set -q VIRTUAL_ENV
        deactivate 2>/dev/null
    end
    if test -d ./venv
        source ./venv/bin/activate.fish
        echo "🐍 Virtualenv ativada: (venv)"
    else if test -d ./.venv
        source ./.venv/bin/activate.fish
        echo "🐍 Virtualenv ativada: (.venv)"
    end
end

# ---- Aliases ----
alias ll='ls -lah'
alias l='ls -l'
alias rm='rm -rf'
alias mysql='mysql -u root -p'
alias up='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y && sudo apt autopurge -y'
alias fish='nvim ~/.config/fish/config.fish'
alias rl='source ~/.config/fish/config.fish'
alias gs='git status'
alias gm='git commit -m'
alias mobile="$ANDROID_SDK_ROOT/emulator/emulator -avd Medium_Phone_API_36.1"
alias flatr='flatpak uninstall'
alias aptr='sudo apt remove'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias init='systemd-analyze blame'
alias fullinit='systemctl list-unit-files --type=service --state=enabled'
alias info='neofetch'
alias vitu='google-chrome https://github.com/vitordsb https://www.linkedin.com/in/vitor-de-souza-15067a1bb/ https://meu-1portifolio.vercel.app'
alias bateria='sudo tlp-stat -b'
alias deploy='git add . && git commit -m "Deploy automático" && git push origin master'
alias lvs='live-server'
alias py='python3'
alias vi='nvim'
alias nr='npm run dev'
alias mknext='npx create-next-app@latest ./'
alias cls='sudo apt autoremove -y && sudo apt autoclean -y'
alias pacotes='cd /etc/apt/sources.list.d'
alias myip='curl ipinfo.io'

alias pyinit='python3 -m venv venv'

alias ia='ollama run gemma3:1b'
alias dbegp='mongosh "mongodb+srv://cluster0.tn4hbrg.mongodb.net/" --apiVersion 1 --username vitordsb2019_db_user'

# ---- Visualizar PDF como imagem no terminal (Kitty + Ueberzug) ----
function pdfview
    mkdir -p /tmp/pdf_previews
    pdftoppm -jpeg $argv[1] /tmp/pdf_previews/page
    ueberzugpp layer --parser simple --silent --max-frames 1 --command \
        "add [identifier] [path:/tmp/pdf_previews/page-1.jpg] [x:0] [y:0] [width:80%] [height:90%]"
end

EOF

echo "✅ Fish configurado com sucesso! vamos tornar ele o padrão"

chsh -s $(which fish)

echo "📝 Instalando e configurando Neovim..."

bash neovim.sh
