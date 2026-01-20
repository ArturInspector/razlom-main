# 🎨 APO_UI - UI System

Система интерфейсов для Mad Max RP сервера.

## 📁 Структура

```
apo_ui/
├── fxmanifest.lua          # Манифест ресурса
├── config.lua              # Конфигурация
├── client/
│   └── main.lua            # Клиентская логика
└── ui/                     # NUI файлы
    ├── index.html          # Точка входа
    ├── css/                # Стили
    │   ├── reset.css       # CSS Reset
    │   ├── variables.css   # CSS переменные (Design System)
    │   ├── components.css  # Компоненты
    │   └── animations.css  # Анимации
    └── js/                 # JavaScript
        ├── main.js         # Основная логика
        ├── events.js       # Обработка событий Lua↔JS
        └── utils.js        # Утилиты
```

## 🎯 Возможности

### HUD (Heads-Up Display)
- Здоровье (HP) с цветовой индикацией
- Радиация (RAD)
- Вес инвентаря (🎒)
- Жажда (💧)
- Голод (🍖)

### Уведомления
- 4 типа: success, warning, error, info
- Автоматическое исчезновение
- Стэкинг уведомлений

### Модальные окна
- Инвентарь (в разработке)
- Крафтинг (в разработке)
- Торговля (в разработке)

## 🔌 API

### Экспорты (Lua)

```lua
-- Показать уведомление
exports['apo_ui']:ShowNotification(message, type, duration)

-- Обновить HUD
exports['apo_ui']:UpdateHUD({
    health = 75,
    hunger = 60,
    thirst = 80,
    radiation = 25,
    weight = 25,
    maxWeight = 50
})

-- Открыть меню
exports['apo_ui']:OpenMenu('inventory', data)

-- Закрыть меню
exports['apo_ui']:CloseMenu()

-- Показать/скрыть HUD
exports['apo_ui']:ShowHUD()
exports['apo_ui']:HideHUD()
```

### События (Lua)

```lua
-- Показать уведомление
TriggerEvent('apo:ui:notify', 'Сообщение', 'success', 3000)

-- Обновить HUD
TriggerEvent('apo:ui:updateHUD', { health = 75 })

-- Переключить видимость HUD
TriggerEvent('apo:ui:toggleHUD', true)
```

## 🎨 Design System

Все UI компоненты следуют единой системе дизайна из `docs/DESIGN.md`:

### Цвета
- Фон: `#1a1a1a`, `#2a2a2a`, `#333333`
- Акценты: `#c44536` (опасность), `#d4a574` (предупреждение), `#5a7a4d` (успех)
- Текст: `#e8e8e8`, `#a0a0a0`

### Шрифты
- Основной: `Roboto Mono, Consolas, monospace`
- Заголовки: `Bebas Neue, Impact, sans-serif`

## 🧪 Тестирование

### В браузере

Откройте `ui/index.html` в браузере для предпросмотра. Автоматически запустятся тестовые данные.

### В игре (DEBUG режим)

```lua
-- В server.cfg добавьте:
set apo_debug "true"

-- Затем в игре используйте команды:
/testui      # Тестовое уведомление и HUD
/testmenu    # Тестовое меню
```

## 📦 NUI Архитектура

### Lua → JavaScript

```lua
SendNUIMessage({
    action = 'updateHUD',
    data = { health = 75 }
})
```

### JavaScript → Lua

```javascript
await sendCallback('close', { reason: 'user' })
```

## 🎯 Best Practices

1. **Производительность**
   - Минимизируйте DOM операции
   - Используйте `requestAnimationFrame` для анимаций
   - Обновляйте HUD не чаще 500ms

2. **Коммуникация**
   - Всегда используйте события через `SendNUIMessage`
   - Валидируйте данные на клиенте
   - Используйте callback для двусторонней связи

3. **Стиль**
   - Используйте CSS переменные из `variables.css`
   - Не хардкодьте цвета и размеры
   - Следуйте Design System

## 🔧 Конфигурация

Все настройки в `config.lua`:

```lua
Config.HUD.updateInterval = 500  -- Частота обновления HUD (мс)
Config.Notifications.duration = 3000  -- Длительность уведомлений
Config.Sounds.enabled = true  -- Включить звуки UI
```

## 🐛 Отладка

```javascript
// В браузере откройте Console (F12)
// Логи будут выглядеть так:
[APO_UI] Инициализация завершена
[APO_UI] HUD обновлён: {...}
```

## 📝 TODO

- [ ] Интеграция с apo_player для реального HUD
- [ ] Полноценный инвентарь с drag & drop
- [ ] Меню крафтинга
- [ ] Система диалогов с NPC
- [ ] Миникарта
- [ ] Звуковые эффекты UI

---

*Документация обновлена: Январь 2026*

