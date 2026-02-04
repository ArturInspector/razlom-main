// ════════════════════════════════════════════════════════════
// Events - Обработка событий Lua ↔ JavaScript
// ════════════════════════════════════════════════════════════

/**
 * Получение имени родительского ресурса
 * @returns {string} Имя ресурса
 */
function GetParentResourceName() {
    return window.location.hostname === 'nui-game-internal' 
        ? 'apo_ui' 
        : 'apo_ui';
}

/**
 * Отправка callback в Lua
 * @param {string} action - Действие
 * @param {object} data - Данные
 * @returns {Promise} Promise с ответом
 */
async function sendCallback(action, data = {}) {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/${action}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });
        return await response.json();
    } catch (error) {
        console.error(`[APO_UI] Ошибка callback ${action}:`, error);
        return null;
    }
}

/**
 * Обработчик сообщений от Lua
 */
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (!data || !data.action) {
        return;
    }
    
    switch (data.action) {
        case 'init':
            handleInit(data.config);
            break;
            
        case 'setHUDVisible':
            handleHUDVisibility(data.visible);
            break;
            
        case 'updateHUD':
            handleHUDUpdate(data.data);
            break;
            
        case 'notify':
            handleNotification(data.message, data.type, data.duration);
            break;
            
        case 'showAlert':
            handleAlert(data.alertType, data.title, data.message, data.duration, data.critical);
            break;
            
        case 'openMenu':
            handleOpenMenu(data.menuType, data.data);
            break;
            
        case 'updateMenu':
            handleUpdateMenu(data.menuType, data.data);
            break;
            
        case 'closeMenu':
            handleCloseMenu();
            break;
            
        default:
            console.warn(`[APO_UI] Неизвестное действие: ${data.action}`);
    }
});

/**
 * Обработка ESC для закрытия меню
 */
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        const modalContainer = document.getElementById('modal-container');
        if (modalContainer && modalContainer.style.display !== 'none') {
            sendCallback('close');
        }
    }
});

