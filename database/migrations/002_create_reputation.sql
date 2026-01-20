-- Таблица репутации с фракциями
CREATE TABLE IF NOT EXISTS apo_reputation (
    identifier VARCHAR(50) NOT NULL,
    faction VARCHAR(50) NOT NULL,
    reputation INT DEFAULT 0,
    PRIMARY KEY (identifier, faction),
    FOREIGN KEY (identifier) REFERENCES apo_players(identifier) ON DELETE CASCADE,
    INDEX idx_faction (faction)
);

