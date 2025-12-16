#!/bin/bash

# ===============================================
# ⚙️ REMNAWAVE BEDOLAGA BOT - КОНФИГУРАТОР
# ===============================================
# Интерактивная настройка существующей установки
# ===============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

# Автоопределение директории установки
if [ -d "/opt/remnawave-bedolaga-telegram-bot" ]; then
    INSTALL_DIR="/opt/remnawave-bedolaga-telegram-bot"
elif [ -d "/root/remnawave-bedolaga-telegram-bot" ]; then
    INSTALL_DIR="/root/remnawave-bedolaga-telegram-bot"
else
    if [ -f "./docker-compose.yml" ] && [ -f "./.env" ]; then
        INSTALL_DIR="$(pwd)"
    else
        echo -e "${RED}❌ Бот не установлен!${NC}"
        echo -e "${YELLOW}Сначала выполните установку.${NC}"
        exit 1
    fi
fi

ENV_FILE="$INSTALL_DIR/.env"

print_menu() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║     ⚙️ REMNAWAVE BEDOLAGA BOT - КОНФИГУРАТОР ⚙️              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${WHITE}Выберите действие:${NC}"
    echo
    echo -e "  ${CYAN}1)${NC} Изменить BOT_TOKEN"
    echo -e "  ${CYAN}2)${NC} Изменить ADMIN_IDS"
    echo -e "  ${CYAN}3)${NC} Изменить настройки Remnawave API"
    echo -e "  ${CYAN}4)${NC} Настроить платежные системы"
    echo -e "  ${CYAN}5)${NC} Настроить уведомления"
    echo -e "  ${CYAN}6)${NC} Настроить webhook"
    echo -e "  ${CYAN}7)${NC} Показать текущую конфигурацию"
    echo -e "  ${CYAN}8)${NC} Перезапустить бота"
    echo -e "  ${CYAN}0)${NC} Выход"
    echo
}

get_env_value() {
    local key=$1
    grep "^$key=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2- | tr -d '"' | tr -d "'"
}

set_env_value() {
    local key=$1
    local value=$2
    
    if grep -q "^$key=" "$ENV_FILE" 2>/dev/null; then
        sed -i "s|^$key=.*|$key=$value|" "$ENV_FILE"
    else
        echo "$key=$value" >> "$ENV_FILE"
    fi
}

edit_bot_token() {
    echo -e "${CYAN}Текущий BOT_TOKEN:${NC} $(get_env_value BOT_TOKEN | head -c 20)..."
    echo
    read -p "Новый BOT_TOKEN (Enter для отмены): " NEW_VALUE
    if [ -n "$NEW_VALUE" ]; then
        set_env_value "BOT_TOKEN" "$NEW_VALUE"
        echo -e "${GREEN}✅ BOT_TOKEN обновлен${NC}"
    fi
}

edit_admin_ids() {
    echo -e "${CYAN}Текущие ADMIN_IDS:${NC} $(get_env_value ADMIN_IDS)"
    echo -e "${YELLOW}Формат: ID через запятую (123456789,987654321)${NC}"
    echo
    read -p "Новые ADMIN_IDS (Enter для отмены): " NEW_VALUE
    if [ -n "$NEW_VALUE" ]; then
        set_env_value "ADMIN_IDS" "$NEW_VALUE"
        echo -e "${GREEN}✅ ADMIN_IDS обновлены${NC}"
    fi
}

edit_remnawave() {
    echo -e "${CYAN}Текущие настройки Remnawave:${NC}"
    echo -e "  API_URL: $(get_env_value REMNAWAVE_API_URL)"
    echo -e "  API_KEY: $(get_env_value REMNAWAVE_API_KEY | head -c 20)..."
    echo
    
    read -p "Новый REMNAWAVE_API_URL (Enter для пропуска): " NEW_URL
    if [ -n "$NEW_URL" ]; then
        set_env_value "REMNAWAVE_API_URL" "$NEW_URL"
        echo -e "${GREEN}✅ REMNAWAVE_API_URL обновлен${NC}"
    fi
    
    read -p "Новый REMNAWAVE_API_KEY (Enter для пропуска): " NEW_KEY
    if [ -n "$NEW_KEY" ]; then
        set_env_value "REMNAWAVE_API_KEY" "$NEW_KEY"
        echo -e "${GREEN}✅ REMNAWAVE_API_KEY обновлен${NC}"
    fi
}

edit_payments() {
    echo -e "${CYAN}Настройка платежных систем:${NC}"
    echo
    echo -e "  1) Telegram Stars"
    echo -e "  2) YooKassa"
    echo -e "  3) CryptoBot"
    echo -e "  4) PayPalych"
    echo -e "  0) Назад"
    echo
    read -p "Выберите систему: " PAYMENT_CHOICE
    
    case $PAYMENT_CHOICE in
        1)
            echo -e "${CYAN}Telegram Stars:${NC}"
            CURRENT=$(get_env_value TELEGRAM_STARS_ENABLED)
            echo -e "  Текущий статус: $CURRENT"
            read -p "  Включить? (true/false): " NEW_VALUE
            if [ -n "$NEW_VALUE" ]; then
                set_env_value "TELEGRAM_STARS_ENABLED" "$NEW_VALUE"
                echo -e "${GREEN}✅ Обновлено${NC}"
            fi
            ;;
        2)
            echo -e "${CYAN}YooKassa:${NC}"
            read -p "  YOOKASSA_ENABLED (true/false): " ENABLED
            read -p "  YOOKASSA_SHOP_ID: " SHOP_ID
            read -p "  YOOKASSA_SECRET_KEY: " SECRET_KEY
            
            [ -n "$ENABLED" ] && set_env_value "YOOKASSA_ENABLED" "$ENABLED"
            [ -n "$SHOP_ID" ] && set_env_value "YOOKASSA_SHOP_ID" "$SHOP_ID"
            [ -n "$SECRET_KEY" ] && set_env_value "YOOKASSA_SECRET_KEY" "$SECRET_KEY"
            echo -e "${GREEN}✅ YooKassa настроена${NC}"
            ;;
        3)
            echo -e "${CYAN}CryptoBot:${NC}"
            read -p "  CRYPTOBOT_ENABLED (true/false): " ENABLED
            read -p "  CRYPTOBOT_API_TOKEN: " TOKEN
            
            [ -n "$ENABLED" ] && set_env_value "CRYPTOBOT_ENABLED" "$ENABLED"
            [ -n "$TOKEN" ] && set_env_value "CRYPTOBOT_API_TOKEN" "$TOKEN"
            echo -e "${GREEN}✅ CryptoBot настроен${NC}"
            ;;
        4)
            echo -e "${CYAN}PayPalych:${NC}"
            read -p "  PAL24_ENABLED (true/false): " ENABLED
            read -p "  PAL24_API_TOKEN: " TOKEN
            read -p "  PAL24_SHOP_ID: " SHOP_ID
            
            [ -n "$ENABLED" ] && set_env_value "PAL24_ENABLED" "$ENABLED"
            [ -n "$TOKEN" ] && set_env_value "PAL24_API_TOKEN" "$TOKEN"
            [ -n "$SHOP_ID" ] && set_env_value "PAL24_SHOP_ID" "$SHOP_ID"
            echo -e "${GREEN}✅ PayPalych настроен${NC}"
            ;;
    esac
}

edit_notifications() {
    echo -e "${CYAN}Настройка уведомлений:${NC}"
    echo -e "  Текущий Chat ID: $(get_env_value ADMIN_NOTIFICATIONS_CHAT_ID)"
    echo -e "  Статус: $(get_env_value ADMIN_NOTIFICATIONS_ENABLED)"
    echo
    
    read -p "ADMIN_NOTIFICATIONS_ENABLED (true/false): " ENABLED
    read -p "ADMIN_NOTIFICATIONS_CHAT_ID: " CHAT_ID
    read -p "ADMIN_NOTIFICATIONS_TOPIC_ID (опционально): " TOPIC_ID
    
    [ -n "$ENABLED" ] && set_env_value "ADMIN_NOTIFICATIONS_ENABLED" "$ENABLED"
    [ -n "$CHAT_ID" ] && set_env_value "ADMIN_NOTIFICATIONS_CHAT_ID" "$CHAT_ID"
    [ -n "$TOPIC_ID" ] && set_env_value "ADMIN_NOTIFICATIONS_TOPIC_ID" "$TOPIC_ID"
    
    echo -e "${GREEN}✅ Уведомления настроены${NC}"
}

edit_webhook() {
    echo -e "${CYAN}Настройка Webhook:${NC}"
    echo -e "  Текущий режим: $(get_env_value BOT_RUN_MODE)"
    echo -e "  Webhook URL: $(get_env_value WEBHOOK_URL)"
    echo
    
    echo -e "${WHITE}Режимы работы:${NC}"
    echo -e "  polling - бот сам опрашивает Telegram"
    echo -e "  webhook - Telegram отправляет обновления на ваш сервер"
    echo -e "  both - оба режима одновременно"
    echo
    
    read -p "BOT_RUN_MODE (polling/webhook/both): " MODE
    if [ "$MODE" == "webhook" ] || [ "$MODE" == "both" ]; then
        read -p "WEBHOOK_URL (https://yourdomain.com): " URL
        [ -n "$URL" ] && set_env_value "WEBHOOK_URL" "$URL"
        set_env_value "WEB_API_ENABLED" "true"
    else
        set_env_value "WEB_API_ENABLED" "false"
    fi
    
    [ -n "$MODE" ] && set_env_value "BOT_RUN_MODE" "$MODE"
    
    echo -e "${GREEN}✅ Webhook настроен${NC}"
}

show_config() {
    echo -e "${CYAN}Текущая конфигурация:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${WHITE}Основные:${NC}"
    echo -e "  BOT_TOKEN: $(get_env_value BOT_TOKEN | head -c 20)..."
    echo -e "  ADMIN_IDS: $(get_env_value ADMIN_IDS)"
    echo
    echo -e "${WHITE}Remnawave:${NC}"
    echo -e "  API_URL: $(get_env_value REMNAWAVE_API_URL)"
    echo -e "  API_KEY: $(get_env_value REMNAWAVE_API_KEY | head -c 20)..."
    echo
    echo -e "${WHITE}Режим работы:${NC}"
    echo -e "  BOT_RUN_MODE: $(get_env_value BOT_RUN_MODE)"
    echo -e "  WEBHOOK_URL: $(get_env_value WEBHOOK_URL)"
    echo -e "  WEB_API_ENABLED: $(get_env_value WEB_API_ENABLED)"
    echo
    echo -e "${WHITE}Платежи:${NC}"
    echo -e "  Telegram Stars: $(get_env_value TELEGRAM_STARS_ENABLED)"
    echo -e "  YooKassa: $(get_env_value YOOKASSA_ENABLED)"
    echo -e "  CryptoBot: $(get_env_value CRYPTOBOT_ENABLED)"
    echo -e "  PayPalych: $(get_env_value PAL24_ENABLED)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

restart_bot() {
    echo -e "${CYAN}🔄 Перезапуск бота...${NC}"
    cd "$INSTALL_DIR"
    docker compose restart
    echo -e "${GREEN}✅ Бот перезапущен${NC}"
    docker compose ps
}

# Проверка установки
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}❌ Файл .env не найден в $INSTALL_DIR${NC}"
    echo -e "${YELLOW}Сначала выполните установку бота.${NC}"
    exit 1
fi

# Главный цикл
while true; do
    print_menu
    read -p "Ваш выбор: " CHOICE
    
    case $CHOICE in
        1) edit_bot_token ;;
        2) edit_admin_ids ;;
        3) edit_remnawave ;;
        4) edit_payments ;;
        5) edit_notifications ;;
        6) edit_webhook ;;
        7) show_config ;;
        8) restart_bot ;;
        0) 
            echo -e "${GREEN}До свидания!${NC}"
            exit 0
            ;;
        *) 
            echo -e "${RED}Неверный выбор${NC}"
            ;;
    esac
    
    echo
    read -p "Нажмите Enter для продолжения..."
done
