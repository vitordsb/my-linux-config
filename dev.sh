#!/usr/bin/env bash
set -e

echo "💻 Instalando ferramentas de desenvolvimento..."
apt install -y python3 python3-pip nodejs npm docker.io docker-compose openjdk-25-jdk openjdk-25-jre

echo "📦 Instalando ferramentas de desenvolvimento Java..."
apt install -y maven gradle

echo "📦 Instalando ferramentas de desenvolvimento banco de dados..."
apt install -y mysql-client mysql-server postgresql-client postgresql

echo "📦 Instalando ferramentas de desenvolvimento PHP..."
apt install -y php php-cli php-common php-curl php-fpm php-gd php-mbstring php-mysql php-xml php-xmlrpc php-zip

# Configura permissões do Docker
usermod -aG docker $SUDO_USER
