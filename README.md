# Razlom — FiveM Server

Постапокалиптический полу-ММО сервер с вторжением инопланетных сущностей.

## Структура

```
resources/[razlom]/
├── apo_core/          # Ядро
├── apo_player/        # Игроки
├── apo_inventory/     # Инвентарь
├── apo_invasion/      # Вторжение (волны, узлы)
├── apo_progression/   # XP, ранги
└── ...
```

## Документация

См. [razlom-docs](../razlom-docs/)

## Запуск

```bash
# Установить зависимости (MySQL, oxmysql)
# Настроить server.cfg
bash run.sh +exec server.cfg
```

