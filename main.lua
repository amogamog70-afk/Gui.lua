-- =====================================================
-- METEOR UI LIBRARY - ROBLOX GUI FRAMEWORK
-- Современная библиотека GUI в стиле Meteor Client
-- =====================================================

local MeteorUI = {}
MeteorUI.__index = MeteorUI
MeteorUI.Version = "1.0.0"

-- =====================================================
-- НАСТРОЙКИ И КОНСТАНТЫ
-- =====================================================

MeteorUI.Settings = {
    -- Цветовая схема
    AccentColor = Color3.fromRGB(120, 120, 255),
    BackgroundColor = Color3.fromRGB(20, 20, 25),
    SurfaceColor = Color3.fromRGB(30, 30, 35),
    BorderColor = Color3.fromRGB(50, 50, 60),
    TextColor = Color3.fromRGB(240, 240, 245),
    TextSecondaryColor = Color3.fromRGB(180, 180, 190),
    
    -- Размеры
    TopBarHeight = 45,
    SearchBarWidth = 250,
    TabHeight = 40,
    CornerRadius = 8,
    Padding = 10,
    
    -- Анимации
    AnimationSpeed = 0.25,
    HoverAnimationSpeed = 0.15,
    RippleAnimationSpeed = 0.4,
    
    -- Эффекты
    BlurEnabled = true,
    AcrylicEnabled = true,
    RippleEnabled = true,
    
    -- Поведение
    DragEnabled = true,
    ResizeEnabled = false,
    AutoSave = true,
    AutoSaveInterval = 30,
}

-- =====================================================
-- CORE MANAGERS
-- =====================================================

MeteorUI.ThemeManager = {}
MeteorUI.AnimationManager = {}
MeteorUI.ConfigManager = {}
MeteorUI.IconManager = {}
MeteorUI.NotificationQueue = {}

-- =====================================================
-- ICON MANAGER - МЕНЕДЖЕР ИКОНОК
-- =====================================================

MeteorUI.Icons = {
    -- Главное меню
    Settings = "rbxassetid://103884184213243",
    
    -- Логотип проекта
    VoltEclipse = "rbxassetid://7015953925",
    
    -- Поисковая строка
    Search = "rbxassetid://118685771787843",
    
    -- Конфиги
    Configs = "rbxassetid://9940320722",
    
    -- Темы
    Theme = "rbxassetid://10190648035",
}

function MeteorUI.IconManager:CreateIcon(parent, iconId, size, position)
    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.BackgroundTransparency = 1
    Icon.Position = position or UDim2.new(0, 0, 0, 0)
    Icon.Size = size or UDim2.new(0, 20, 0, 20)
    Icon.Image = iconId
    Icon.ImageColor3 = MeteorUI.Settings.TextColor
    Icon.ScaleType = Enum.ScaleType.Fit
    Icon.Parent = parent
    return Icon
end

function MeteorUI.IconManager:SetIconColor(icon, color)
    if icon and icon:IsA("ImageLabel") then
        icon.ImageColor3 = color
    end
end

-- =====================================================
-- АРХИТЕКТУРА КОМПОНЕНТОВ
-- =====================================================

-- ОСНОВНЫЕ КОНТЕЙНЕРЫ
MeteorUI.Components = {
    Window = {},      -- Главное окно приложения
    Tab = {},         -- Вкладка в верхней панели
    GroupBox = {},    -- Группа элементов
    Section = {},     -- Секция внутри GroupBox
}

-- ЭЛЕМЕНТЫ ВВОДА
MeteorUI.Inputs = {
    Button = {},           -- Кнопка
    Toggle = {},           -- Переключатель
    Slider = {},           -- Слайдер
    TextBox = {},          -- Текстовое поле
    NumberInput = {},      -- Числовой ввод
    Dropdown = {},         -- Выпадающий список
    SearchableDropdown = {}, -- Выпадающий список с поиском
    MultiDropdown = {},    -- Множественный выбор
    ColorPicker = {},      -- Выбор цвета
    Keybind = {},          -- Привязка клавиш
    Checkbox = {},         -- Чекбокс
    RadioButton = {},      -- Радио кнопка
}

-- ЭЛЕМЕНТЫ ОТОБРАЖЕНИЯ
MeteorUI.Display = {
    Label = {},        -- Текстовая метка
    Paragraph = {},    -- Параграф текста
    Separator = {},    -- Разделитель
    ProgressBar = {},  -- Прогресс бар
    Image = {},        -- Изображение
    Icon = {},         -- Иконка
    FPSCounter = {},   -- Счетчик FPS
    Watermark = {},    -- Водяной знак
}

-- UI СИСТЕМЫ
MeteorUI.Systems = {
    SearchBar = {},        -- Поисковая строка
    GlobalSearch = {},     -- Глобальный поиск
    Tooltip = {},          -- Всплывающая подсказка
    ContextMenu = {},      -- Контекстное меню
    Notification = {},     -- Уведомление
    LoadingScreen = {},    -- Экран загрузки
    SplashScreen = {},     -- Заставка
    DiscordPopup = {},     -- Discord всплывающее окно
}

-- =====================================================
-- WINDOW - ГЛАВНОЕ ОКНО
-- =====================================================

function MeteorUI:CreateWindow(config)
    config = config or {}
    
    local Window = {
        Title = config.Title or "Meteor UI",
        Visible = true,
        Minimized = false,
        Position = config.Position or UDim2.new(0.5, -300, 0.5, -250),
        Size = config.Size or UDim2.new(0, 600, 0, 500),
        Tabs = {},
        CurrentTab = nil,
        ScreenGui = nil,
        MainFrame = nil,
        TopBar = nil,
        SearchBar = nil,
        TabContainer = nil,
        ContentContainer = nil,
    }
    
    function Window:Initialize()
        -- Создание ScreenGui
        self.ScreenGui = Instance.new("ScreenGui")
        self.ScreenGui.Name = "MeteorUI"
        self.ScreenGui.ResetOnSpawn = false
        self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        self.ScreenGui.Parent = game:GetService("CoreGui")

        -- Blur эффект
        if MeteorUI.Settings.BlurEnabled then
            local Blur = Instance.new("BlurEffect")
            Blur.Size = 10
            Blur.Parent = game:GetService("Lighting")
        end
        
        -- Главный фрейм
        self.MainFrame = Instance.new("Frame")
        self.MainFrame.Name = "MainFrame"
        self.MainFrame.BackgroundColor3 = MeteorUI.Settings.BackgroundColor
        self.MainFrame.BorderSizePixel = 0
        self.MainFrame.Position = self.Position
        self.MainFrame.Size = self.Size
        self.MainFrame.Parent = self.ScreenGui
        
        -- Скругление углов
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, MeteorUI.Settings.CornerRadius)
        Corner.Parent = self.MainFrame
        
        -- Верхняя панель (TopBar)
        self:CreateTopBar()
        
        -- Контейнер контента
        self.ContentContainer = Instance.new("Frame")
        self.ContentContainer.Name = "ContentContainer"
        self.ContentContainer.BackgroundTransparency = 1
        self.ContentContainer.Position = UDim2.new(0, 0, 0, MeteorUI.Settings.TopBarHeight)
        self.ContentContainer.Size = UDim2.new(1, 0, 1, -MeteorUI.Settings.TopBarHeight)
        self.ContentContainer.Parent = self.MainFrame
        
        -- Включение перетаскивания
        if MeteorUI.Settings.DragEnabled then
            self:EnableDragging()
        end
        
        return self
    end

    -- =====================================================
    -- TOP BAR - ВЕРХНЯЯ ПАНЕЛЬ С ПОИСКОМ И ВКЛАДКАМИ
    -- =====================================================
    
    function Window:CreateTopBar()
        -- Основной TopBar контейнер
        self.TopBar = Instance.new("Frame")
        self.TopBar.Name = "TopBar"
        self.TopBar.BackgroundColor3 = MeteorUI.Settings.SurfaceColor
        self.TopBar.BorderSizePixel = 0
        self.TopBar.Size = UDim2.new(1, 0, 0, MeteorUI.Settings.TopBarHeight)
        self.TopBar.Parent = self.MainFrame
        
        -- Скругление верхних углов
        local TopCorner = Instance.new("UICorner")
        TopCorner.CornerRadius = UDim.new(0, MeteorUI.Settings.CornerRadius)
        TopCorner.Parent = self.TopBar
        
        -- Заглушка снизу чтобы убрать скругление
        local BottomCover = Instance.new("Frame")
        BottomCover.BackgroundColor3 = MeteorUI.Settings.SurfaceColor
        BottomCover.BorderSizePixel = 0
        BottomCover.Position = UDim2.new(0, 0, 1, -10)
        BottomCover.Size = UDim2.new(1, 0, 0, 10)
        BottomCover.Parent = self.TopBar
        
        -- ПОИСКОВАЯ СТРОКА (Search Bar) - СЛЕВА
        self.SearchBar = self:CreateSearchBar()
        
        -- КОНТЕЙНЕР ВКЛАДОК - СПРАВА ОТ ПОИСКА
        self.TabContainer = Instance.new("Frame")
        self.TabContainer.Name = "TabContainer"
        self.TabContainer.BackgroundTransparency = 1
        self.TabContainer.Position = UDim2.new(0, MeteorUI.Settings.SearchBarWidth + 15, 0, 0)
        self.TabContainer.Size = UDim2.new(1, -(MeteorUI.Settings.SearchBarWidth + 15), 1, 0)
        self.TabContainer.Parent = self.TopBar
        
        -- Layout для вкладок (горизонтально)
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.FillDirection = Enum.FillDirection.Horizontal
        TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        TabLayout.Padding = UDim.new(0, 5)
        TabLayout.Parent = self.TabContainer
    end

    -- =====================================================
    -- SEARCH BAR - ПОИСКОВАЯ СТРОКА
    -- =====================================================
    
    function Window:CreateSearchBar()
        -- Контейнер поисковой строки
        local SearchContainer = Instance.new("Frame")
        SearchContainer.Name = "SearchBar"
        SearchContainer.BackgroundColor3 = MeteorUI.Settings.BackgroundColor
        SearchContainer.BorderSizePixel = 0
        SearchContainer.Position = UDim2.new(0, 10, 0.5, -15)
        SearchContainer.Size = UDim2.new(0, MeteorUI.Settings.SearchBarWidth, 0, 30)
        SearchContainer.Parent = self.TopBar
        
        -- Скругление
        local SearchCorner = Instance.new("UICorner")
        SearchCorner.CornerRadius = UDim.new(0, 6)
        SearchCorner.Parent = SearchContainer
        
        -- Иконка поиска (ImageLabel)
        local SearchIcon = Instance.new("ImageLabel")
        SearchIcon.Name = "SearchIcon"
        SearchIcon.BackgroundTransparency = 1
        SearchIcon.Position = UDim2.new(0, 8, 0.5, -10)
        SearchIcon.Size = UDim2.new(0, 20, 0, 20)
        SearchIcon.Image = MeteorUI.Icons.Search
        SearchIcon.ImageColor3 = MeteorUI.Settings.TextSecondaryColor
        SearchIcon.ScaleType = Enum.ScaleType.Fit
        SearchIcon.Parent = SearchContainer
        
        -- Текстовое поле
        local SearchInput = Instance.new("TextBox")
        SearchInput.Name = "SearchInput"
        SearchInput.BackgroundTransparency = 1
        SearchInput.Position = UDim2.new(0, 35, 0, 0)
        SearchInput.Size = UDim2.new(1, -40, 1, 0)
        SearchInput.Font = Enum.Font.Gotham
        SearchInput.PlaceholderText = "Search..."
        SearchInput.PlaceholderColor3 = MeteorUI.Settings.TextSecondaryColor
        SearchInput.Text = ""
        SearchInput.TextColor3 = MeteorUI.Settings.TextColor
        SearchInput.TextSize = 14
        SearchInput.TextXAlignment = Enum.TextXAlignment.Left
        SearchInput.ClearTextOnFocus = false
        SearchInput.Parent = SearchContainer

        -- Анимация при фокусе
        SearchInput.Focused:Connect(function()
            MeteorUI.AnimationManager:Animate(SearchContainer, {
                BackgroundColor3 = MeteorUI.Settings.SurfaceColor
            }, MeteorUI.Settings.HoverAnimationSpeed)
            
            MeteorUI.AnimationManager:Animate(SearchIcon, {
                ImageColor3 = MeteorUI.Settings.AccentColor
            }, MeteorUI.Settings.HoverAnimationSpeed)
        end)
        
        SearchInput.FocusLost:Connect(function()
            MeteorUI.AnimationManager:Animate(SearchContainer, {
                BackgroundColor3 = MeteorUI.Settings.BackgroundColor
            }, MeteorUI.Settings.HoverAnimationSpeed)
            
            MeteorUI.AnimationManager:Animate(SearchIcon, {
                ImageColor3 = MeteorUI.Settings.TextSecondaryColor
            }, MeteorUI.Settings.HoverAnimationSpeed)
        end)
        
        -- Обработка поиска
        SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
            self:PerformSearch(SearchInput.Text)
        end)
        
        return SearchContainer
    end
    
    function Window:PerformSearch(query)
        -- Глобальный поиск по всем элементам UI
        if query == "" then
            -- Показать все элементы
            return
        end
        
        query = string.lower(query)
        
        -- Поиск по вкладкам, секциям, элементам
        for _, tab in pairs(self.Tabs) do
            local matchFound = string.find(string.lower(tab.Name), query)
            -- Логика фильтрации элементов
        end
    end

    -- =====================================================
    -- TAB SYSTEM - СИСТЕМА ВКЛАДОК
    -- =====================================================
    
    function Window:CreateTab(name, iconId)
        local Tab = {
            Name = name,
            IconId = iconId,
            Active = false,
            Button = nil,
            Icon = nil,
            Content = nil,
            Sections = {},
        }
        
        -- Кнопка вкладки
        Tab.Button = Instance.new("TextButton")
        Tab.Button.Name = name
        Tab.Button.BackgroundColor3 = MeteorUI.Settings.SurfaceColor
        Tab.Button.BackgroundTransparency = 0.5
        Tab.Button.BorderSizePixel = 0
        Tab.Button.Size = UDim2.new(0, 120, 0, 35)
        Tab.Button.Font = Enum.Font.GothamMedium
        Tab.Button.Text = "  " .. name
        Tab.Button.TextColor3 = MeteorUI.Settings.TextSecondaryColor
        Tab.Button.TextSize = 13
        Tab.Button.TextXAlignment = Enum.TextXAlignment.Left
        Tab.Button.AutoButtonColor = false
        Tab.Button.Parent = self.TabContainer
        
        -- Скругление кнопки
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = Tab.Button
        
        -- Padding для текста
        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingLeft = UDim.new(0, 30)
        TabPadding.Parent = Tab.Button
        
        -- Иконка вкладки (если предоставлена)
        if iconId then
            Tab.Icon = Instance.new("ImageLabel")
            Tab.Icon.Name = "TabIcon"
            Tab.Icon.BackgroundTransparency = 1
            Tab.Icon.Position = UDim2.new(0, 8, 0.5, -10)
            Tab.Icon.Size = UDim2.new(0, 20, 0, 20)
            Tab.Icon.Image = iconId
            Tab.Icon.ImageColor3 = MeteorUI.Settings.TextSecondaryColor
            Tab.Icon.ScaleType = Enum.ScaleType.Fit
            Tab.Icon.Parent = Tab.Button
        end
        
        -- Индикатор активной вкладки (нижняя линия)
        local ActiveIndicator = Instance.new("Frame")
        ActiveIndicator.Name = "ActiveIndicator"
        ActiveIndicator.BackgroundColor3 = MeteorUI.Settings.AccentColor
        ActiveIndicator.BorderSizePixel = 0
        ActiveIndicator.Position = UDim2.new(0, 0, 1, -2)
        ActiveIndicator.Size = UDim2.new(1, 0, 0, 2)
        ActiveIndicator.Visible = false
        ActiveIndicator.Parent = Tab.Button

        -- Контент вкладки
        Tab.Content = Instance.new("ScrollingFrame")
        Tab.Content.Name = name .. "Content"
        Tab.Content.BackgroundTransparency = 1
        Tab.Content.BorderSizePixel = 0
        Tab.Content.Size = UDim2.new(1, 0, 1, 0)
        Tab.Content.ScrollBarThickness = 4
        Tab.Content.ScrollBarImageColor3 = MeteorUI.Settings.AccentColor
        Tab.Content.Visible = false
        Tab.Content.Parent = self.ContentContainer
        
        -- Layout для контента
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ContentLayout.Parent = Tab.Content
        
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 15)
        ContentPadding.PaddingBottom = UDim.new(0, 15)
        ContentPadding.PaddingLeft = UDim.new(0, 15)
        ContentPadding.PaddingRight = UDim.new(0, 15)
        ContentPadding.Parent = Tab.Content
        
        -- Обновление размера контента
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 30)
        end)
        
        -- Клик по вкладке
        Tab.Button.MouseButton1Click:Connect(function()
            self:SelectTab(Tab)
        end)

        -- Hover анимация
        Tab.Button.MouseEnter:Connect(function()
            if not Tab.Active then
                MeteorUI.AnimationManager:Animate(Tab.Button, {
                    BackgroundTransparency = 0.2
                }, MeteorUI.Settings.HoverAnimationSpeed)
                
                if Tab.Icon then
                    MeteorUI.AnimationManager:Animate(Tab.Icon, {
                        ImageColor3 = MeteorUI.Settings.TextColor
                    }, MeteorUI.Settings.HoverAnimationSpeed)
                end
            end
        end)
        
        Tab.Button.MouseLeave:Connect(function()
            if not Tab.Active then
                MeteorUI.AnimationManager:Animate(Tab.Button, {
                    BackgroundTransparency = 0.5
                }, MeteorUI.Settings.HoverAnimationSpeed)
                
                if Tab.Icon then
                    MeteorUI.AnimationManager:Animate(Tab.Icon, {
                        ImageColor3 = MeteorUI.Settings.TextSecondaryColor
                    }, MeteorUI.Settings.HoverAnimationSpeed)
                end
            end
        end)
        
        table.insert(self.Tabs, Tab)
        
        -- Автоматически выбрать первую вкладку
        if #self.Tabs == 1 then
            self:SelectTab(Tab)
        end
        
        return Tab
    end
    
    function Window:SelectTab(tab)
        -- Деактивировать все вкладки
        for _, t in pairs(self.Tabs) do
            t.Active = false
            t.Content.Visible = false
            t.Button.BackgroundTransparency = 0.5
            t.Button.TextColor3 = MeteorUI.Settings.TextSecondaryColor
            t.Button:FindFirstChild("ActiveIndicator").Visible = false
            
            if t.Icon then
                t.Icon.ImageColor3 = MeteorUI.Settings.TextSecondaryColor
            end
        end
        
        -- Активировать выбранную вкладку
        tab.Active = true
        tab.Content.Visible = true
        tab.Button.BackgroundTransparency = 0
        tab.Button.TextColor3 = MeteorUI.Settings.TextColor
        tab.Button:FindFirstChild("ActiveIndicator").Visible = true
        
        if tab.Icon then
            tab.Icon.ImageColor3 = MeteorUI.Settings.AccentColor
        end
        
        self.CurrentTab = tab
    end

    -- =====================================================
    -- SECTION - СЕКЦИЯ ВНУТРИ ВКЛАДКИ
    -- =====================================================
    
    function Window:CreateSection(tab, name)
        local Section = {
            Name = name,
            Container = nil,
            Elements = {},
        }
        
        -- Контейнер секции
        Section.Container = Instance.new("Frame")
        Section.Container.Name = name
        Section.Container.BackgroundColor3 = MeteorUI.Settings.SurfaceColor
        Section.Container.BorderSizePixel = 0
        Section.Container.Size = UDim2.new(0.95, 0, 0, 50)
        Section.Container.Parent = tab.Content
        
        -- Скругление
        local SectionCorner = Instance.new("UICorner")
        SectionCorner.CornerRadius = UDim.new(0, MeteorUI.Settings.CornerRadius)
        SectionCorner.Parent = Section.Container
        
        -- Заголовок секции
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Name = "Title"
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Position = UDim2.new(0, 15, 0, 10)
        SectionTitle.Size = UDim2.new(1, -30, 0, 25)
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.Text = name
        SectionTitle.TextColor3 = MeteorUI.Settings.TextColor
        SectionTitle.TextSize = 15
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.Parent = Section.Container
        
        -- Layout для элементов
        local ElementLayout = Instance.new("UIListLayout")
        ElementLayout.Padding = UDim.new(0, 8)
        ElementLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ElementLayout.Parent = Section.Container

        local SectionPadding = Instance.new("UIPadding")
        SectionPadding.PaddingTop = UDim.new(0, 40)
        SectionPadding.PaddingBottom = UDim.new(0, 15)
        SectionPadding.PaddingLeft = UDim.new(0, 15)
        SectionPadding.PaddingRight = UDim.new(0, 15)
        SectionPadding.Parent = Section.Container
        
        -- Автоматическое изменение размера секции
        ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Section.Container.Size = UDim2.new(0.95, 0, 0, ElementLayout.AbsoluteContentSize.Y + 55)
        end)
        
        table.insert(tab.Sections, Section)
        return Section
    end
    
    -- =====================================================
    -- WINDOW CONTROLS - УПРАВЛЕНИЕ ОКНОМ
    -- =====================================================
    
    function Window:EnableDragging()
        local dragging = false
        local dragInput, mousePos, framePos
        
        self.TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                mousePos = input.Position
                framePos = self.MainFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        self.TopBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                self.MainFrame.Position = UDim2.new(
                    framePos.X.Scale, framePos.X.Offset + delta.X,
                    framePos.Y.Scale, framePos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    function Window:Hide()
        self.ScreenGui.Enabled = false
    end
    
    function Window:Show()
        self.ScreenGui.Enabled = true
    end
    
    function Window:Toggle()
        self.ScreenGui.Enabled = not self.ScreenGui.Enabled
    end
    
    function Window:Destroy()
        if self.ScreenGui then
            self.ScreenGui:Destroy()
        end
    end
    
    return Window:Initialize()
end

-- =====================================================
-- ANIMATION MANAGER - МЕНЕДЖЕР АНИМАЦИЙ
-- =====================================================

function MeteorUI.AnimationManager:Animate(object, properties, duration)
    duration = duration or MeteorUI.Settings.AnimationSpeed
    
    local TweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    
    return tween
end

function MeteorUI.AnimationManager:RippleEffect(button, position)
    if not MeteorUI.Settings.RippleEnabled then return end
    
    local Ripple = Instance.new("Frame")
    Ripple.Name = "Ripple"
    Ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Ripple.BackgroundTransparency = 0.5
    Ripple.BorderSizePixel = 0
    Ripple.Position = UDim2.new(0, position.X, 0, position.Y)
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    Ripple.Parent = button
    
    local RippleCorner = Instance.new("UICorner")
    RippleCorner.CornerRadius = UDim.new(1, 0)
    RippleCorner.Parent = Ripple
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    self:Animate(Ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, MeteorUI.Settings.RippleAnimationSpeed)
    
    task.wait(MeteorUI.Settings.RippleAnimationSpeed)
    Ripple:Destroy()
end

-- =====================================================
-- THEME MANAGER - МЕНЕДЖЕР ТЕМ
-- =====================================================

MeteorUI.Themes = {
    Default = {
        AccentColor = Color3.fromRGB(120, 120, 255),
        BackgroundColor = Color3.fromRGB(20, 20, 25),
        SurfaceColor = Color3.fromRGB(30, 30, 35),
        BorderColor = Color3.fromRGB(50, 50, 60),
        TextColor = Color3.fromRGB(240, 240, 245),
        TextSecondaryColor = Color3.fromRGB(180, 180, 190),
    },
    Dark = {
        AccentColor = Color3.fromRGB(100, 200, 255),
        BackgroundColor = Color3.fromRGB(15, 15, 18),
        SurfaceColor = Color3.fromRGB(25, 25, 28),
        BorderColor = Color3.fromRGB(40, 40, 50),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSecondaryColor = Color3.fromRGB(150, 150, 160),
    },
    Light = {
        AccentColor = Color3.fromRGB(80, 80, 220),
        BackgroundColor = Color3.fromRGB(240, 240, 245),
        SurfaceColor = Color3.fromRGB(255, 255, 255),
        BorderColor = Color3.fromRGB(200, 200, 210),
        TextColor = Color3.fromRGB(20, 20, 25),
        TextSecondaryColor = Color3.fromRGB(100, 100, 110),
    }
}

function MeteorUI.ThemeManager:ApplyTheme(themeName)
    local theme = MeteorUI.Themes[themeName]
    if not theme then return end
    
    for key, value in pairs(theme) do
        MeteorUI.Settings[key] = value
    end
end

-- =====================================================
-- CONFIG MANAGER - МЕНЕДЖЕР КОНФИГУРАЦИЙ
-- =====================================================

function MeteorUI.ConfigManager:SaveConfig(configName, data)
    if not writefile then
        warn("Executor doesn't support writefile!")
        return false
    end
    
    local success, err = pcall(function()
        writefile("MeteorUI_" .. configName .. ".json", game:GetService("HttpService"):JSONEncode(data))
    end)
    
    return success
end

function MeteorUI.ConfigManager:LoadConfig(configName)
    if not readfile then
        warn("Executor doesn't support readfile!")
        return nil
    end
    
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile("MeteorUI_" .. configName .. ".json"))
    end)
    
    return success and result or nil
end

function MeteorUI.ConfigManager:DeleteConfig(configName)
    if not delfile then
        warn("Executor doesn't support delfile!")
        return false
    end
    
    local success = pcall(function()
        delfile("MeteorUI_" .. configName .. ".json")
    end)
    
    return success
end

-- =====================================================
-- ПРИМЕР ИСПОЛЬЗОВАНИЯ
-- =====================================================

--[[

-- Создание окна
local Window = MeteorUI:CreateWindow({
    Title = "Meteor UI Library",
    Position = UDim2.new(0.5, -300, 0.5, -250),
    Size = UDim2.new(0, 600, 0, 500)
})

-- Создание вкладок с иконками
local CombatTab = Window:CreateTab("Combat", nil) -- Можно добавить свою иконку
local MovementTab = Window:CreateTab("Movement", nil)
local VisualTab = Window:CreateTab("Visual", nil)
local ConfigsTab = Window:CreateTab("Configs", MeteorUI.Icons.Configs)
local ThemeTab = Window:CreateTab("Theme", MeteorUI.Icons.Theme)
local SettingsTab = Window:CreateTab("Settings", MeteorUI.Icons.Settings)

-- Создание секций
local WeaponsSection = Window:CreateSection(CombatTab, "Weapons")
local SpeedSection = Window:CreateSection(MovementTab, "Speed")

-- Добавление элементов (будут реализованы далее)
-- WeaponsSection:AddToggle("KillAura", false, function(state) end)
-- WeaponsSection:AddSlider("Reach", 3, 6, 3, function(value) end)
-- SpeedSection:AddToggle("Speed", false, function(state) end)

-- Управление окном
-- Window:Hide()
-- Window:Show()
-- Window:Toggle()
-- Window:Destroy()

-- Изменение темы
-- MeteorUI.ThemeManager:ApplyTheme("Dark")
-- MeteorUI.ThemeManager:ApplyTheme("Light")

]]

-- =====================================================
-- ВОЗВРАТ БИБЛИОТЕКИ
-- =====================================================

return MeteorUI
