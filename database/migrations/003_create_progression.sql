-- Таблица прогрессии и перков
CREATE TABLE IF NOT EXISTS apo_progression (
    identifier VARCHAR(50) PRIMARY KEY,
    perks TEXT, -- JSON массив активных перков
    talents TEXT, -- JSON дерево талантов
    FOREIGN KEY (identifier) REFERENCES apo_players(identifier) ON DELETE CASCADE
);

