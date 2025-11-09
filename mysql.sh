#!/usr/bin/env bash
set -e  # para se o script falhar
set -u  # erro se variável não definida

echo "📦 Instalando ferramentas de desenvolvimento banco de dados..."
apt install -y mysql-client mysql-server postgresql-client postgresql


echo "iniciando o mysql e colocando senha: senha123"

mysql -u root -p

ALTER USER 'root'@'localhost' IDENTIFIED BY 'senha123';
FLUSH PRIVILEGES;

echo "✅ Banco de dados configurado!"

bash finalize.sh
