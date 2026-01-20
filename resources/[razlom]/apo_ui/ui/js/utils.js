// ════════════════════════════════════════════════════════════
// Utils - Утилиты
// ════════════════════════════════════════════════════════════

/**
 * Получить цвет для прогресс-бара в зависимости от значения
 * @param {number} value - Значение (0-100)
 * @param {string} type - Тип статуса (health, radiation)
 * @returns {string} CSS класс
 */
function getProgressBarClass(value, type) {
    if (type === 'health') {
        if (value < 30) return 'danger critical';
        if (value < 70) return 'warning';
        return 'health';
    }
    
    if (type === 'radiation') {
        if (value > 70) return 'danger critical';
        if (value > 30) return 'warning';
        return 'radiation';
    }
    
    return '';
}

/**
 * Форматирование числа с ведущими нулями
 * @param {number} num - Число
 * @param {number} size - Количество цифр
 * @returns {string} Отформатированное число
 */
function padNumber(num, size) {
    let s = num + "";
    while (s.length < size) s = "0" + s;
    return s;
}

/**
 * Ограничение значения в диапазоне
 * @param {number} value - Значение
 * @param {number} min - Минимум
 * @param {number} max - Максимум
 * @returns {number} Ограниченное значение
 */
function clamp(value, min, max) {
    return Math.min(Math.max(value, min), max);
}

/**
 * Интерполяция между двумя значениями
 * @param {number} a - Начальное значение
 * @param {number} b - Конечное значение
 * @param {number} t - Коэффициент (0-1)
 * @returns {number} Интерполированное значение
 */
function lerp(a, b, t) {
    return a + (b - a) * t;
}

/**
 * Генерация уникального ID
 * @returns {string} Уникальный ID
 */
function generateId() {
    return '_' + Math.random().toString(36).substr(2, 9);
}

/**
 * Создание DOM элемента с классами и атрибутами
 * @param {string} tag - Тег элемента
 * @param {string[]} classes - Массив классов
 * @param {object} attrs - Объект атрибутов
 * @returns {HTMLElement} Созданный элемент
 */
function createElement(tag, classes = [], attrs = {}) {
    const element = document.createElement(tag);
    
    if (classes.length > 0) {
        element.classList.add(...classes);
    }
    
    Object.keys(attrs).forEach(key => {
        element.setAttribute(key, attrs[key]);
    });
    
    return element;
}

/**
 * Плавное изменение ширины прогресс-бара
 * @param {HTMLElement} element - Элемент прогресс-бара
 * @param {number} targetWidth - Целевая ширина (%)
 * @param {number} duration - Длительность (мс)
 */
function animateProgressBar(element, targetWidth, duration = 300) {
    const startWidth = parseFloat(element.style.width) || 0;
    const startTime = Date.now();
    
    function update() {
        const elapsed = Date.now() - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const currentWidth = lerp(startWidth, targetWidth, progress);
        
        element.style.width = currentWidth + '%';
        
        if (progress < 1) {
            requestAnimationFrame(update);
        }
    }
    
    requestAnimationFrame(update);
}










