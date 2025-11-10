#!/usr/bin/env bash
set -e  # para se o script falhar
set -u  # erro se variável não definida

if [ "$EUID" -ne 0 ]; then
    echo "❌ Execute este script como root (via sudo)."
    exit 1
fi

TARGET_USER="${SUDO_USER:-}"
if [ -z "$TARGET_USER" ] || [ "$TARGET_USER" = "root" ]; then
    echo "❌ Defina um usuário não-root ao executar (ex.: sudo ./install.sh)."
    exit 1
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [ -z "$TARGET_HOME" ]; then
    echo "❌ Não foi possível descobrir o diretório home de $TARGET_USER."
    exit 1
fi

FISH_CONFIG="$TARGET_HOME/.config/fish/config.fish"
FISH_MIN_VERSION="3.4.0"

ensure_fish_release_repo() {
    if [ ! -r /etc/os-release ]; then
        return
    fi
    # shellcheck disable=SC1091
    . /etc/os-release
    local tags
    tags="$(printf '%s %s' "${ID:-}" "${ID_LIKE:-}" | tr '[:upper:]' '[:lower:]')"
    case "$tags" in
        *ubuntu*|*pop*|*linuxmint*|*elementary*)
            if grep -Rqs "fish-shell/release-3" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
                return
            fi
            if ! command -v add-apt-repository >/dev/null 2>&1; then
                apt install -y software-properties-common
            fi
            echo "➕ Adicionando PPA oficial do Fish Shell..."
            add-apt-repository -y ppa:fish-shell/release-3
            apt update
            ;;
        *)
            ;;
    esac
}

warn_if_old_fish() {
    if ! command -v fish >/dev/null 2>&1; then
        return
    fi
    local installed_version
    installed_version="$(fish --version | awk '{print $3}')"
    if ! dpkg --compare-versions "$installed_version" ge "$FISH_MIN_VERSION"; then
        echo "⚠️  A versão do Fish (${installed_version}) é antiga e pode quebrar plugins (mínimo recomendado: ${FISH_MIN_VERSION})."
        echo "⚠️  Considere atualizar manualmente adicionando o PPA oficial do Fish."
    fi
}

echo "🐠 Instalando e configurando Fish Shell..."

ensure_fish_release_repo
apt install -y fish fzf
warn_if_old_fish
chsh -s "$(command -v fish)" "$TARGET_USER"

# Instala o gerenciador de plugins Fisher
su - "$TARGET_USER" -c "fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'"

# Instala plugins úteis via Fisher
su - "$TARGET_USER" -c "fish -c 'fisher install jorgebucaran/nvm.fish PatrickF1/fzf.fish jethrokuan/z exa junegunn/fzf'"

# Cria configuração inicial personalizada
mkdir -p "$(dirname "$FISH_CONFIG")"

cat <<'EOF' > "$FISH_CONFIG"

# ==========================
# 🐠 Fish Shell Config - vitor (atualizado)
# ==========================

set -g fish_greeting ""

# ---- Tema / Prompt bonito ----
if type -q starship
    starship init fish | source
end

# ---- Zoxide (atalho de diretórios) ----
if type -q zoxide
    zoxide init fish | source
    alias cd='z'
end

# ---- Variáveis globais ----
set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64
set -gx ANDROID_SDK_ROOT $HOME/Android/Sdk
set -gx ANDROID_HOME $ANDROID_SDK_ROOT
set -gx FLUTTER_HOME $HOME/dev/flutter
set -gx ZED_ALLOW_EMULATED_GPU 1
set -gx PHP_INI_SCAN_DIR "$HOME/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"

# ==========================
# Node, NVM, PNPM, NPM, Bun, Cargo
# ==========================

# ---- NVM ----
set -gx NVM_DIR $HOME/.nvm
set -gx N_PREFIX $HOME/.local/share/n
set -gx NODE_PATH /usr/lib/node_modules

# Carrega o nvm.fish (instalador automático)
if not functions -q nvm
    if not type -q fisher
        echo "⚙️  Instalando Fisher..."
        curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    end
    fisher install jorgebucaran/nvm.fish
end

# Usa o Node padrão automaticamente
if type -q nvm
    nvm use default >/dev/null 2>&1
end

# ---- NPM e PNPM ----
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
set -gx NPM_CONFIG_PREFIX "$HOME/.npm-global"
mkdir -p $PNPM_HOME $NPM_CONFIG_PREFIX/bin

# ---- Bun ----
set -gx BUN_INSTALL "$HOME/.bun"
if test -d $BUN_INSTALL
    set -gx PATH $BUN_INSTALL/bin $PATH
end

# ---- Cargo (Rust) ----
set -gx CARGO_HOME "$HOME/.cargo"
set -gx RUSTUP_HOME "$HOME/.rustup"
if test -d $CARGO_HOME
    set -gx PATH $CARGO_HOME/bin $PATH
end

# ---- PATH combinado e ordenado ----
set -gx PATH \
    $HOME/bin \
    $NVM_DIR/versions/node/*/bin \
    $BUN_INSTALL/bin \
    $PNPM_HOME \
    $NPM_CONFIG_PREFIX/bin \
    $CARGO_HOME/bin \
    /usr/local/bin \
    /usr/local/go/bin \
    $JAVA_HOME/bin \
    $ANDROID_SDK_ROOT/cmdline-tools/latest/bin \
    $ANDROID_SDK_ROOT/platform-tools \
    $ANDROID_SDK_ROOT/emulator \
    $FLUTTER_HOME/bin \
    $HOME/.dotnet \
    $HOME/.dotnet/tools \
    $HOME/.config/herd-lite/bin \
    $PATH

# ==========================
# Python (auto venv)
# ==========================

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

# ==========================
# Aliases
# ==========================

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

# ==========================
# Visualizar PDF como imagem no terminal
# ==========================
function pdfview
    mkdir -p /tmp/pdf_previews
    pdftoppm -jpeg $argv[1] /tmp/pdf_previews/page
    ueberzugpp layer --parser simple --silent --max-frames 1 --command \
        "add [identifier] [path:/tmp/pdf_previews/page-1.jpg] [x:0] [y:0] [width:80%] [height:90%]"
end

EOF

chown -R "$TARGET_USER":"$TARGET_USER" "$(dirname "$FISH_CONFIG")"

echo "✅ Fish configurado com sucesso! vamos tornar ele o padrão"

echo "✅ Fish shell configurado!"
