ALTER TABLE apo_players 
ADD COLUMN equipped_weapons TEXT DEFAULT NULL 
COMMENT 'JSON array of equipped weapons with metadata';

