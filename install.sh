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

MODULES=(
  "1|base.sh|Base do sistema"
  "2|dev.sh|Ferramentas de desenvolvimento"
  "3|fish.sh|Shell e terminal"
  "4|neovim.sh|Neovim"
  "5|apps.sh|Aplicativos via APT"
  "6|flatpakApps.sh|Aplicativos via Flatpak"
  "7|mysql.sh|Bancos de dados"
  "8|finalize.sh|Limpeza final"
)

declare -A MODULE_ID_TO_SCRIPT=()
declare -A MODULE_ID_TO_LABEL=()
declare -a MODULE_IDS=()
for entry in "${MODULES[@]}"; do
  IFS="|" read -r module_id module_script module_label <<<"$entry"
  MODULE_ID_TO_SCRIPT["$module_id"]="$module_script"
  MODULE_ID_TO_LABEL["$module_id"]="$module_label"
  MODULE_IDS+=("$module_id")
done

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

show_menu() {
  ls_log_section "Selecione os módulos para instalar"
  for entry in "${MODULES[@]}"; do
    IFS="|" read -r module_id _module_script module_label <<<"$entry"
    echo "  ${module_id}) ${module_label}"
  done
  echo "  all) Instalar todos os módulos na ordem acima (padrão)"
  echo
}

prompt_module_selection() {
  local selection
  local normalized
  declare -ga SELECTED_IDS=()
  while true; do
    show_menu
    read -r -p "Digite os módulos desejados (ex.: 1 3 5 ou all): " selection || true
    selection="${selection,,}"
    selection="${selection//,/ }"
    selection="${selection//[^a-z0-9[:space:]]/ }"
    # Remove espaços duplicados
    normalized="$(echo "$selection" | tr -s '[:space:]' ' ' | sed 's/^ *//;s/ *$//')"
    if [ -z "$normalized" ] || [ "$normalized" = "all" ]; then
      SELECTED_IDS=("${MODULE_IDS[@]}")
      break
    fi
    read -ra tokens <<<"$normalized"
    if [ "${#tokens[@]}" -eq 0 ]; then
      ls_log_warn "Entrada vazia. Tente novamente."
      continue
    fi
    local all_valid=1
    local tmp_ids=()
    for token in "${tokens[@]}"; do
      if [[ ! "$token" =~ ^[0-9]+$ ]]; then
        ls_log_warn "Entrada inválida: '${token}'. Use números ou 'all'."
        all_valid=0
        break
      fi
      if [ -z "${MODULE_ID_TO_SCRIPT[$token]:-}" ]; then
        ls_log_warn "Módulo '${token}' não existe. Escolha um dos números listados."
        all_valid=0
        break
      fi
      tmp_ids+=("$token")
    done
    if [ "$all_valid" -eq 1 ]; then
      SELECTED_IDS=("${tmp_ids[@]}")
      break
    fi
  done
}

prompt_module_selection

declare -A SELECTED_MAP=()
for module_id in "${SELECTED_IDS[@]}"; do
  SELECTED_MAP["$module_id"]=1
done

FINALIZE_SELECTED=0

for entry in "${MODULES[@]}"; do
  IFS="|" read -r module_id script label <<<"$entry"
  if [ -z "${SELECTED_MAP[$module_id]:-}" ]; then
    continue
  fi
  if [ "$script" = "finalize.sh" ]; then
    FINALIZE_SELECTED=1
    export LINUX_SETUP_SKIP_REBOOT=1
  fi
  run_module "$script" "$label"
done

if [ "$FINALIZE_SELECTED" -eq 1 ]; then
  unset LINUX_SETUP_SKIP_REBOOT || true
fi

generate_post_install_report "$TARGET_USER" "$TARGET_HOME" "${COMPLETED_STEPS[@]}"

if [ "$FINALIZE_SELECTED" -eq 1 ]; then
  if [ "${LINUX_SETUP_AUTO_REBOOT:-1}" = "1" ]; then
    ls_log_info "🔁 Sistema será reiniciado em 10 segundos..."
    sleep 10
    reboot
  else
    ls_log_warn "Reboot automático desativado. Execute 'sudo reboot' quando estiver pronto."
  fi
else
  ls_log_warn "O módulo de limpeza final não foi executado. Considere rodar 'bash finalize.sh' e reiniciar manualmente."
fi
