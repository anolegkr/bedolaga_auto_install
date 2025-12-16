#!/bin/bash

# ===============================================
# 🚀 REMNAWAVE BEDOLAGA BOT - БЫСТРАЯ УСТАНОВКА
# ===============================================
# Одна команда для запуска полной установки
# ===============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     🤖 REMNAWAVE BEDOLAGA BOT - БЫСТРАЯ УСТАНОВКА 🤖        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Проверка root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Скрипт должен быть запущен от имени root!${NC}"
    echo -e "${YELLOW}Используйте: sudo bash quick-install.sh${NC}"
    exit 1
fi

# Установка необходимых пакетов
echo -e "${GREEN}📦 Установка базовых пакетов...${NC}"
apt-get update -y
apt-get install -y curl wget git

# Скачивание и запуск основного скрипта
echo -e "${GREEN}📥 Загрузка установщика...${NC}"

INSTALL_SCRIPT="/tmp/bedolaga-install.sh"

curl -fsSL https://raw.githubusercontent.com/wrx861/bedolaga_auto_install/main/scripts/install.sh -o "$INSTALL_SCRIPT" || {
    echo -e "${YELLOW}⚠️ Не удалось загрузить с GitHub, используем локальную версию...${NC}"
    
    # Если не удалось загрузить, клонируем репо со скриптами
    TEMP_DIR="/tmp/bedolaga-temp"
    rm -rf "$TEMP_DIR"
    git clone https://github.com/wrx861/bedolaga_auto_install.git "$TEMP_DIR"
    cp "$TEMP_DIR/scripts/install.sh" "$INSTALL_SCRIPT"
    rm -rf "$TEMP_DIR"
}

chmod +x "$INSTALL_SCRIPT"

echo -e "${GREEN}🚀 Запуск установщика...${NC}"
bash "$INSTALL_SCRIPT"

# Очистка
rm -f "$INSTALL_SCRIPT"
