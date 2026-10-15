-- Схема базы данных для сайта объявлений
-- SQLite совместима, легко портируется на PostgreSQL/MySQL

PRAGMA foreign_keys = ON;

-- Пользователи
CREATE TABLE users (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    email       TEXT NOT NULL UNIQUE,
    phone       TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Категории
CREATE TABLE categories (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL UNIQUE
);

-- Объявления
CREATE TABLE advertisements (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    owner_id    INTEGER NOT NULL,
    title       TEXT NOT NULL,
    text        TEXT,                    -- описание
    price       DECIMAL(12, 2),
    status      TEXT NOT NULL DEFAULT 'активно'
                    CHECK (status IN ('активно', 'продано', 'снято')),
    date        DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Связь объявлений и категорий (many-to-many)
CREATE TABLE ads_categories (
    ad_id       INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    PRIMARY KEY (ad_id, category_id),
    FOREIGN KEY (ad_id) REFERENCES advertisements(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- Продвижения (платные услуги)
CREATE TABLE promotions (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    ad_id       INTEGER NOT NULL,
    type        TEXT NOT NULL,           -- например: 'поднять', 'выделить', 'премиум'
    start       DATETIME NOT NULL,
    end         DATETIME NOT NULL,
    status      TEXT NOT NULL DEFAULT 'активно'
                    CHECK (status IN ('активно', 'завершено', 'отменено')),
    FOREIGN KEY (ad_id) REFERENCES advertisements(id) ON DELETE CASCADE
);

-- Статистика просмотров / звонков / сообщений
CREATE TABLE stats (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    ad_id       INTEGER NOT NULL,
    event_type  TEXT NOT NULL
                    CHECK (event_type IN ('просмотр', 'звонок', 'сообщение')),
    count       INTEGER NOT NULL DEFAULT 1,
    date        DATE NOT NULL DEFAULT (date('now')),
    FOREIGN KEY (ad_id) REFERENCES advertisements(id) ON DELETE CASCADE
);

-- Индексы для производительности
CREATE INDEX idx_ads_owner      ON advertisements(owner_id);
CREATE INDEX idx_ads_status     ON advertisements(status);
CREATE INDEX idx_ads_date       ON advertisements(date);
CREATE INDEX idx_promotions_ad  ON promotions(ad_id);
CREATE INDEX idx_stats_ad       ON stats(ad_id);
CREATE INDEX idx_stats_date     ON stats(date);
