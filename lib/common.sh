#!/usr/bin/env bash

# Evita reprocessar caso já tenha sido carregado.
if [ -n "${LINUX_SETUP_COMMON_SOURCED:-}" ]; then
  return
fi
export LINUX_SETUP_COMMON_SOURCED=1

LINUX_SETUP_MIN_DISK_MB="${LINUX_SETUP_MIN_DISK_MB:-4096}"

ls_log_info() {
  echo -e "ℹ️  $*"
}

ls_log_warn() {
  echo -e "⚠️  $*" >&2
}

ls_log_error() {
  echo -e "❌ $*" >&2
}

ls_log_section() {
  echo -e "\n===== $* ====="
}

detect_distro() {
  if [ -n "${LS_PACKAGE_MANAGER:-}" ]; then
    return
  fi

  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    LS_OS_RELEASE_ID="${ID:-unknown}"
    LS_OS_RELEASE_LIKE="${ID_LIKE:-}"
    LS_OS_PRETTY_NAME="${PRETTY_NAME:-${NAME:-Linux}}"
  else
    LS_OS_RELEASE_ID="unknown"
    LS_OS_RELEASE_LIKE=""
    LS_OS_PRETTY_NAME="Linux"
  fi

  case "$LS_OS_RELEASE_ID" in
    ubuntu|debian|linuxmint|pop|zorin|elementary)
      LS_PACKAGE_MANAGER="apt"
      ;;
    fedora|rhel|rocky|almalinux|centos|oracle)
      LS_PACKAGE_MANAGER="dnf"
      ;;
    arch|manjaro|endeavouros|garuda)
      LS_PACKAGE_MANAGER="pacman"
      ;;
    *)
      if [[ "${LS_OS_RELEASE_LIKE,,}" == *debian* ]]; then
        LS_PACKAGE_MANAGER="apt"
      elif [[ "${LS_OS_RELEASE_LIKE,,}" == *rhel* ]] || [[ "${LS_OS_RELEASE_LIKE,,}" == *fedora* ]]; then
        LS_PACKAGE_MANAGER="dnf"
      elif [[ "${LS_OS_RELEASE_LIKE,,}" == *arch* ]]; then
        LS_PACKAGE_MANAGER="pacman"
      else
        LS_PACKAGE_MANAGER=""
      fi
      ;;
  esac
}

require_package_manager() {
  local expected="$1"
  if [ -z "${LS_PACKAGE_MANAGER:-}" ]; then
    ls_log_error "Não foi possível detectar o gerenciador de pacotes desta distro."
    exit 1
  fi

  if [ "$LS_PACKAGE_MANAGER" != "$expected" ]; then
    ls_log_error "Distro detectada (${LS_OS_PRETTY_NAME:-desconhecida}) usa '${LS_PACKAGE_MANAGER}', mas este setup só suporta '${expected}' no momento."
    exit 1
  fi
}

check_disk_space() {
  local mount_point="${1:-/}"
  local required_mb="${LINUX_SETUP_MIN_DISK_MB}"
  local available_kb
  available_kb=$(df --output=avail "$mount_point" 2>/dev/null | tail -n 1 | tr -d ' ')

  if [ -z "$available_kb" ]; then
    ls_log_warn "Não foi possível determinar o espaço livre em ${mount_point}."
    return
  fi

  local available_mb=$((available_kb / 1024))
  if [ "$available_mb" -lt "$required_mb" ]; then
    ls_log_error "Espaço insuficiente em ${mount_point}: ${available_mb}MB disponíveis; mínimo recomendado ${required_mb}MB."
    exit 1
  fi

  ls_log_info "💽 Espaço disponível suficiente em ${mount_point}: ${available_mb}MB."
}

check_network_connectivity() {
  if ping -c 1 -W 1 1.1.1.1 >/dev/null 2>&1; then
    ls_log_info "🌐 Conectividade de rede verificada via ICMP."
    return
  fi

  if command -v curl >/dev/null 2>&1; then
    if curl -Is https://deb.debian.org >/dev/null 2>&1; then
      ls_log_info "🌐 Conectividade de rede verificada via HTTP."
      return
    fi
  fi

  ls_log_error "Sem conectividade de rede (falha em ping e HTTP). Verifique sua conexão."
  exit 1
}

ensure_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    ls_log_error "Comando obrigatório '${cmd}' não encontrado. Instale-o manualmente e execute novamente."
    exit 1
  fi
}

run_preflight_checks() {
  ls_log_section "Pré-checks do sistema"
  detect_distro
  ls_log_info "🖥️  Sistema detectado: ${LS_OS_PRETTY_NAME:-desconhecido}"
  require_package_manager "apt"
  ensure_command "sudo"
  check_disk_space "/"
  check_network_connectivity
  ls_log_info "✅ Pré-checks concluídos."
}
