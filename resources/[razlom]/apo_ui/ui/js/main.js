// ════════════════════════════════════════════════════════════
// Main - Основная логика UI
// ════════════════════════════════════════════════════════════

let config = null;
let currentMenu = null;
let selectedItem = null;

// ══════════════════════════════════════════════════════════
// Инициализация
// ══════════════════════════════════════════════════════════

function handleInit(cfg) {
    config = cfg;
    console.log('[APO_UI] Инициализация завершена', config);
}

// ══════════════════════════════════════════════════════════
// HUD управление
// ══════════════════════════════════════════════════════════

function handleHUDVisibility(visible) {
    const hud = document.getElementById('hud');
    if (visible) {
        hud.classList.remove('hidden');
    } else {
        hud.classList.add('hidden');
    }
}

function handleHUDUpdate(data) {
    // Здоровье
    if (data.health !== undefined) {
        const healthBar = document.getElementById('health-bar');
        const healthValue = document.getElementById('health-value');
        
        healthBar.style.width = data.health + '%';
        healthValue.textContent = Math.round(data.health) + '%';
        
        healthBar.className = 'progress-fill ' + getProgressBarClass(data.health, 'health');
    }
    
    // Радиация
    if (data.radiation !== undefined) {
        const radiationBar = document.getElementById('radiation-bar');
        const radiationValue = document.getElementById('radiation-value');
        
        radiationBar.style.width = data.radiation + '%';
        radiationValue.textContent = Math.round(data.radiation) + '%';
        
        radiationBar.className = 'progress-fill ' + getProgressBarClass(data.radiation, 'radiation');
    }
    
    // Вес инвентаря
    if (data.weight !== undefined && data.maxWeight !== undefined) {
        const weightValue = document.getElementById('weight-value');
        weightValue.textContent = `${data.weight.toFixed(1)}/${data.maxWeight.toFixed(1)}`;
    }
    
    // Жажда
    if (data.thirst !== undefined) {
        const thirstValue = document.getElementById('thirst-value');
        thirstValue.textContent = Math.round(data.thirst) + '%';
    }
    
    // Голод
    if (data.hunger !== undefined) {
        const hungerValue = document.getElementById('hunger-value');
        hungerValue.textContent = Math.round(data.hunger) + '%';
    }
}

// ══════════════════════════════════════════════════════════
// Уведомления
// ══════════════════════════════════════════════════════════

function handleNotification(message, type = 'info', duration = 3000) {
    const container = document.getElementById('notifications');
    
    const notification = createElement('div', ['notification', type]);
    const messageEl = createElement('div', ['notification-message']);
    messageEl.textContent = message;
    
    notification.appendChild(messageEl);
    container.appendChild(notification);
    
    if (config && config.Sounds && config.Sounds.enabled) {
        sendCallback('playSound', { sound: 'notify' });
    }
    
    setTimeout(() => {
        notification.classList.add('fade-out');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, duration);
}

// ══════════════════════════════════════════════════════════
// Модальные окна (Инвентарь и др.)
// ══════════════════════════════════════════════════════════

function handleOpenMenu(menuType, data) {
    const container = document.getElementById('modal-container');
    container.style.display = 'flex';
    currentMenu = menuType;

    if (menuType === 'inventory') {
        renderInventory(data);
    } else {
        // Заглушка для других меню
        const modal = createElement('div', ['modal']);
        const header = createElement('div', ['modal-header']);
        header.textContent = menuType.toUpperCase();
        
        const content = createElement('div', ['modal-content']);
        content.textContent = JSON.stringify(data, null, 2);
        
        const closeBtn = createElement('button', ['btn', 'btn-secondary']);
        closeBtn.textContent = 'Закрыть';
        closeBtn.onclick = () => sendCallback('close');
        
        modal.appendChild(header);
        modal.appendChild(content);
        modal.appendChild(closeBtn);
        
        container.innerHTML = '';
        container.appendChild(modal);
    }
}

function handleUpdateMenu(menuType, data) {
    if (currentMenu === menuType) {
        if (menuType === 'inventory') {
            renderInventory(data);
        }
    }
}

function handleCloseMenu() {
    const container = document.getElementById('modal-container');
    container.style.display = 'none';
    
    // Скрываем все подменю
    document.getElementById('inventory-menu').style.display = 'none';
    
    currentMenu = null;
    selectedItem = null;
}

// ══════════════════════════════════════════════════════════
// Рендеринг инвентаря
// ══════════════════════════════════════════════════════════

function renderInventory(data) {
    const menu = document.getElementById('inventory-menu');
    menu.style.display = 'flex';
    
    const weightText = document.getElementById('inv-weight-text');
    weightText.textContent = `ВЕС: ${data.weight.toFixed(1)}/${data.maxWeight.toFixed(1)} кг`;
    
    const grid = document.getElementById('inv-grid');
    grid.innerHTML = '';
    
    data.items.forEach(item => {
        const itemEl = createElement('div', ['inventory-item']);
        if (selectedItem && selectedItem.name === item.name) {
            itemEl.classList.add('active');
        }
        
        const iconEl = createElement('div', ['item-icon']);
        iconEl.textContent = getItemIcon(item.name);
        
        const labelEl = createElement('div', ['item-label']);
        labelEl.textContent = item.label;
        
        const countEl = createElement('div', ['item-count']);
        countEl.textContent = `x${item.count}`;
        
        itemEl.appendChild(iconEl);
        itemEl.appendChild(labelEl);
        itemEl.appendChild(countEl);
        
        itemEl.onclick = () => selectItem(item);
        
        grid.appendChild(itemEl);
    });
    
    // Если есть выбранный предмет, обновляем инфо
    if (selectedItem) {
        // Ищем обновленный предмет в списке
        const updatedItem = data.items.find(i => i.name === selectedItem.name);
        if (updatedItem) {
            showItemDetails(updatedItem);
        } else {
            selectedItem = null;
            showItemDetails(null);
        }
    }
}

function selectItem(item) {
    selectedItem = item;
    
    // Обновляем классы в сетке
    const items = document.querySelectorAll('.inventory-item');
    items.forEach(el => {
        if (el.querySelector('.item-label').textContent === item.label) {
            el.classList.add('active');
        } else {
            el.classList.remove('active');
        }
    });
    
    showItemDetails(item);
}

function showItemDetails(item) {
    const info = document.getElementById('inv-info');
    info.innerHTML = '';
    
    if (!item) {
        const empty = createElement('div', ['info-empty']);
        empty.textContent = 'ВЫБЕРИТЕ ПРЕДМЕТ';
        info.appendChild(empty);
        return;
    }
    
    const title = createElement('div', ['item-details-title']);
    title.textContent = item.label.toUpperCase();
    
    const weight = createElement('div', ['item-details-weight']);
    weight.textContent = `Вес: ${item.weight.toFixed(2)} кг / шт`;
    
    const desc = createElement('div', ['item-details-description']);
    desc.textContent = item.description || 'Описание отсутствует.';
    
    const actions = createElement('div', ['item-actions']);
    
    const useBtn = createElement('button', ['btn', 'btn-primary']);
    useBtn.textContent = 'ИСПОЛЬЗОВАТЬ';
    useBtn.onclick = () => sendCallback('useItem', { name: item.name });
    
    const dropBtn = createElement('button', ['btn', 'btn-secondary']);
    dropBtn.textContent = 'ВЫБРОСИТЬ';
    dropBtn.onclick = () => sendCallback('dropItem', { name: item.name });
    
    actions.appendChild(useBtn);
    actions.appendChild(dropBtn);
    
    info.appendChild(title);
    info.appendChild(weight);
    info.appendChild(desc);
    info.appendChild(actions);
}

function getItemIcon(itemName) {
    const icons = {
        'water': '💧',
        'canned_food': '🥫',
        'bandage': '🩹',
        'medkit': '💉',
        'antirad': '💊',
        'scrap_metal': '⛓️',
        'electronic_parts': '🔌',
        'fuel_can': '⛽'
    };
    return icons[itemName] || '📦';
}

// ══════════════════════════════════════════════════════════
// Отладка
// ══════════════════════════════════════════════════════════

if (window.location.hostname !== 'nui-game-internal') {
    // ... отладка ...
}
