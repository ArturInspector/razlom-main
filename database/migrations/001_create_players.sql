-- Таблица игроков
CREATE TABLE IF NOT EXISTS apo_players (
    identifier VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    `rank` INT DEFAULT 1,
    xp INT DEFAULT 0,
    faction VARCHAR(50) DEFAULT NULL,
    inventory TEXT,
    position TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_rank (`rank`),
    INDEX idx_faction (faction)
);

