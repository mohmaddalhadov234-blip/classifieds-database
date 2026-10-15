#!/bin/bash
# Инициализация базы данных

DB_FILE="classifieds.db"

if [ -f "$DB_FILE" ]; then
    echo "База уже существует: $DB_FILE"
    read -p "Пересоздать? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
    rm "$DB_FILE"
fi

sqlite3 "$DB_FILE" < schema.sql
sqlite3 "$DB_FILE" < seed.sql

echo "База данных успешно создана: $DB_FILE"
echo ""
echo "Проверка:"
sqlite3 "$DB_FILE" "SELECT COUNT(*) AS users FROM users;"
sqlite3 "$DB_FILE" "SELECT COUNT(*) AS ads FROM advertisements;"
sqlite3 "$DB_FILE" "SELECT COUNT(*) AS categories FROM categories;"
