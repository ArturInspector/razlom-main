// ════════════════════════════════════════════════════════════
// Main - Основная логика UI
// ════════════════════════════════════════════════════════════

let config = null;
let currentMenu = null;
let selectedItem = null;
let selectedRecipe = null;
const DEFAULT_THREAT_MAX = 10;

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
        const healthCard = document.getElementById('card-health');
        
        animateProgressBar(healthBar, data.health);
        healthValue.textContent = Math.round(data.health) + '%';
        
        healthBar.className = 'progress-fill ' + getProgressBarClass(data.health, 'health');
        healthCard.classList.toggle('critical', data.health < 30);
    }
    
    // Радиация
    if (data.radiation !== undefined) {
        const radiationBar = document.getElementById('radiation-bar');
        const radiationValue = document.getElementById('radiation-value');
        const radiationCard = document.getElementById('card-radiation');
        const contamination = document.getElementById('contamination-overlay');
        
        animateProgressBar(radiationBar, data.radiation);
        radiationValue.textContent = Math.round(data.radiation) + '%';
        
        radiationBar.className = 'progress-fill ' + getProgressBarClass(data.radiation, 'radiation');
        const isContaminated = data.radiation > 60;
        radiationCard.classList.toggle('contaminated', isContaminated);
        contamination.classList.toggle('active', isContaminated);
    }
    
    // Вес инвентаря
    if (data.weight !== undefined && data.maxWeight !== undefined) {
        const weightValue = document.getElementById('weight-value');
        const weightCard = document.getElementById('card-weight');
        weightValue.textContent = `${data.weight.toFixed(1)}/${data.maxWeight.toFixed(1)}`;
        const ratio = data.maxWeight > 0 ? data.weight / data.maxWeight : 0;
        weightCard.classList.remove('warning', 'critical');
        if (ratio >= 0.95) {
            weightCard.classList.add('critical');
        } else if (ratio >= 0.8) {
            weightCard.classList.add('warning');
        }
    }
    
    // Жажда
    if (data.thirst !== undefined) {
        const thirstValue = document.getElementById('thirst-value');
        thirstValue.textContent = Math.round(data.thirst) + '%';
        const thirstCard = document.getElementById('card-thirst');
        thirstCard.classList.remove('critical');
        if (data.thirst < 25) {
            thirstCard.classList.add('critical');
        }
    }
    
    // Голод
    if (data.hunger !== undefined) {
        const hungerValue = document.getElementById('hunger-value');
        hungerValue.textContent = Math.round(data.hunger) + '%';
        const hungerCard = document.getElementById('card-hunger');
        hungerCard.classList.remove('critical');
        if (data.hunger < 25) {
            hungerCard.classList.add('critical');
        }
    }

    // Уровень угрозы
    if (data.threat !== undefined || data.threatLevel !== undefined) {
        const level = data.threat ?? data.threatLevel;
        const max = data.threatMax ?? data.maxThreat ?? DEFAULT_THREAT_MAX;
        updateThreat(level, max);
    }

    // Зона
    if (data.zone !== undefined) {
        updateZone(data.zone);
    }

    // Захват узла
    if (data.capture !== undefined) {
        updateCapture(data.capture);
    }
}

function updateThreat(level, maxThreat) {
    const bar = document.getElementById('threat-bar');
    const fill = document.getElementById('threat-fill');
    const value = document.getElementById('threat-value');
    const status = document.getElementById('threat-status');

    const safeMax = Math.max(maxThreat || DEFAULT_THREAT_MAX, 1);
    const clamped = clamp(level, 0, safeMax);
    const percent = (clamped / safeMax) * 100;

    fill.style.width = `${percent}%`;
    value.textContent = `${clamped.toFixed(1)} / ${safeMax}`;

    let state = 'stable';
    if (clamped >= safeMax * 0.8) {
        state = 'critical';
    } else if (clamped >= safeMax * 0.6) {
        state = 'danger';
    } else if (clamped >= safeMax * 0.35) {
        state = 'warning';
    }

    bar.classList.remove('warning', 'danger', 'critical');
    if (state !== 'stable') bar.classList.add(state);

    const fillColor = {
        critical: 'linear-gradient(135deg, #ff073a 0%, #7b001c 100%)',
        danger: 'linear-gradient(135deg, #ff6b35 0%, #8c2f12 100%)',
        warning: 'linear-gradient(135deg, #ff6b35 0%, #8c2f12 100%)',
        stable: 'linear-gradient(135deg, #00f5ff 0%, #007b8c 100%)'
    };
    fill.style.background = fillColor[state];

    const labelMap = {
        critical: 'Critical escalation',
        danger: 'High activity',
        warning: 'Elevated signal',
        stable: 'Low signal'
    };
    status.textContent = labelMap[state];
}

function updateZone(zone) {
    const zoneEl = document.getElementById('zone-status');
    const nameEl = document.getElementById('zone-name');
    const metaEl = document.getElementById('zone-meta');

    if (!zone || !nameEl || !metaEl) return;

    nameEl.textContent = (zone.name || 'UNKNOWN').toUpperCase();

    const danger = zone.dangerous ? 'DANGER' : 'SAFE';
    const bonus = zone.threat_bonus ? `+${zone.threat_bonus} THREAT` : '';
    const type = zone.type ? zone.type.toUpperCase() : '';
    metaEl.textContent = [danger, type, bonus].filter(Boolean).join(' • ');

    zoneEl.classList.toggle('danger', !!zone.dangerous);
}

function updateCapture(capture) {
    const container = document.getElementById('capture-status');
    if (!container) return;

    if (!capture.active) {
        container.classList.add('hidden');
        return;
    }

    container.classList.remove('hidden');
    const nameEl = document.getElementById('capture-name');
    const fillEl = document.getElementById('capture-fill');
    const valueEl = document.getElementById('capture-value');
    const metaEl = document.getElementById('capture-meta');

    const progress = clamp(capture.progress || 0, 0, 100);
    if (nameEl) nameEl.textContent = (capture.label || 'NODE').toUpperCase();
    if (fillEl) fillEl.style.width = `${progress}%`;
    if (valueEl) valueEl.textContent = `${progress}%`;

    const waves = capture.wavesLeft !== undefined ? `WAVES: ${capture.wavesLeft}` : '';
    const time = capture.timeLeft !== undefined ? `TIME: ${capture.timeLeft}s` : '';
    if (metaEl) metaEl.textContent = [waves, time].filter(Boolean).join(' • ');
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
    const inventoryMenu = document.getElementById('inventory-menu');
    const craftingMenu = document.getElementById('crafting-menu');
    const existingDynamic = container.querySelector('.dynamic-modal');
    if (existingDynamic) existingDynamic.remove();

    container.style.display = 'flex';
    currentMenu = menuType;

    if (menuType === 'inventory') {
        if (inventoryMenu) inventoryMenu.style.display = 'flex';
        if (craftingMenu) craftingMenu.style.display = 'none';
        renderInventory(data);
    } else if (menuType === 'crafting') {
        if (inventoryMenu) inventoryMenu.style.display = 'none';
        if (craftingMenu) craftingMenu.style.display = 'flex';
        renderCrafting(data);
    } else if (menuType === 'shop') {
        if (inventoryMenu) inventoryMenu.style.display = 'none';
        if (craftingMenu) craftingMenu.style.display = 'none';
        renderShop(data);
    } else if (menuType === 'faction') {
        if (inventoryMenu) inventoryMenu.style.display = 'none';
        if (craftingMenu) craftingMenu.style.display = 'none';
        renderFaction(data);
    } else {
        // Заглушка для других меню
        if (inventoryMenu) inventoryMenu.style.display = 'none';
        if (craftingMenu) craftingMenu.style.display = 'none';

        const modal = createElement('div', ['modal', 'dynamic-modal']);
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
        
        container.appendChild(modal);
    }
}

function handleUpdateMenu(menuType, data) {
    if (currentMenu === menuType) {
        if (menuType === 'inventory') {
            renderInventory(data);
        } else if (menuType === 'crafting') {
            renderCrafting(data);
        } else if (menuType === 'shop') {
            renderShop(data);
        } else if (menuType === 'faction') {
            renderFaction(data);
        }
    }
}

function handleCloseMenu() {
    const container = document.getElementById('modal-container');
    container.style.display = 'none';
    
    // Скрываем все подменю
    document.getElementById('inventory-menu').style.display = 'none';
    document.getElementById('crafting-menu').style.display = 'none';
    const existingDynamic = container.querySelector('.dynamic-modal');
    if (existingDynamic) existingDynamic.remove();
    
    currentMenu = null;
    selectedItem = null;
    selectedRecipe = null;
}

function renderShop(data) {
    const container = document.getElementById('modal-container');
    const existing = container.querySelector('.dynamic-modal');
    if (existing) existing.remove();

    const modal = createElement('div', ['modal', 'dynamic-modal', 'shop-modal']);
    const header = createElement('div', ['modal-header']);
    header.textContent = 'COLONY EXCHANGE';

    const currency = createElement('div', ['shop-currency']);
    currency.textContent = `CREDITS: ${data.currency || 0}`;

    const list = createElement('div', ['shop-list']);
    (data.items || []).forEach(item => {
        const row = createElement('div', ['shop-item']);
        const label = createElement('div', ['shop-item-label']);
        label.textContent = item.label;

        const price = createElement('div', ['shop-item-price']);
        price.textContent = `BUY: ${item.price} / SELL: ${item.sellPrice}`;

        const actions = createElement('div', ['shop-actions']);
        const buyBtn = createElement('button', ['btn', 'btn-primary']);
        buyBtn.textContent = 'КУПИТЬ';
        buyBtn.onclick = () => sendCallback('shopBuy', { item: item.name, count: 1 });

        const sellBtn = createElement('button', ['btn', 'btn-secondary']);
        sellBtn.textContent = 'ПРОДАТЬ';
        sellBtn.onclick = () => sendCallback('shopSell', { item: item.name, count: 1 });

        actions.appendChild(buyBtn);
        actions.appendChild(sellBtn);

        row.appendChild(label);
        row.appendChild(price);
        row.appendChild(actions);
        list.appendChild(row);
    });

    const closeBtn = createElement('button', ['btn', 'btn-secondary']);
    closeBtn.textContent = 'ЗАКРЫТЬ';
    closeBtn.onclick = () => sendCallback('close');

    modal.appendChild(header);
    modal.appendChild(currency);
    modal.appendChild(list);
    modal.appendChild(closeBtn);

    container.appendChild(modal);
}

function renderFaction(data) {
    const container = document.getElementById('modal-container');
    const existing = container.querySelector('.dynamic-modal');
    if (existing) existing.remove();

    const modal = createElement('div', ['modal', 'dynamic-modal', 'faction-modal']);
    const header = createElement('div', ['modal-header']);
    header.textContent = 'FACTION CHOICE';

    const list = createElement('div', ['faction-list']);
    (data.factions || []).forEach(faction => {
        const row = createElement('div', ['faction-item']);
        const label = createElement('div', ['faction-label']);
        label.textContent = faction.label;

        const desc = createElement('div', ['faction-desc']);
        desc.textContent = faction.bonus;

        const chooseBtn = createElement('button', ['btn', 'btn-primary']);
        chooseBtn.textContent = 'ВЫБРАТЬ';
        chooseBtn.onclick = () => sendCallback('factionSelect', { id: faction.id });

        row.appendChild(label);
        row.appendChild(desc);
        row.appendChild(chooseBtn);
        list.appendChild(row);
    });

    const closeBtn = createElement('button', ['btn', 'btn-secondary']);
    closeBtn.textContent = 'ЗАКРЫТЬ';
    closeBtn.onclick = () => sendCallback('close');

    modal.appendChild(header);
    modal.appendChild(list);
    modal.appendChild(closeBtn);

    container.appendChild(modal);
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
// Рендеринг крафта
// ══════════════════════════════════════════════════════════

function renderCrafting(data) {
    const menu = document.getElementById('crafting-menu');
    menu.style.display = 'flex';

    const list = document.getElementById('craft-list');
    list.innerHTML = '';

    const recipes = data.recipes || [];
    recipes.forEach(recipe => {
        const recipeEl = createElement('div', ['crafting-item']);
        if (selectedRecipe && selectedRecipe.name === recipe.name) {
            recipeEl.classList.add('active');
        }

        const titleEl = createElement('div', ['crafting-item-title']);
        titleEl.textContent = recipe.label.toUpperCase();

        const timeEl = createElement('div', ['crafting-item-time']);
        timeEl.textContent = `ВРЕМЯ: ${Math.floor((recipe.time || 0) / 1000)}С`;

        recipeEl.appendChild(titleEl);
        recipeEl.appendChild(timeEl);
        recipeEl.onclick = () => selectRecipe(recipe);
        list.appendChild(recipeEl);
    });

    if (selectedRecipe) {
        const updatedRecipe = recipes.find(r => r.name === selectedRecipe.name);
        if (updatedRecipe) {
            showRecipeDetails(updatedRecipe);
        } else {
            selectedRecipe = null;
            showRecipeDetails(null);
        }
    }
}

function selectRecipe(recipe) {
    selectedRecipe = recipe;
    const items = document.querySelectorAll('.crafting-item');
    items.forEach(el => {
        if (el.querySelector('.crafting-item-title').textContent === recipe.label.toUpperCase()) {
            el.classList.add('active');
        } else {
            el.classList.remove('active');
        }
    });
    showRecipeDetails(recipe);
}

function showRecipeDetails(recipe) {
    const info = document.getElementById('craft-info');
    info.innerHTML = '';

    if (!recipe) {
        const empty = createElement('div', ['info-empty']);
        empty.textContent = 'ВЫБЕРИТЕ РЕЦЕПТ';
        info.appendChild(empty);
        return;
    }

    const title = createElement('div', ['crafting-recipe-title']);
    title.textContent = recipe.label.toUpperCase();

    const list = createElement('div', ['crafting-recipe-list']);
    recipe.inputs.forEach(input => {
        const row = createElement('div', ['crafting-recipe-item']);
        row.innerHTML = `<span>${input.label}</span><span>x${input.count}</span>`;
        list.appendChild(row);
    });

    const output = createElement('div', ['crafting-recipe-item']);
    output.innerHTML = `<span>${recipe.output.label}</span><span>+${recipe.output.count}</span>`;

    const actions = createElement('div', ['item-actions']);
    const craftBtn = createElement('button', ['btn', 'btn-primary']);
    craftBtn.textContent = 'СОБРАТЬ';
    craftBtn.onclick = () => sendCallback('craftItem', { name: recipe.name });

    actions.appendChild(craftBtn);

    info.appendChild(title);
    info.appendChild(list);
    info.appendChild(output);
    info.appendChild(actions);
}

// ══════════════════════════════════════════════════════════
// Отладка
// ══════════════════════════════════════════════════════════

if (window.location.hostname !== 'nui-game-internal') {
    // ... отладка ...
}
