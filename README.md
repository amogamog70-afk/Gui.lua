🕹️ Minecraft-Style Roblox UI Library
Легковесная, минималистичная и полностью кастомизируемая UI-библиотека для Roblox, выполненная в стиле олдскульных чит-клиентов Minecraft (Huzuni, Wurst, Vape). Идеально подходит для создания скриптов, чит-меню или административных панелей.

✨ Особенности / Features
📐 Олдскульный дизайн: Строгие прямоугольные формы без скруглений, пиксельные рамки и моноширинный шрифт.

🗂️ Модульная структура: Возможность создавать бесконечное количество независимых окон (категорий) одной строчкой кода.

🛠️ Встроенный Dragging: Каждое окно можно свободно перетаскивать по экрану, удерживая за верхнюю панель.

🔼 Сворачивание окон: Локальное скрытие содержимого вкладки по нажатию на стрелочку (▲ / ▼).

⌨️ Глобальный бинд (Right Shift): Быстрое скрытие и отображение абсолютно всего интерфейса по нажатию на Правый Shift.

⚡ Авто-выравнивание: Окна автоматически подстраивают свой размер по высоте в зависимости от количества кнопок внутри.

🚀 Быстрый старт (Начало работы)
Чтобы использовать библиотеку в своем проекте, вставь этот код в свой загрузчик (Executor или LocalScript в Roblox Studio):

Lua
-- Загрузка библиотеки с вашего GitHub
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ВСТАВЬ_СВОЙ_НИК/ВСТАВЬ_ИМЯ_РЕПОЗИТОРИЯ/main/main.lua"))()

-- 1. Создаем окно для категории Combat
local CombatWindow = Library:CreateWindow("Combat", UDim2.new(0, 50, 0, 50))

CombatWindow:CreateToggle("KillAura", function(state)
    print("Киллаура:", state)
end)

CombatWindow:CreateToggle("AutoClicker", function(state)
    print("Автокликер:", state)
end)

-- 2. Создаем окно для категории Movement
local MoveWindow = Library:CreateWindow("Movement", UDim2.new(0, 240, 0, 50))

MoveWindow:CreateToggle("Fly", function(state)
    print("Полет:", state)
end)

MoveWindow:CreateButton("Teleport to Spawn", function()
    game.Players.LocalPlayer.Character:MoveTo(Vector3.new(0, 10, 0))
end)
📚 Документация API
Инициализация окна
Lua
local Window = Library:CreateWindow(titleText, defaultPosition)
titleText (string) — Название вкладки (автоматически переводится в верхний регистр).

defaultPosition (UDim2) — Начальное положение окна на экране.

Создание переключателя (Toggle)
Lua
Window:CreateToggle(toggleName, callback)
toggleName (string) — Название функции.

callback (function) — Функция, которая срабатывает при нажатии. Возвращает true (включено) или false (выключено).

Создание обычной кнопки (Button)
Lua
Window:CreateButton(buttonName, callback)
buttonName (string) — Текст на кнопке.

callback (function) — Функция, которая сработает один раз при клике.

🛠️ Кастомизация
Если вы хотите изменить цвета (например, сделать обводку зеленой или красной), откройте файл main.lua и отредактируйте параметры цветов:

Color3.fromRGB(15, 15, 15) — Фон окон.

Color3.fromRGB(255, 255, 255) — Цвет обводки (бордюра).

Color3.fromRGB(30, 30, 30) — Цвет верхней панели (шапки).
