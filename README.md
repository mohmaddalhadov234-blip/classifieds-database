# Classifieds Database

База данных для сайта объявлений (классифайды).

## Структура

| Таблица | Описание |
|--------|----------|
| `users` | Пользователи (профили) |
| `advertisements` | Объявления |
| `categories` | Категории |
| `ads_categories` | Связь many-to-many объявлений и категорий |
| `promotions` | Платные продвижения |
| `stats` | Статистика (просмотры, звонки, сообщения) |

## Быстрый старт (SQLite)

```bash
# Создать базу и применить схему
sqlite3 classifieds.db < schema.sql

# Загрузить тестовые данные
sqlite3 classifieds.db < seed.sql

# Проверить
sqlite3 classifieds.db "SELECT * FROM advertisements;"
```

## Примеры запросов

### Все активные объявления с владельцем и категориями
```sql
SELECT 
    a.id,
    a.title,
    a.price,
    a.status,
    u.name AS owner,
    GROUP_CONCAT(c.name) AS categories
FROM advertisements a
JOIN users u ON u.id = a.owner_id
LEFT JOIN ads_categories ac ON ac.ad_id = a.id
LEFT JOIN categories c ON c.id = ac.category_id
WHERE a.status = 'активно'
GROUP BY a.id;
```

### Статистика по объявлению
```sql
SELECT event_type, SUM(count) as total
FROM stats
WHERE ad_id = 1
GROUP BY event_type;
```

### Объявления с активными продвижениями
```sql
SELECT a.title, p.type, p.start, p.end
FROM advertisements a
JOIN promotions p ON p.ad_id = a.id
WHERE p.status = 'активно'
  AND datetime('now') BETWEEN p.start AND p.end;
```

## API (рекомендуемые эндпоинты)

### Пользователи
- `POST /api/users` — создать
- `GET /api/users/{id}` — получить
- `PUT /api/users/{id}` — обновить
- `DELETE /api/users/{id}` — удалить

### Объявления
- `POST /api/ads` — создать
- `GET /api/ads` — список (фильтры: `?status=активно&category=Транспорт&page=1&limit=20`)
- `GET /api/ads/{id}` — одно объявление
- `PUT /api/ads/{id}` — обновить
- `DELETE /api/ads/{id}` — удалить

## Заметки по проектированию

- Внешние ключи включены (`PRAGMA foreign_keys = ON`)
- При удалении пользователя каскадно удаляются его объявления
- При удалении объявления каскадно удаляются связи, продвижения и статистика
- Статусы ограничены CHECK-ограничениями
- Добавлены индексы на часто используемые поля

## Портирование

Схема написана под SQLite, но легко переносится:

- PostgreSQL: заменить `AUTOINCREMENT` на `SERIAL` / `GENERATED ALWAYS AS IDENTITY`
- MySQL: `AUTO_INCREMENT`, типы дат оставить как есть

## Автор

Домашнее задание по базам данных.
