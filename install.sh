#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

echo "🚀 Iniciando configuração do sistema..."

# Garantir que está com sudo ativo
if [ "$EUID" -ne 0 ]; then
  echo "❌ Execute com: sudo ./install.sh"
  exit 1
fi

if [ -z "${SUDO_USER:-}" ] || [ "$SUDO_USER" = "root" ]; then
  echo "❌ Execute com sudo a partir de um usuário não-root (ex.: sudo ./install.sh)."
  exit 1
fi

TARGET_USER="$SUDO_USER"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [ -z "$TARGET_HOME" ]; then
  echo "❌ Não foi possível encontrar o diretório HOME de $TARGET_USER."
  exit 1
fi

run_preflight_checks

declare -a COMPLETED_STEPS=()

run_module() {
  local script_path="$1"
  local label="$2"
  ls_log_section "$label"
  bash "$SCRIPT_DIR/$script_path"
  COMPLETED_STEPS+=("$label")
  ls_log_info "✅ ${label} concluído."
}

generate_post_install_report() {
  local report_user="$1"
  local report_home="$2"
  shift 2
  local report_steps=("$@")
  local report_path="$report_home/POST_INSTALL.md"

  {
    echo "# Linux Setup - Pós-instalação"
    echo
    echo "- Data: $(date)"
    echo "- Usuário configurado: ${report_user}"
    echo "- Sistema detectado: ${LS_OS_PRETTY_NAME:-desconhecido}"
    echo
    echo "## Etapas concluídas"
    if [ "${#report_steps[@]}" -eq 0 ]; then
      echo "- Nenhuma etapa registrada."
    else
      for step in "${report_steps[@]}"; do
        echo "- ${step}"
      done
    fi
    echo
    echo "## Próximos passos recomendados"
    cat <<'EOF'
- Abra o Android Studio (`android-studio`) e aceite as licenças/SDKs necessários.
- Execute `mysql_secure_installation` para reforçar a segurança do MySQL (senha padrão: senha123 ou valor configurado em MYSQL_ROOT_PASSWORD).
- Faça login no Fish Shell e revise `~/.config/fish/config.fish` para ajustes pessoais.
- Atualize aplicativos Flatpak periodicamente com `flatpak update`.
- Revise o arquivo `POST_INSTALL.md` sempre que fizer alterações futuras neste setup.
- Reboot do sistema para aplicar o novo shell padrão (caso ainda não tenha reiniciado).
EOF
  } > "$report_path"

  chown "$report_user":"$report_user" "$report_path" 2>/dev/null || true
  ls_log_info "📄 Relatório pós-instalação salvo em ${report_path}"
}

STEPS=(
  "base.sh|Base do sistema"
  "dev.sh|Ferramentas de desenvolvimento"
  "fish.sh|Shell e terminal"
  "neovim.sh|Neovim"
  "apps.sh|Aplicativos via APT"
  "flatpakApps.sh|Aplicativos via Flatpak"
  "mysql.sh|Bancos de dados"
  "finalize.sh|Limpeza final"
)

for entry in "${STEPS[@]}"; do
  IFS="|" read -r script label <<<"$entry"
  if [ "$script" = "finalize.sh" ]; then
    export LINUX_SETUP_SKIP_REBOOT=1
  fi
  run_module "$script" "$label"
done

unset LINUX_SETUP_SKIP_REBOOT || true

generate_post_install_report "$TARGET_USER" "$TARGET_HOME" "${COMPLETED_STEPS[@]}"

if [ "${LINUX_SETUP_AUTO_REBOOT:-1}" = "1" ]; then
  ls_log_info "🔁 Sistema será reiniciado em 10 segundos..."
  sleep 10
  reboot
else
  ls_log_warn "Reboot automático desativado. Execute 'sudo reboot' quando estiver pronto."
fi
