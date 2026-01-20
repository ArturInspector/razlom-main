# Миграции базы данных Razlom

## Применение миграций

```bash
# Подключение к MySQL
mysql -u root -p

# Создание БД и пользователя
CREATE DATABASE apo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'apo'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON apo.* TO 'apo'@'localhost';
FLUSH PRIVILEGES;
USE apo;

# Применение миграций по порядку
SOURCE migrations/001_create_players.sql;
SOURCE migrations/002_create_reputation.sql;
SOURCE migrations/003_create_progression.sql;
```

## Структура таблиц

- `apo_players` — основные данные игроков
- `apo_reputation` — репутация с фракциями
- `apo_progression` — перки и таланты

