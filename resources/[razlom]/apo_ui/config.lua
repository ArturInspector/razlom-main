Config = {}

-- Настройки отображения
Config.HUD = {
    enabled = true,
    updateInterval = 500,  -- Обновление HUD каждые 500ms
    position = {
        health = {x = 20, y = 20},
        status = {x = -20, y = 20}  -- Правый верх (отрицательные = справа)
    }
}

-- Уведомления
Config.Notifications = {
    duration = 3000,        -- Длительность по умолчанию (мс)
    maxVisible = 5,         -- Максимум одновременно
    position = 'top-center'
}

-- Звуки UI
Config.Sounds = {
    enabled = true,
    volume = 0.3,
    types = {
        click = 'ui/click.ogg',
        hover = 'ui/hover.ogg',
        open = 'ui/open.ogg',
        close = 'ui/close.ogg',
        error = 'ui/error.ogg',
        success = 'ui/success.ogg',
        notify = 'ui/notify.ogg'
    }
}

-- Цвета статусов (для HUD)
Config.Colors = {
    health = {
        high = '#5a7a4d',      -- >70%
        medium = '#d4a574',    -- 30-70%
        low = '#c44536'        -- <30%
    },
    radiation = {
        safe = '#5a7a4d',
        warning = '#d4a574',
        danger = '#c44536'
    }
}










