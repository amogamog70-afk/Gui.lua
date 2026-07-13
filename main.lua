-- [[ METEOR ADVANCED PIXEL-PERFECT UI ENGINE (MINECRAFT CLICK-GUI STYLE) ]]
-- Разработано специально для воссоздания стиля Meteor / Wish / Wurst Client в Roblox.
-- Все углы острые (0px), шрифты моноширинные, добавлены продвинутые пиксельные элементы.

local Theme = {
MainBg = Color3.fromRGB(11, 11, 15),          -- Ультра-тёмный фон плашки
ElementBg = Color3.fromRGB(18, 18, 24),       -- Базовый фон кнопок
ElementHover = Color3.fromRGB(26, 26, 36),    -- Цвет при наведении
PopupBg = Color3.fromRGB(14, 14, 20),         -- Фон выпадающих менюшек
Accent = Color3.fromRGB(0, 102, 255),         -- Классический синий клик-гуи (из скриншота) или твой розовый: Color3.fromRGB(218, 43, 172)
AccentHover = Color3.fromRGB(0, 140, 255),
TextPrimary = Color3.fromRGB(255, 255, 255),
TextSecondary = Color3.fromRGB(150, 150, 160),
Border = Color3.fromRGB(35, 35, 45),          -- Четкая рамка
Font = Enum.Font.Code                         -- Идеальный пиксельный/хакерский шрифт
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Инициализация GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeteorPremiumGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Папка для оверлеев (Dropdown / ColorPicker)
local PopupsFolder = Instance.new("Folder")
PopupsFolder.Name = "ActivePopups"
PopupsFolder.Parent = ScreenGui

local function CloseAllPopups()
PopupsFolder:ClearAllChildren()
end

-- Функция создания жесткой пиксельной обводки
local function AddPixelBorder(parent, color, thickness)
local Stroke = Instance.new("UIStroke")
Stroke.Color = color or Theme.Border
Stroke.Thickness = thickness or 1
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.LineJoinMode = Enum.LineJoinMode.Miter -- Делает углы обводки идеально острыми
Stroke.Parent = parent
return Stroke
end

-- Функция перетаскивания (Drag & Drop) для главного окна
local function MakeDraggable(dragFrame, parentFrame)
local dragging = false
local dragInput, dragStart, startPos

dragFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = parentFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

dragFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        parentFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)


end

-- 1. ГЛАВНЫЙ ТОП-BAR (Y = 0)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0, 520, 0, 36)
TopBar.Position = UDim2.new(0.5, -260, 0.15, 0) -- Чуть ниже верха для удобства теста
TopBar.BackgroundColor3 = Theme.MainBg
TopBar.BorderSizePixel = 0
TopBar.Parent = ScreenGui

AddPixelBorder(TopBar, Theme.Border, 1)
MakeDraggable(TopBar, TopBar)

-- Синяя/розовая неоновая линия на нижней границе
local BottomLine = Instance.new("Frame")
BottomLine.Size = UDim2.new(1, 0, 0, 2)
BottomLine.Position = UDim2.new(0, 0, 1, -2)
BottomLine.BackgroundColor3 = Theme.Accent
BottomLine.BorderSizePixel = 0
BottomLine.Parent = TopBar

-- Контейнер для вкладок
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 340, 1, -2)
TabContainer.Position = UDim2.new(0, 12, 0, 0)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = TopBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 14)
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Parent = TabContainer

-- Контейнер Поиска
local SearchContainer = Instance.new("Frame")
SearchContainer.Size = UDim2.new(0, 135, 0, 22)
SearchContainer.Position = UDim2.new(1, -147, 0.5, -11)
SearchContainer.BackgroundColor3 = Theme.ElementBg
SearchContainer.BorderSizePixel = 0
SearchContainer.Parent = TopBar

AddPixelBorder(SearchContainer, Theme.Border, 1)

local SearchInput = Instance.new("TextBox")
SearchInput.Size = UDim2.new(1, -24, 1, 0)
SearchInput.Position = UDim2.new(0, 6, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.Font = Theme.Font
SearchInput.Text = ""
SearchInput.PlaceholderText = "Search.."
SearchInput.PlaceholderColor3 = Theme.TextSecondary
SearchInput.TextColor3 = Theme.TextPrimary
SearchInput.TextSize = 11
SearchInput.TextXAlignment = Enum.TextXAlignment.Left
SearchInput.Parent = SearchContainer

local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Name = "SearchIcon"
SearchIcon.Size = UDim2.new(0, 14, 0, 14)
SearchIcon.Position = UDim2.new(1, -20, 0.5, -7)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Image = "rbxassetid://118685771787843"
SearchIcon.ImageColor3 = Theme.Accent
SearchIcon.Parent = SearchContainer

-- 2. СРЕДНИЙ КОНТЕЙНЕР (Прижат к топ-бару, без зазоров)
local ContainerFrame = Instance.new("Frame")
ContainerFrame.Size = UDim2.new(1, 0, 0, 220) -- Слегка увеличили высоту для новых крутых элементов
ContainerFrame.Position = UDim2.new(0, 0, 1, 0)
ContainerFrame.BackgroundColor3 = Theme.MainBg
ContainerFrame.BorderSizePixel = 0
ContainerFrame.Parent = TopBar

AddPixelBorder(ContainerFrame, Theme.Border, 1)

-- Дополнительная тонкая полоса сбоку для премиум-вида
local LeftLine = Instance.new("Frame")
LeftLine.Size = UDim2.new(0, 2, 1, 0)
LeftLine.Position = UDim2.new(0, 0, 0, 0)
LeftLine.BackgroundColor3 = Theme.Accent
LeftLine.BorderSizePixel = 0
LeftLine.Parent = ContainerFrame

local Pages = {}
local AllElements = {}
local FirstPage = nil
local Library = {}

function Library:CreateTab(name)
local Page = Instance.new("ScrollingFrame")
Page.Name = name .. "Page"
Page.Size = UDim2.new(1, -12, 1, -12)
Page.Position = UDim2.new(0, 6, 0, 6)
Page.BackgroundTransparency = 1
Page.Visible = false
Page.ScrollBarThickness = 3
Page.ScrollBarImageColor3 = Theme.Accent
Page.ScrollBarImageTransparency = 0
Page.BorderSizePixel = 0
Page.CanvasSize = UDim2.new(0, 0, 0, 0)
Page.Parent = ContainerFrame

local PageGrid = Instance.new("UIGridLayout")
PageGrid.CellSize = UDim2.new(0, 156, 0, 42) -- Высота 42px идеально подходит для новых макетов слайдеров
PageGrid.CellPadding = UDim2.new(0, 12, 0, 10)
PageGrid.SortOrder = Enum.SortOrder.LayoutOrder
PageGrid.Parent = Page

PageGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Page.CanvasSize = UDim2.new(0, 0, 0, PageGrid.AbsoluteContentSize.Y + 10)
end)

-- Кнопка вкладки
local TabButton = Instance.new("TextButton")
TabButton.Name = name .. "Tab"
TabButton.Size = UDim2.new(0, 65, 0, 24)
TabButton.BackgroundTransparency = 1
TabButton.Font = Theme.Font
TabButton.Text = "[" .. name .. "]"
TabButton.TextColor3 = Theme.TextSecondary
TabButton.TextSize = 12
TabButton.Parent = TabContainer

TabButton.MouseEnter:Connect(function()
    if not Page.Visible then TabButton.TextColor3 = Theme.TextPrimary end
end)
TabButton.MouseLeave:Connect(function()
    if not Page.Visible then TabButton.TextColor3 = Theme.TextSecondary end
end)

local function Activate()
    CloseAllPopups()
    for _, p in pairs(Pages) do p.Visible = false end
    for _, btn in pairs(TabContainer:GetChildren()) do
        if btn:IsA("TextButton") then 
            btn.TextColor3 = Theme.TextSecondary 
            btn.Text = "[" .. btn.Name:gsub("Tab", "") .. "]"
        end
    end
    Page.Visible = true
    TabButton.TextColor3 = Theme.Accent
    TabButton.Text = "> " .. name .. " <"
end

TabButton.MouseButton1Click:Connect(Activate)
if not FirstPage then FirstPage = Activate end
Pages[name] = Page

local Elements = {}

local function ApplyButtonEffects(button)
    button.MouseEnter:Connect(function() button.BackgroundColor3 = Theme.ElementHover end)
    button.MouseLeave:Connect(function() button.BackgroundColor3 = Theme.ElementBg end)
end

-- [[ 1. КНОПКА (PIXEL STYLE) ]]
function Elements:CreateButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundColor3 = Theme.ElementBg
    Button.Font = Theme.Font
    Button.Text = text
    Button.TextColor3 = Theme.TextPrimary
    Button.TextSize = 11
    Button.Parent = Page
    
    AddPixelBorder(Button, Theme.Border, 1)
    ApplyButtonEffects(Button)

    Button.MouseButton1Click:Connect(function() 
        CloseAllPopups() 
        Button.BackgroundColor3 = Theme.Accent
        task.wait(0.08)
        Button.BackgroundColor3 = Theme.ElementHover
        pcall(callback) 
    end)
    table.insert(AllElements, {Instance = Button, Name = text:lower(), PageActivate = Activate})
end

-- [[ 2. ПЕРЕКЛЮЧАТЕЛЬ (TOGGLE) ]]
function Elements:CreateToggle(text, default, callback)
    local state = default or false
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1, 0, 1, 0)
    Toggle.BackgroundColor3 = Theme.ElementBg
    Toggle.Font = Theme.Font
    Toggle.Text = "  " .. text
    Toggle.TextColor3 = Theme.TextPrimary
    Toggle.TextSize = 11
    Toggle.TextXAlignment = Enum.TextXAlignment.Left
    Toggle.Parent = Page
    
    AddPixelBorder(Toggle, Theme.Border, 1)
    ApplyButtonEffects(Toggle)

    -- Квадратный майнкрафт-индикатор
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 12, 0, 12)
    Indicator.Position = UDim2.new(1, -18, 0.5, -6)
    Indicator.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(30, 30, 40)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Toggle
    AddPixelBorder(Indicator, Theme.Border, 1)

    Toggle.MouseButton1Click:Connect(function()
        CloseAllPopups()
        state = not state
        Indicator.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(30, 30, 40)
        pcall(callback, state)
    end)
    table.insert(AllElements, {Instance = Toggle, Name = text:lower(), PageActivate = Activate})
end

-- [[ 3. СЛАЙДЕР С ТРЕУГОЛЬНИКОМ (ИЗ image_45e6c5.png) ]]
function Elements:CreateSlider(text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = Page

    -- Название над слайдером
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 14)
    Title.Position = UDim2.new(0, 2, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Theme.Font
    Title.Text = text
    Title.TextColor3 = Theme.TextPrimary
    Title.TextSize = 11
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = SliderFrame

    -- Трек слайдера (серая полоса)
    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(1, -4, 0, 16)
    Track.Position = UDim2.new(0, 2, 0, 18)
    Track.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    Track.BorderSizePixel = 0
    Track.Text = ""
    Track.AutoButtonColor = false
    Track.Parent = SliderFrame
    AddPixelBorder(Track, Theme.Border, 1)

    -- Заполнение слайдера (синяя/розовая полоса)
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track

    -- Текстовое значение по центру поверх слайдера (формат "3/5" или просто число)
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(1, 0, 1, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Font = Theme.Font
    ValueLabel.Text = tostring(default) .. " / " .. tostring(max)
    ValueLabel.TextColor3 = Theme.TextPrimary
    ValueLabel.TextSize = 11
    ValueLabel.ZIndex = 3
    ValueLabel.Parent = Track

    -- Синий треугольный курсор-указатель (направлен вниз ▼)
    local Pointer = Instance.new("TextLabel")
    Pointer.Size = UDim2.new(0, 12, 0, 12)
    -- Позиционируем на границе заполнения
    Pointer.Position = UDim2.new(Fill.Size.X.Scale, 0, 0, -6)
    Pointer.AnchorPoint = Vector2.new(0.5, 0)
    Pointer.BackgroundTransparency = 1
    Pointer.Font = Theme.Font
    Pointer.Text = "▼"
    Pointer.TextColor3 = Theme.Accent
    Pointer.TextSize = 14
    Pointer.ZIndex = 4
    Pointer.Parent = Track

    local isSliding = false
    local function update(input)
        local progress = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local rawVal = min + (max - min) * progress
        local val = math.floor(rawVal) -- можно сделать float, если нужно

        ValueLabel.Text = tostring(val) .. " / " .. tostring(max)
        Fill.Size = UDim2.new(progress, 0, 1, 0)
        Pointer.Position = UDim2.new(progress, 0, 0, -6)
        pcall(callback, val)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            CloseAllPopups()
            isSliding = true
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isSliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    table.insert(AllElements, {Instance = SliderFrame, Name = text:lower(), PageActivate = Activate})
end

-- [[ 4. ТЕКСТ БОКС (PIXEL STYLE) ]]
function Elements:CreateTextBox(placeholder, callback)
    local BoxFrame = Instance.new("Frame")
    BoxFrame.BackgroundColor3 = Theme.ElementBg
    BoxFrame.Parent = Page
    
    local BorderStroke = AddPixelBorder(BoxFrame, Theme.Border, 1)

    local BoxInput = Instance.new("TextBox")
    BoxInput.Size = UDim2.new(1, -12, 1, 0)
    BoxInput.Position = UDim2.new(0, 6, 0, 0)
    BoxInput.BackgroundTransparency = 1
    BoxInput.Font = Theme.Font
    BoxInput.PlaceholderText = placeholder
    BoxInput.PlaceholderColor3 = Theme.TextSecondary
    BoxInput.TextColor3 = Theme.TextPrimary
    BoxInput.TextSize = 11
    BoxInput.Parent = BoxFrame

    BoxInput.Focused:Connect(function()
        BorderStroke.Color = Theme.Accent -- Подсвечиваем рамку при наведении фокуса
    end)

    BoxInput.FocusLost:Connect(function(enterPressed)
        BorderStroke.Color = Theme.Border
        pcall(callback, BoxInput.Text, enterPressed)
    end)
    table.insert(AllElements, {Instance = BoxFrame, Name = placeholder:lower(), PageActivate = Activate})
end

-- [[ 5. СОВРЕМЕННЫЙ DROPDOWN (ОПЦИИ ИЗ МАЙНКРАФТ-КЛИЕНТОВ) ]]
function Elements:CreateDropdown(text, list, callback)
    local Dropdown = Instance.new("TextButton")
    Dropdown.Size = UDim2.new(1, 0, 1, 0)
    Dropdown.BackgroundColor3 = Theme.ElementBg
    Dropdown.Font = Theme.Font
    Dropdown.Text = "  " .. text .. "  [+]"
    Dropdown.TextColor3 = Theme.TextPrimary
    Dropdown.TextSize = 11
    Dropdown.TextXAlignment = Enum.TextXAlignment.Left
    Dropdown.Parent = Page
    
    AddPixelBorder(Dropdown, Theme.Border, 1)
    ApplyButtonEffects(Dropdown)

    Dropdown.MouseButton1Click:Connect(function()
        local alreadyOpen = PopupsFolder:FindFirstChild(text .. "Drop")
        CloseAllPopups()
        if alreadyOpen then return end

        local DropMenu = Instance.new("Frame")
        DropMenu.Name = text .. "Drop"
        DropMenu.Size = UDim2.new(0, Dropdown.AbsoluteSize.X, 0, math.clamp(#list * 24, 24, 120))
        DropMenu.Position = UDim2.new(0, Dropdown.AbsolutePosition.X, 0, Dropdown.AbsolutePosition.Y + Dropdown.AbsoluteSize.Y)
        DropMenu.BackgroundColor3 = Theme.PopupBg
        DropMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        DropMenu.Parent = PopupsFolder
        
        AddPixelBorder(DropMenu, Theme.Accent, 1)

        local Scroll = Instance.new("ScrollingFrame", DropMenu)
        Scroll.Size = UDim2.new(1, 0, 1, 0)
        Scroll.BackgroundTransparency = 1
        Scroll.CanvasSize = UDim2.new(0, 0, 0, #list * 24)
        Scroll.ScrollBarThickness = 2
        Scroll.ScrollBarImageColor3 = Theme.Accent

        local ListLayout = Instance.new("UIListLayout", Scroll)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

        for _, option in pairs(list) do
            local OptBtn = Instance.new("TextButton", Scroll)
            OptBtn.Size = UDim2.new(1, 0, 0, 24)
            OptBtn.BackgroundColor3 = Theme.PopupBg
            OptBtn.BorderSizePixel = 0
            OptBtn.Font = Theme.Font
            OptBtn.Text = tostring(option)
            OptBtn.TextColor3 = Theme.TextSecondary
            OptBtn.TextSize = 11

            OptBtn.MouseEnter:Connect(function() 
                OptBtn.TextColor3 = Theme.TextPrimary 
                OptBtn.BackgroundColor3 = Theme.ElementBg
            end)
            OptBtn.MouseLeave:Connect(function() 
                OptBtn.TextColor3 = Theme.TextSecondary 
                OptBtn.BackgroundColor3 = Theme.PopupBg
            end)

            OptBtn.MouseButton1Click:Connect(function()
                Dropdown.Text = "  " .. text .. ": " .. tostring(option)
                CloseAllPopups()
                pcall(callback, option)
            end)
        end
    end)
    table.insert(AllElements, {Instance = Dropdown, Name = text:lower(), PageActivate = Activate})
end

-- [[ 6. ПИКСЕЛЬНЫЙ COLOR PICKER (КОПИЯ С image_45e6a1.png) ]]
function Elements:CreateColorPicker(text, defaultColor, callback)
    local Picker = Instance.new("TextButton")
    Picker.BackgroundColor3 = Theme.ElementBg
    Picker.Font = Theme.Font
    Picker.Text = "  " .. text
    Picker.TextColor3 = Theme.TextPrimary
    Picker.TextSize = 11
    Picker.TextXAlignment = Enum.TextXAlignment.Left
    Picker.Parent = Page
    
    AddPixelBorder(Picker, Theme.Border, 1)
    ApplyButtonEffects(Picker)

    -- Цветной квадрат-превью на кнопке пикера
    local ColorBox = Instance.new("Frame")
    ColorBox.Size = UDim2.new(0, 16, 0, 16)
    ColorBox.Position = UDim2.new(1, -22, 0.5, -8)
    ColorBox.BackgroundColor3 = defaultColor
    ColorBox.BorderSizePixel = 0
    ColorBox.Parent = Picker
    AddPixelBorder(ColorBox, Theme.Border, 1)

    local currentH, currentS, currentV = Color3.toHSV(defaultColor)
    local currentA = 1 -- Альфа (прозрачность)

    Picker.MouseButton1Click:Connect(function()
        local alreadyOpen = PopupsFolder:FindFirstChild(text .. "Picker")
        CloseAllPopups()
        if alreadyOpen then return end

        -- Панель самого Пикера (Ширина 190, Высота 220)
        local PickerMenu = Instance.new("Frame")
        PickerMenu.Name = text .. "Picker"
        PickerMenu.Size = UDim2.new(0, 195, 0, 225)
        PickerMenu.Position = UDim2.new(0, Picker.AbsolutePosition.X, 0, Picker.AbsolutePosition.Y + Picker.AbsoluteSize.Y)
        PickerMenu.BackgroundColor3 = Theme.PopupBg
        PickerMenu.Parent = PopupsFolder
        AddPixelBorder(PickerMenu, Theme.Accent, 1)

        -- Заголовок внутри меню пикера
        local PickerTitle = Instance.new("TextLabel")
        PickerTitle.Size = UDim2.new(1, -10, 0, 20)
        PickerTitle.Position = UDim2.new(0, 8, 0, 4)
        PickerTitle.BackgroundTransparency = 1
        PickerTitle.Font = Theme.Font
        PickerTitle.Text = text
        PickerTitle.TextColor3 = Theme.TextPrimary
        PickerTitle.TextSize = 11
        PickerTitle.TextXAlignment = Enum.TextXAlignment.Left
        PickerTitle.Parent = PickerMenu

        -- 1. SV BOX (Поле выбора Насыщенности и Яркости)
        local SVBox = Instance.new("TextButton")
        SVBox.Size = UDim2.new(0, 150, 0, 120)
        SVBox.Position = UDim2.new(0, 8, 0, 24)
        SVBox.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1) -- Базовый цвет Hue
        SVBox.BorderSizePixel = 0
        SVBox.Text = ""
        SVBox.AutoButtonColor = false
        SVBox.Parent = PickerMenu
        AddPixelBorder(SVBox, Theme.Border, 1)

        -- Горизонтальный градиент: Белый -> Прозрачный (для Насыщенности)
        local SatGradient = Instance.new("Frame")
        SatGradient.Size = UDim2.new(1, 0, 1, 0)
        SatGradient.BackgroundTransparency = 0
        SatGradient.BorderSizePixel = 0
        SatGradient.Parent = SVBox

        local SatUIGradient = Instance.new("UIGradient")
        SatUIGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        })
        SatUIGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        SatUIGradient.Parent = SatGradient

        -- Вертикальный градиент: Прозрачный -> Чёрный (для Яркости)
        local ValGradient = Instance.new("Frame")
        ValGradient.Size = UDim2.new(1, 0, 1, 0)
        ValGradient.BorderSizePixel = 0
        ValGradient.Parent = SVBox

        local ValUIGradient = Instance.new("UIGradient")
        ValUIGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
        })
        ValUIGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        })
        ValUIGradient.Rotation = 90
        ValUIGradient.Parent = ValGradient

        -- Точка-курсор на поле SV
        local SVCursor = Instance.new("Frame")
        SVCursor.Size = UDim2.new(0, 4, 0, 4)
        SVCursor.Position = UDim2.new(currentS, -2, 1 - currentV, -2)
        SVCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        SVCursor.BorderSizePixel = 0
        SVCursor.Parent = SVBox
        AddPixelBorder(SVCursor, Color3.new(0, 0, 0), 1)

        -- 2. HUE SLIDER (Вертикальная радужная полоска справа)
        local HueSlider = Instance.new("TextButton")
        HueSlider.Size = UDim2.new(0, 18, 0, 120)
        HueSlider.Position = UDim2.new(0, 168, 0, 24)
        HueSlider.BorderSizePixel = 0
        HueSlider.Text = ""
        HueSlider.AutoButtonColor = false
        HueSlider.Parent = PickerMenu
        AddPixelBorder(HueSlider, Theme.Border, 1)

        local HueGradient = Instance.new("UIGradient")
        HueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
        HueGradient.Rotation = 90
        HueGradient.Parent = HueSlider

        -- Линейный указатель на Hue-слайдере
        local HueCursor = Instance.new("Frame")
        HueCursor.Size = UDim2.new(1, 4, 0, 2)
        HueCursor.Position = UDim2.new(0, -2, currentH, -1)
        HueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        HueCursor.BorderSizePixel = 0
        HueCursor.Parent = HueSlider
        AddPixelBorder(HueCursor, Color3.new(0, 0, 0), 1)

        -- Поля вывода внизу пикера (Hex & RGB)
        local HexInput = Instance.new("TextBox")
        HexInput.Size = UDim2.new(0, 75, 0, 22)
        HexInput.Position = UDim2.new(0, 8, 0, 152)
        HexInput.BackgroundColor3 = Theme.ElementBg
        HexInput.Font = Theme.Font
        HexInput.Text = ""
        HexInput.PlaceholderText = "#Hex"
        HexInput.TextColor3 = Theme.TextPrimary
        HexInput.TextSize = 10
        HexInput.Parent = PickerMenu
        AddPixelBorder(HexInput, Theme.Border, 1)

        local RGBInput = Instance.new("TextBox")
        RGBInput.Size = UDim2.new(0, 95, 0, 22)
        RGBInput.Position = UDim2.new(0, 91, 0, 152)
        RGBInput.BackgroundColor3 = Theme.ElementBg
        RGBInput.Font = Theme.Font
        RGBInput.Text = ""
        RGBInput.PlaceholderText = "R, G, B"
        RGBInput.TextColor3 = Theme.TextPrimary
        RGBInput.TextSize = 10
        RGBInput.Parent = PickerMenu
        AddPixelBorder(RGBInput, Theme.Border, 1)

        -- 3. ALPHA SLIDER (Слайдер прозрачности в самом низу)
        local AlphaSlider = Instance.new("TextButton")
        AlphaSlider.Size = UDim2.new(0, 178, 0, 14)
        AlphaSlider.Position = UDim2.new(0, 8, 0, 182)
        AlphaSlider.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        AlphaSlider.BorderSizePixel = 0
        AlphaSlider.Text = ""
        AlphaSlider.AutoButtonColor = false
        AlphaSlider.Parent = PickerMenu
        AddPixelBorder(AlphaSlider, Theme.Border, 1)

        -- Текстура шахматной доски для симуляции прозрачности (сделаем градиентом от цвета к прозрачному)
        local AlphaFill = Instance.new("Frame")
        AlphaFill.Size = UDim2.new(1, 0, 1, 0)
        AlphaFill.BorderSizePixel = 0
        AlphaFill.Parent = AlphaSlider

        local AlphaUIGradient = Instance.new("UIGradient")
        AlphaUIGradient.Color = ColorSequence.new(defaultColor)
        AlphaUIGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0), -- плотный цвет
            NumberSequenceKeypoint.new(1, 1)  -- прозрачный
        })
        AlphaUIGradient.Parent = AlphaFill

        local AlphaCursor = Instance.new("Frame")
        AlphaCursor.Size = UDim2.new(0, 4, 1, 4)
        AlphaCursor.Position = UDim2.new(1 - currentA, -2, 0, -2)
        AlphaCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        AlphaCursor.BorderSizePixel = 0
        AlphaCursor.Parent = AlphaSlider
        AddPixelBorder(AlphaCursor, Color3.new(0, 0, 0), 1)

        -- Вспомогательные функции обновления
        local function UpdateColor(fromInputs)
            local mainColor = Color3.fromHSV(currentH, currentS, currentV)
            ColorBox.BackgroundColor3 = mainColor
            SVBox.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
            AlphaUIGradient.Color = ColorSequence.new(mainColor)

            -- Обновление текстовых полей (если обновление не от ввода пользователя)
            if not fromInputs then
                local r = math.round(mainColor.R * 255)
                local g = math.round(mainColor.G * 255)
                local b = math.round(mainColor.B * 255)
                HexInput.Text = string.format("#%02x%02x%02x", r, g, b)
                RGBInput.Text = string.format("%d, %d, %d", r, g, b)
            end

            pcall(callback, mainColor, currentA)
        end

        -- Первичная инициализация текстов
        UpdateColor(false)

        -- Логика движения по SV Box
        local draggingSV = false
        local function updateSV(input)
            local progressX = math.clamp((input.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
            local progressY = math.clamp((input.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)

            currentS = progressX
            currentV = 1 - progressY

            SVCursor.Position = UDim2.new(progressX, -2, progressY, -2)
            UpdateColor(false)
        end

        SVBox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true updateSV(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingSV and input.UserInputType == Enum.UserInputType.MouseMovement then updateSV(input) end
        end)

        -- Логика движения по Hue Slider
        local draggingHue = false
        local function updateHue(input)
            local progressY = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
            currentH = progressY

            HueCursor.Position = UDim2.new(0, -2, progressY, -1)
            UpdateColor(false)
        end

        HueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true updateHue(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then updateHue(input) end
        end)

        -- Логика движения по Alpha Slider
        local draggingAlpha = false
        local function updateAlpha(input)
            local progressX = math.clamp((input.Position.X - AlphaSlider.AbsolutePosition.X) / AlphaSlider.AbsoluteSize.X, 0, 1)
            currentA = 1 - progressX

            AlphaCursor.Position = UDim2.new(progressX, -2, 0, -2)
            UpdateColor(false)
        end

        AlphaSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingAlpha = true updateAlpha(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingAlpha = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingAlpha and input.UserInputType == Enum.UserInputType.MouseMovement then updateAlpha(input) end
        end)

        -- Обработка ручного ввода в HexInput
        HexInput.FocusLost:Connect(function()
            local textHex = HexInput.Text:gsub("#", "")
            if #textHex == 6 then
                local r = tonumber(textHex:sub(1, 2), 16)
                local g = tonumber(textHex:sub(3, 4), 16)
                local b = tonumber(textHex:sub(5, 6), 16)
                if r and g and b then
                    local col = Color3.fromRGB(r, g, b)
                    currentH, currentS, currentV = Color3.toHSV(col)
                    
                    -- Перемещаем курсоры
                    SVCursor.Position = UDim2.new(currentS, -2, 1 - currentV, -2)
                    HueCursor.Position = UDim2.new(0, -2, currentH, -1)
                    UpdateColor(true)
                end
            end
        end)

        -- Обработка ручного ввода в RGBInput
        RGBInput.FocusLost:Connect(function()
            local r, g, b = RGBInput.Text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
            r, g, b = tonumber(r), tonumber(g), tonumber(b)
            if r and g and b then
                local col = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
                currentH, currentS, currentV = Color3.toHSV(col)

                -- Перемещаем курсоры
                SVCursor.Position = UDim2.new(currentS, -2, 1 - currentV, -2)
                HueCursor.Position = UDim2.new(0, -2, currentH, -1)
                UpdateColor(true)
            end
        end)
    end)

    table.insert(AllElements, {Instance = Picker, Name = text:lower(), PageActivate = Activate})
end

return Elements


end

-- Скрытие/Показ GUI на клавишу Right Shift
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == Enum.KeyCode.RightShift then
uiVisible = not uiVisible
TopBar.Visible = uiVisible
if not uiVisible then CloseAllPopups() end
end
end)

-- Умная система поиска элементов
SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
local query = SearchInput.Text:lower()
CloseAllPopups()
for _, elem in pairs(AllElements) do
if query == "" then
elem.Instance.Visible = true
else
if string.find(elem.Name, query) then
elem.Instance.Visible = true
elem.PageActivate()
else
elem.Instance.Visible = false
end
end
end
end)

task.spawn(function()
repeat task.wait() until FirstPage
FirstPage()
end)

return Library
