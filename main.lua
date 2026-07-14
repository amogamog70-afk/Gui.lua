local Library = {}
Library.Theme = {
    Background = Color3.fromRGB(17, 17, 17),       -- Темно-серый фон (Meteor)
    Card = Color3.fromRGB(24, 24, 24),             -- Цвет окон/карточек
    Accent = Color3.fromRGB(145, 70, 255),         -- Фиолетовый неон
    Stroke = Color3.fromRGB(35, 35, 35),           -- Границы по умолчанию
    Text = Color3.fromRGB(255, 255, 255),          -- Белый текст
    TextDim = Color3.fromRGB(150, 150, 150),       -- Серый текст
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local ParentContainer = nil
pcall(function() ParentContainer = CoreGui end)
if not ParentContainer then
    ParentContainer = Players.LocalPlayer:WaitForChild("PlayerGui")
end

if ParentContainer:FindFirstChild("MeteorLibrary") then
    ParentContainer.MeteorLibrary:Destroy()
end

local function tween(object, info, properties)
    local anim = TweenService:Create(object, TweenInfo.new(info), properties)
    anim:Play()
    return anim
end

-- Функция перетаскивания всего интерфейса за Хедер
local function makeDraggable(frame, dragAnchor)
    local dragging, dragInput, dragStart, startPos
    dragAnchor.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragAnchor.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [[ ИНИЦИАЛИЗАЦИЯ БИБЛИОТЕКИ ]] --
function Library:Init()
    local Main = {
        CurrentTab = nil,
        Tabs = {},
        Pages = {}
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MeteorLibrary"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = ParentContainer

    -- Главный контейнер (двигается целиком вместе со всеми окнами)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 750, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -375, 0, 25) -- Сверху экрана по центру
    MainFrame.BackgroundTransparency = 1
    MainFrame.Parent = ScreenGui

    -- Верхняя панель (Хедер)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Library.Theme.Background
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 6)
    HeaderCorner.Parent = Header

    local HeaderStroke = Instance.new("UIStroke")
    HeaderStroke.Color = Library.Theme.Stroke
    HeaderStroke.Thickness = 1.5
    HeaderStroke.Parent = Header

    makeDraggable(MainFrame, Header) -- Тянем за хедер — двигается всё меню

    -- Список вкладок (Слева)
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Name = "TabsContainer"
    TabsContainer.Size = UDim2.new(0.6, 0, 1, 0)
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.Parent = Header

    local TabsLayout = Instance.new("UIListLayout")
    TabsLayout.FillDirection = Enum.FillDirection.Horizontal
    TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsLayout.Padding = UDim.new(0, 8)
    TabsLayout.Parent = TabsContainer

    local TabsPadding = Instance.new("UIPadding")
    TabsPadding.PaddingLeft = UDim.new(0, 10)
    TabsPadding.PaddingTop = UDim.new(0, 8)
    TabsPadding.Parent = TabsContainer

    -- Правая часть (Поиск + Настройки)
    local RightContainer = Instance.new("Frame")
    RightContainer.Name = "RightContainer"
    RightContainer.Size = UDim2.new(0.4, -10, 1, 0)
    RightContainer.Position = UDim2.new(0.6, 0, 0, 0)
    RightContainer.BackgroundTransparency = 1
    RightContainer.Parent = Header

    local RightLayout = Instance.new("UIListLayout")
    RightLayout.FillDirection = Enum.FillDirection.Horizontal
    RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    RightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Padding = UDim.new(0, 8)
    RightLayout.Parent = RightContainer

    -- Поиск
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Size = UDim2.new(0, 160, 0, 29)
    SearchFrame.BackgroundColor3 = Library.Theme.Card
    SearchFrame.LayoutOrder = 1
    SearchFrame.Parent = RightContainer

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 4)
    SearchCorner.Parent = SearchFrame

    local SearchStroke = Instance.new("UIStroke")
    SearchStroke.Color = Library.Theme.Stroke
    SearchStroke.Thickness = 1
    SearchStroke.Parent = SearchFrame

    local SearchIcon = Instance.new("TextLabel")
    SearchIcon.Size = UDim2.new(0, 25, 1, 0)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Text = "🔍"
    SearchIcon.TextSize = 12
    SearchIcon.TextColor3 = Library.Theme.TextDim
    SearchIcon.Parent = SearchFrame

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -30, 1, 0)
    SearchBox.Position = UDim2.new(0, 25, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
    SearchBox.TextColor3 = Library.Theme.Text
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.Parent = SearchFrame

    -- Шестеренка
    local SettingsBtn = Instance.new("TextButton")
    SettingsBtn.Name = "SettingsBtn"
    SettingsBtn.Size = UDim2.new(0, 29, 0, 29)
    SettingsBtn.BackgroundColor3 = Library.Theme.Card
    SettingsBtn.Text = "⚙️"
    SettingsBtn.TextColor3 = Library.Theme.TextDim
    SettingsBtn.TextSize = 15
    SettingsBtn.Font = Enum.Font.Gotham
    SettingsBtn.LayoutOrder = 2
    SettingsBtn.Parent = RightContainer

    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 4)
    SettingsCorner.Parent = SettingsBtn

    local SettingsStroke = Instance.new("UIStroke")
    SettingsStroke.Color = Library.Theme.Stroke
    SettingsStroke.Thickness = 1
    SettingsStroke.Parent = SettingsBtn

    -- Общий контейнер для страниц вкладок (выравнивается под хедером)
    local PagesFolder = Instance.new("Frame")
    PagesFolder.Name = "PagesFolder"
    PagesFolder.Size = UDim2.new(1, 0, 1, -55)
    PagesFolder.Position = UDim2.new(0, 0, 0, 55)
    PagesFolder.BackgroundTransparency = 1
    PagesFolder.Parent = MainFrame

    local function showPage(tabName)
        for name, page in pairs(Main.Pages) do
            if name == tabName then
                page.Visible = true
                tween(Main.Tabs[name].Stroke, 0.15, {Color = Library.Theme.Accent, Thickness = 2})
                tween(Main.Tabs[name].Button, 0.15, {TextColor3 = Library.Theme.Text})
            else
                page.Visible = false
                tween(Main.Tabs[name].Stroke, 0.15, {Color = Library.Theme.Stroke, Thickness = 1})
                tween(Main.Tabs[name].Button, 0.15, {TextColor3 = Library.Theme.TextDim})
            end
        end
    end

    -- Умный поиск (фильтрует окна по названию при вводе текста)
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, page in pairs(Main.Pages) do
            for _, window in ipairs(page:GetChildren()) do
                if window:IsA("Frame") and window.Name ~= "UIGridLayout" then
                    local winTitle = window:FindFirstChild("WindowTitle")
                    if winTitle then
                        if string.find(string.lower(winTitle.Text), query) then
                            window.Visible = true
                        else
                            window.Visible = false
                        end
                    end
                end
            end
        end
    end)

    -- [[ МЕТОД: СОЗДАНИЕ ВКЛАДКИ ]] --
    function Main:CreateTab(tabName)
        local Tab = {}

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName .. "Tab"
        TabBtn.Size = UDim2.new(0, 110, 0, 29)
        TabBtn.BackgroundColor3 = Library.Theme.Card
        TabBtn.Text = string.upper(tabName)
        TabBtn.TextColor3 = Library.Theme.TextDim
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 11
        TabBtn.Parent = TabsContainer

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 4)
        TabBtnCorner.Parent = TabBtn

        local TabBtnStroke = Instance.new("UIStroke")
        TabBtnStroke.Color = Library.Theme.Stroke
        TabBtnStroke.Thickness = 1
        TabBtnStroke.Parent = TabBtn

        -- Страница для окон этой вкладки (сетка окон)
        local Page = Instance.new("Frame")
        Page.Name = tabName .. "Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.Parent = PagesFolder

        local PageLayout = Instance.new("UIGridLayout")
        PageLayout.CellSize = UDim2.new(0, 175, 0, 140) -- Размер окон (карт) под функции
        PageLayout.CellPadding = UDim2.new(0, 12, 0, 12)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page

        Main.Tabs[tabName] = {Button = TabBtn, Stroke = TabBtnStroke}
        Main.Pages[tabName] = Page

        TabBtn.MouseButton1Click:Connect(function()
            showPage(tabName)
        end)

        if not Main.CurrentTab then
            Main.CurrentTab = tabName
            showPage(tabName)
        end

        -- [[ МЕТОД: СОЗДАНИЕ ОКНА (Группы / Карточки) ]] --
        function Tab:CreateWindow(windowName)
            local Window = {}

            local WindowFrame = Instance.new("Frame")
            WindowFrame.Name = windowName .. "Window"
            WindowFrame.BackgroundColor3 = Library.Theme.Card
            WindowFrame.Parent = Page

            local WindowCorner = Instance.new("UICorner")
            WindowCorner.CornerRadius = UDim.new(0, 4)
            WindowCorner.Parent = WindowFrame

            local WindowStroke = Instance.new("UIStroke")
            WindowStroke.Color = Library.Theme.Stroke
            WindowStroke.Thickness = 1
            WindowStroke.Parent = WindowFrame

            -- Заголовок Окна (например, "ESP" как на рисунке)
            local WindowTitle = Instance.new("TextLabel")
            WindowTitle.Name = "WindowTitle"
            WindowTitle.Size = UDim2.new(1, 0, 0, 25)
            WindowTitle.Position = UDim2.new(0, 10, 0, 4)
            WindowTitle.BackgroundTransparency = 1
            WindowTitle.Text = windowName
            WindowTitle.TextColor3 = Library.Theme.Text
            WindowTitle.Font = Enum.Font.GothamBold
            WindowTitle.TextSize = 12
            WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
            WindowTitle.Parent = WindowFrame

            -- Список элементов внутри Окна
            local ElementsContainer = Instance.new("Frame")
            ElementsContainer.Name = "Elements"
            ElementsContainer.Size = UDim2.new(1, -20, 1, -35)
            ElementsContainer.Position = UDim2.new(0, 10, 0, 30)
            ElementsContainer.BackgroundTransparency = 1
            ElementsContainer.Parent = WindowFrame

            local ElementsLayout = Instance.new("UIListLayout")
            ElementsLayout.FillDirection = Enum.FillDirection.Vertical
            ElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementsLayout.Padding = UDim.new(0, 6)
            ElementsLayout.Parent = ElementsContainer

            -- Автоматическая подстройка высоты окна под количество элементов в нем
            ElementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                WindowFrame.Size = UDim2.new(0, 175, 0, ElementsLayout.AbsoluteContentSize.Y + 42)
            end)

            -- [[ МЕТОД: СОЗДАНИЕ КНОПКИ (внутри Окна) ]] --
            function Window:CreateButton(btnText, callback)
                callback = callback or function() end

                local Button = Instance.new("TextButton")
                Button.Name = btnText .. "Btn"
                Button.Size = UDim2.new(1, 0, 0, 24)
                Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Button.Text = btnText
                Button.TextColor3 = Library.Theme.TextDim
                Button.Font = Enum.Font.Gotham
                Button.TextSize = 11
                Button.Parent = ElementsContainer

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 3)
                BtnCorner.Parent = Button

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Library.Theme.Stroke
                BtnStroke.Thickness = 1
                BtnStroke.Parent = Button

                Button.MouseEnter:Connect(function()
                    tween(BtnStroke, 0.15, {Color = Color3.fromRGB(70, 70, 70)})
                    tween(Button, 0.15, {TextColor3 = Library.Theme.Text})
                end)
                Button.MouseLeave:Connect(function()
                    tween(BtnStroke, 0.15, {Color = Library.Theme.Stroke})
                    tween(Button, 0.15, {TextColor3 = Library.Theme.TextDim})
                end)
                Button.MouseButton1Click:Connect(function()
                    tween(BtnStroke, 0.05, {Color = Library.Theme.Accent})
                    task.wait(0.08)
                    tween(BtnStroke, 0.05, {Color = Color3.fromRGB(70, 70, 70)})
                    callback()
                end)
            end

            -- [[ МЕТОД: СОЗДАНИЕ СЛАЙДЕРА (внутри Окна) ]] --
            function Window:CreateSlider(sliderText, min, max, default, callback)
                callback = callback or function() end
                local val = default or min

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = sliderText .. "Slider"
                SliderFrame.Size = UDim2.new(1, 0, 0, 30)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = ElementsContainer

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.6, 0, 0, 14)
                Label.BackgroundTransparency = 1
                Label.Text = sliderText
                Label.TextColor3 = Library.Theme.TextDim
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 10
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SliderFrame

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(0.4, 0, 0, 14)
                ValLabel.Position = UDim2.new(0.6, 0, 0, 0)
                ValLabel.BackgroundTransparency = 1
                ValLabel.Text = tostring(val)
                ValLabel.TextColor3 = Library.Theme.Text
                ValLabel.Font = Enum.Font.GothamBold
                ValLabel.TextSize = 10
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.Parent = SliderFrame

                local Track = Instance.new("Frame")
                Track.Size = UDim2.new(1, 0, 0, 4)
                Track.Position = UDim2.new(0, 0, 0, 20)
                Track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                Track.BorderSizePixel = 0
                Track.Parent = SliderFrame

                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(0, 2)
                TrackCorner.Parent = Track

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Library.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Parent = Track

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 2)
                FillCorner.Parent = Fill

                local isDragging = false
                local function update(input)
                    local percentage = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    val = math.round(min + ((max - min) * percentage))
                    Fill.Size = UDim2.new(percentage, 0, 1, 0)
                    ValLabel.Text = tostring(val)
                    callback(val)
                end

                SliderFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = true
                        update(input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)
            end

            -- [[ МЕТОД: СОЗДАНИЕ ПЕРЕКЛЮЧАТЕЛЯ / TOGGLE (внутри Окна) ]] --
            function Window:CreateToggle(toggleText, default, callback)
                callback = callback or function() end
                local state = default or false

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = toggleText .. "Toggle"
                ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = ElementsContainer

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -25, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = toggleText
                Label.TextColor3 = Library.Theme.TextDim
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ToggleFrame

                local Box = Instance.new("TextButton")
                Box.Size = UDim2.new(0, 16, 0, 16)
                Box.Position = UDim2.new(1, -16, 0.5, -8)
                Box.BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(30, 30, 30)
                Box.Text = ""
                Box.Parent = ToggleFrame

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 3)
                BoxCorner.Parent = Box

                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = state and Library.Theme.Accent or Library.Theme.Stroke
                BoxStroke.Thickness = 1
                BoxStroke.Parent = Box

                Box.MouseButton1Click:Connect(function()
                    state = not state
                    tween(Box, 0.12, {BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(30, 30, 30)})
                    tween(BoxStroke, 0.12, {Color = state and Library.Theme.Accent or Library.Theme.Stroke})
                    callback(state)
                end)
            end

            return Window
        end

        return Tab
    end

    return Main
end

return Library
