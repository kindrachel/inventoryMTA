-- inventar.sql - только индексы и дополнительные настройки

-- Создаем индексы для производительности
CREATE INDEX IF NOT EXISTS idx_items_user ON items(user_id);
CREATE INDEX IF NOT EXISTS idx_world_items_position ON world_items(position);
CREATE INDEX IF NOT EXISTS idx_inventarinhalt_user ON inventarinhalt(user_id);