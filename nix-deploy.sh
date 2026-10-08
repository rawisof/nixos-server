#!/usr/bin/env bash

set -euo pipefail

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# === ОБЪЯВЛЕНИЕ ПЕРЕМЕННЫХ (Исправлено: добавлены пути) ===
HARDWARE_CONF="hardware-configuration.nix" # или ваш кастомный путь, например ./hardware-configuration.nix
SECRETS_DIR="/etc/nixos/secrets"
GRAFANA_SECRET="$SECRETS_DIR/grafana_secret"
SSH_KEY="$SECRETS_DIR/ssh_host_ed25519_key"

echo -e "${BLUE}==> Starting... ${NC}"

# Проверка прав суперпользователя (Исправлено: опечатка в permission denied и {$RED})
if [ "$EUID" -ne 0 ]; then
	echo -e "${RED}Error: permission denied. Run as root/sudo.${NC}"
	exit 1
fi

# Генерация hardware-configuration.nix (Исправлено: добавлен $ перед HARDWARE_CONF в cp)
if [ ! -f "$HARDWARE_CONF" ]; then
	echo -e "${BLUE}==> Generate hardware-configuration.nix...${NC}"
	nixos-generate-config --dir /tmp/nixos-gen
	cp /tmp/nixos-gen/hardware-configuration.nix "$HARDWARE_CONF"
	rm -rf /tmp/nixos-gen
	echo -e "${GREEN}[ OK ] hardware-configuration.nix created.${NC}"
else
	echo -e "${GREEN}[ OK ] hardware-configuration.nix exists.${NC}"
fi

# Создание директории секретов
echo -e "${BLUE}==> Setting up secrets directory (${SECRETS_DIR})...${NC}"
mkdir -p "$SECRETS_DIR"
chmod 0700 "$SECRETS_DIR"

# Генерация SSH ключей хоста
if [ ! -f "$SSH_KEY" ]; then
	echo -e "${BLUE}==> Generating SSH host keys...${NC}"
	ssh-keygen -t ed25519 -N "" -f "$SSH_KEY"
	chmod 0600 "$SSH_KEY"
	echo -e "${GREEN}[ OK ] SSH key generated.${NC}"
else
	echo -e "${GREEN}[ OK ] SSH key exists.${NC}"
fi

# Генерация ключа Grafana (Исправлено: права доступа и группа, чтобы Grafana могла его прочесть)
if [ ! -f "$GRAFANA_SECRET" ]; then
	echo -e "${BLUE}==> Generating Grafana key...${NC}"
	tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24 > "$GRAFANA_SECRET"
	echo "" >> "$GRAFANA_SECRET"
	
	# Сначала создаем группу grafana, если её еще нет в системе, чтобы chown не падал
	getent group grafana >/dev/null || groupadd -r grafana || true
	
	# Выставляем правильные права
	chown root:grafana "$GRAFANA_SECRET" 2>/dev/null || true
	chmod 0640 "$GRAFANA_SECRET"
	echo -e "${GREEN}[ OK ] Grafana key generated.${NC}"
else
	echo -e "${GREEN}[ OK ] Grafana key exists.${NC}"
fi

# Добавление в индекс Git для Flakes
if [ -d ".git" ]; then
	echo -e "${BLUE}==> Updating git index for flakes...${NC}"
	git add -N "$HARDWARE_CONF" 2>/dev/null || true
fi

echo -e "${GREEN}==============================${NC}"
echo -e "${GREEN}[ OK ] deploy end.${NC}"
echo -e "${GREEN}==============================${NC}"

echo -e "${GREEN}==============================${NC}"
echo -e "${GREEN} And 'cp /etc/nixos/develop/flake.nix' you project path${NC}"
echo -e "${GREEN}==============================${NC}"
