-- [[ Настройки темы (70% тёмно-серый / 30% фиолетовый акцент) ]]
local Theme = {
    MainBg = Color3.fromRGB(15, 15, 20),       -- Главный фон (70%)
    SecondaryBg = Color3.fromRGB(22, 22, 30),  -- Фон панелей и кнопок
    SearchBarBg = Color3.fromRGB(28, 28, 38),  -- Фон поиска
    Accent = Color3.fromRGB(138, 43, 226),     -- Яркий фиолетовый (30%)
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 170)
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Инициализация GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeteorStyleLib"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================
-- [1] ГЛАВНЫЙ ФРЕЙМ (ОСНОВА)
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.4, -175)
MainFrame.BackgroundColor3 = Theme.MainBg
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- ==========================================
-- [2] ТОП-БАР С ПОИСКОМ (ДЛЯ ДРАГ-И-ДРОПА)
-- ==========================================
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

-- Поисковая строка внутри Топ-Бара
local SearchContainer = Instance.new("Frame")
SearchContainer.Size = UDim2.new(0, 300, 0, 32)
SearchContainer.Position = UDim2.new(1, -315, 0.5, -16)
SearchContainer.BackgroundColor3 = Theme.SearchBarBg
SearchContainer.BorderSizePixel = 0
SearchContainer.Parent = TopBar

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent = SearchContainer

local SearchInput = Instance.new("TextBox")
SearchInput.Size = UDim2.new(1, -30, 1, 0)
SearchInput.Position = UDim2.new(0, 10, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.Font = Enum.Font.Gotham
SearchInput.Text = ""
SearchInput.PlaceholderText = "Найти функцию (Search)..."
SearchInput.PlaceholderColor3 = Theme.TextSecondary
SearchInput.TextColor3 = Theme.TextPrimary
SearchInput.TextSize = 13
SearchInput.TextXAlignment = Enum.TextXAlignment.Left
SearchInput.Parent = SearchContainer

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Size = UDim2.new(0, 20, 1, 0)
SearchIcon.Position = UDim2.new(1, -25, 0, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextSize = 12
SearchIcon.TextColor3 = Theme.Accent
SearchIcon.Parent = SearchContainer

-- Название чит-библиотеки в углу
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 150, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "METEOR.lua"
Title.TextColor3 = Theme.TextPrimary
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- ==========================================
-- [3] СТРУКТУРА: ВКЛАДКИ (ЛЕВО) И КОНТЕНТ (ПРАВО)
-- ==========================================
local SideBar = Instance.new("ScrollingFrame")
SideBar.Name = "SideBar"
SideBar.Size = UDim2.new(0, 140, 1, -60)
SideBar.Position = UDim2.new(0, 10, 0, 50)
SideBar.BackgroundTransparency = 1
SideBar.CanvasSize = UDim2.new(0, 0, 0, 0)
SideBar.ScrollBarThickness = 0
SideBar.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 6)
SideLayout.Parent = SideBar

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -170, 1, -60)
ContentContainer.Position = UDim2.new(0, 160, 0, 50)
ContentContainer.BackgroundColor3 = Theme.SecondaryBg
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentContainer

-- Таблицы для хранения страниц и кнопок (для поиска)
local Pages = {}
local AllButtons = {}
local FirstPage = nil

-- ==========================================
-- [4] ДВИЖОК БИБЛИОТЕКИ (ФУНКЦИИ КРЕЙТА)
-- ==========================================
local Library = {}

function Library:CreateTab(name)
    -- Фрейм для контента этой вкладки
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, -20, 1, -20)
    Page.Position = UDim2.new(0, 10, 0, 10)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.Parent = ContentContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.Parent = Page
    
    -- Авто-размер скроллинга под количество кнопок
    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y)
    end)

    -- Кнопка переключения вкладки в сайдбаре
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.BackgroundColor3 = Theme.SecondaryBg
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Text = name
    TabButton.TextColor3 = Theme.TextSecondary
    TabButton.TextSize = 13
    TabButton.AutoButtonColor = false
    TabButton.Parent = SideBar

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton

    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = Theme.Accent
    TabStroke.Thickness = 0
    TabStroke.Parent = TabButton

    -- Логика переключения
    local function Activate()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, btn in pairs(SideBar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.TextColor3 = Theme.TextSecondary
                btn.UIStroke.Thickness = 0
            end
        end
        Page.Visible = true
        TabButton.TextColor3 = Theme.TextPrimary
        TabButton.UIStroke.Thickness = 1
    end

    TabButton.MouseButton1Click:Connect(Activate)

    if not FirstPage then
        FirstPage = Activate
    end

    Pages[name] = Page

    -- Внутренний функционал добавления элементов во вкладку
    local Elements = {}
    
    function Elements:CreateButton(text, callback)
        local Button = Instance.new("TextButton")
        Button.Name = text
        Button.Size = UDim2.new(1, -6, 0, 38)
        Button.BackgroundColor3 = Theme.MainBg
        Button.Font = Enum.Font.Gotham
        Button.Text = "  " .. text
        Button.TextColor3 = Theme.TextPrimary
        Button.TextSize = 13
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.Parent = Page

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = Button

        -- Эффект при наведении
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SearchBarBg}):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.MainBg}):Play()
        end)

        Button.MouseButton1Click:Connect(function()
            -- Кратковременная фиолетовая вспышка при клике
            local flash = TweenService:Create(Button, TweenInfo.new(0.1), {TextColor3 = Theme.Accent})
            flash:Play()
            flash.Completed:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {TextColor3 = Theme.TextPrimary}):Play()
            end)
            
            pcall(callback)
        end)

        -- Сохраняем кнопку в глобальный список для работы поиска
        table.insert(AllButtons, {Instance = Button, Name = text:lower(), PageActivate = Activate})
    end

    return Elements
end

-- ==========================================
-- [5] СИСТЕМА УПРАВЛЕНИЯ (DRAG, HIDE, SEARCH)
-- ==========================================

-- Логика Драга (Перетаскивание за TopBar)
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Скрытие на Right Shift
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        uiVisible = not uiVisible
        ScreenGui.Enabled = uiVisible
    end
end)

-- Умный Поиск
SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchInput.Text:lower()
    
    if query == "" then
        -- Если поиск пустой, возвращаем всё как было
        for _, btnData in pairs(AllButtons) do
            btnData.Instance.Visible = true
        end
    else
        -- Скрываем неподходящие кнопки
        for _, btnData in pairs(AllButtons) do
            if string.find(btnData.Name, query) then
                btnData.Instance.Visible = true
                -- Автоматически перекидываем игрока на вкладку, где нашёлся элемент
                btnData.PageActivate()
            else
                btnData.Instance.Visible = false
            end
        end
    end
end)


-- ==========================================
-- [6] СОЗДАНИЕ ПРИМЕРОВ ВКЛАДОК И КНОПОК
-- ==========================================

-- Вкладка "Combat"
local CombatTab = Library:CreateTab("Combat")
CombatTab:CreateButton("Kill Aura", function()
    print("Kill Aura активирована!")
end)
CombatTab:CreateButton("Auto Clicker", function()
    print("Auto Clicker запущен")
end)
CombatTab:CreateButton("Hitboxes Expanded", function()
    print("Хитбоксы увеличены")
end)

-- Вкладка "Movement"
local MovementTab = Library:CreateTab("Movement")
MovementTab:CreateButton("Fly (Fly Hack)", function()
    print("Полет!")
end)
MovementTab:CreateButton("Speed Hack (CFrame)", function()
    print("Скорость изменена")
end)
MovementTab:CreateButton("Infinite Jump", function()
    print("Бесконечный прыжок")
end)

-- Вкладка "Visuals"
local VisualsTab = Library:CreateTab("Visuals")
VisualsTab:CreateButton("ESP Box", function()
    print("Подсветка игроков включена")
end)
VisualsTab:CreateButton("Chams", function()
    print("Цветные чамсы наложены")
end)

-- Запуск первой вкладки по умолчанию
if FirstPage then FirstPage() end

return Library
