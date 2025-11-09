#!/usr/bin/env bash
set -e  # para se o script falhar
set -u  # erro se variável não definida

if [ "$EUID" -ne 0 ]; then
    echo "❌ Execute este script como root (via sudo)."
    exit 1
fi

echo "📦 Instalando ferramentas de desenvolvimento banco de dados..."
apt install -y mysql-client mysql-server postgresql-client postgresql

MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-senha123}"

echo "🔐 Configurando senha do usuário root do MySQL..."
mysql --protocol=socket <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
SQL

echo "✅ Banco de dados configurado!"
