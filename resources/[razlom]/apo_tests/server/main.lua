local tests = {}

ApoTest = {
    register = function(name, fn)
        table.insert(tests, { name = name, fn = fn })
    end,
    assertTrue = function(condition, message)
        if not condition then
            error(message or 'Assertion failed')
        end
    end,
    assertEquals = function(expected, actual, message)
        if expected ~= actual then
            error(message or string.format('Expected %s, got %s', tostring(expected), tostring(actual)))
        end
    end
}

local function loadTestFile(path)
    local content = LoadResourceFile(GetCurrentResourceName(), path)
    if not content then
        print('[TESTS] Файл не найден: ' .. path)
        return
    end

    local chunk, err = load(content, '@' .. path)
    if not chunk then
        print('[TESTS] Ошибка загрузки: ' .. err)
        return
    end

    chunk()
end

local function runTests()
    local passed, failed = 0, 0
    for _, test in ipairs(tests) do
        local ok, err = pcall(test.fn)
        if ok then
            passed = passed + 1
            print('[TESTS] PASS: ' .. test.name)
        else
            failed = failed + 1
            print('[TESTS] FAIL: ' .. test.name .. ' — ' .. err)
        end
    end

    print(string.format('[TESTS] Итог: %d passed, %d failed', passed, failed))
end

RegisterCommand('apotest', function()
    tests = {}
    loadTestFile('tests/inventory.lua')
    runTests()
end, true)

