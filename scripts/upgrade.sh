#!/bin/bash

# ===============================================
# 🔄 REMNAWAVE BEDOLAGA BOT - ОБНОВЛЕНИЕ
# ===============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Автоопределение директории установки
if [ -d "/opt/remnawave-bedolaga-telegram-bot" ]; then
    INSTALL_DIR="/opt/remnawave-bedolaga-telegram-bot"
elif [ -d "/root/remnawave-bedolaga-telegram-bot" ]; then
    INSTALL_DIR="/root/remnawave-bedolaga-telegram-bot"
else
    # Если запущен из директории бота
    if [ -f "./docker-compose.yml" ] && [ -f "./main.py" ]; then
        INSTALL_DIR="$(pwd)"
    else
        echo -e "${RED}❌ Директория бота не найдена!${NC}"
        echo -e "${YELLOW}Проверьте /opt/remnawave-bedolaga-telegram-bot или /root/remnawave-bedolaga-telegram-bot${NC}"
        exit 1
    fi
fi

echo -e "${PURPLE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     🔄 REMNAWAVE BEDOLAGA BOT - ОБНОВЛЕНИЕ 🔄               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}📁 Директория: $INSTALL_DIR${NC}"

cd "$INSTALL_DIR"

# Создание бэкапа
echo -e "${CYAN}📦 Создание бэкапа перед обновлением...${NC}"
BACKUP_DIR="./backups"
BACKUP_NAME="pre_update_$(date +%Y%m%d_%H%M%S).tar.gz"
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/$BACKUP_NAME" .env data/ 2>/dev/null || true
echo -e "${GREEN}✅ Бэкап создан: $BACKUP_DIR/$BACKUP_NAME${NC}"

# Получение текущей и последней версии
CURRENT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
echo -e "${CYAN}📍 Текущая версия: $CURRENT_COMMIT${NC}"

# Выбор метода обновления
echo
echo -e "${WHITE}Выберите метод обновления:${NC}"
echo -e "  1) Обновить до последнего коммита (main branch)"
echo -e "  2) Обновить до конкретного релиза (тег)"
echo -e "  3) Отмена"
echo
read -p "Ваш выбор (1-3): " UPDATE_CHOICE

case $UPDATE_CHOICE in
    1)
        echo -e "${CYAN}🔄 Обновление до последнего коммита...${NC}"
        git fetch origin main
        git reset --hard origin/main
        ;;
    2)
        echo -e "${CYAN}📋 Доступные релизы:${NC}"
        git fetch --tags
        git tag -l --sort=-v:refname | head -10
        echo
        read -p "Введите версию (например, v2.9.1): " TAG_VERSION
        if [ -z "$TAG_VERSION" ]; then
            echo -e "${RED}❌ Версия не указана${NC}"
            exit 1
        fi
        echo -e "${CYAN}🔄 Переключение на версию $TAG_VERSION...${NC}"
        git checkout "$TAG_VERSION"
        ;;
    3)
        echo -e "${YELLOW}Обновление отменено${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Неверный выбор${NC}"
        exit 1
        ;;
esac

NEW_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
echo -e "${GREEN}✅ Код обновлен до: $NEW_COMMIT${NC}"

# Пересборка контейнеров
echo -e "${CYAN}🐳 Пересборка Docker контейнеров...${NC}"

# Определяем compose файл
COMPOSE_FILE="docker-compose.yml"
[ -f ".install_config" ] && source .install_config
[ -f "docker-compose.local.yml" ] && COMPOSE_FILE="docker-compose.local.yml"

docker compose -f "$COMPOSE_FILE" down
docker compose -f "$COMPOSE_FILE" build --no-cache
docker compose -f "$COMPOSE_FILE" up -d

# Ожидание запуска
echo -e "${CYAN}⏳ Ожидание запуска контейнеров...${NC}"
sleep 10

# Проверка статуса
echo -e "${CYAN}📊 Статус контейнеров:${NC}"
docker compose -f "$COMPOSE_FILE" ps

echo
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ ОБНОВЛЕНИЕ ЗАВЕРШЕНО УСПЕШНО!                         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${CYAN}📋 Изменения: $CURRENT_COMMIT -> $NEW_COMMIT${NC}"
echo -e "${CYAN}📦 Бэкап: $BACKUP_DIR/$BACKUP_NAME${NC}"
echo
echo -e "${YELLOW}💡 Для просмотра логов: ./logs.sh${NC}"
