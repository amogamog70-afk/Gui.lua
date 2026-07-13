-- [[ Настройки темы (70% тёмный / 30% фиолетовый) ]]
local Theme = {
    MainBg = Color3.fromRGB(20, 20, 25),      -- Глубокий чёрно-серый
    SearchBarBg = Color3.fromRGB(30, 30, 38), -- Чуть светлее для выделения элементов
    Accent = Color3.fromRGB(138, 43, 226),    -- Насыщенный фиолетовый (Purple Accent)
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 190)
}

-- [[ Сервисы ]]
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- [[ Инициализация UI ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomLibraryUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Главный контейнер (Поисковая строка / Топ-бар)
local SearchBar = Instance.new("Frame")
SearchBar.Name = "SearchBar"
SearchBar.Size = UDim2.new(0, 350, 0, 45)
SearchBar.Position = UDim2.new(0.5, -175, 0.3, 0) -- По центру экрана изначально
SearchBar.BackgroundColor3 = Theme.MainBg
SearchBar.BorderSizePixel = 0
SearchBar.Parent = ScreenGui

-- Скругление углов для главного бара
local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 8)
MainUICorner.Parent = SearchBar

-- Фиолетовая обводка (Акцент)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Theme.Accent
UIStroke.Thickness = 1.5
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = SearchBar

-- Контейнер для самого ввода текста
local InputFrame = Instance.new("Frame")
InputFrame.Name = "InputFrame"
InputFrame.Size = UDim2.new(1, -20, 1, -14)
InputFrame.Position = UDim2.new(0, 10, 0, 7)
InputFrame.BackgroundColor3 = Theme.SearchBarBg
InputFrame.BorderSizePixel = 0
InputFrame.Parent = SearchBar

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = InputFrame

-- Поле ввода текста
local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -30, 1, 0)
TextBox.Position = UDim2.new(0, 10, 0, 0)
TextBox.BackgroundTransparency = 1
TextBox.Font = Enum.Font.GothamBold
TextBox.Text = ""
TextBox.PlaceholderText = "Search features..."
TextBox.PlaceholderColor3 = Theme.TextSecondary
TextBox.TextColor3 = Theme.TextPrimary
TextBox.TextSize = 14
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.Parent = InputFrame

-- Иконка поиска (просто текстовый символ для минимализма)
local SearchIcon = Instance.new("TextLabel")
SearchIcon.Size = UDim2.new(0, 20, 1, 0)
SearchIcon.Position = UDim2.new(1, -25, 0, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Font = Enum.Font.GothamBold
SearchIcon.Text = "🔍"
SearchIcon.TextColor3 = Theme.Accent
SearchIcon.TextSize = 14
SearchIcon.Parent = InputFrame

-- ----------------------------------------------------
-- [[ Логика перетаскивания (Drag & Drop) ]]
-- ----------------------------------------------------
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    -- Плавное перемещение через Tween
    local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(SearchBar, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
end

SearchBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = SearchBar.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

SearchBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- ----------------------------------------------------
-- [[ Логика скрытия меню на Right Shift ]]
-- ----------------------------------------------------
local uiVisible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Не скрываем, если игрок в этот момент пишет в чат или в наш же поиск
    if gameProcessed then return end 
    
    if input.KeyCode == Enum.Enum.KeyCode.RightShift then
        uiVisible = not uiVisible
        ScreenGui.Enabled = uiVisible
    end
end)

-- [[ Пример вывода поиска в консоль ]]
TextBox:GetPropertyChangedSignal("Text"):Connect(function()
    print("Ищем:", TextBox.Text)
    -- Сюда позже добавим фильтрацию кнопок/функций
end)
