-- [[ VOLTECLIPSE / METEOR STYLE CLEAN UI LIBRARY ]] --
local Library = {}
Library.Theme = {
    Background = Color3.fromRGB(15, 15, 15),       -- Еще более глубокий тёмный тон
    Card = Color3.fromRGB(22, 22, 22),             -- Фоновые окна
    Accent = Color3.fromRGB(145, 70, 255),         -- Фиолетовый неон (Volt Цветь)
    Stroke = Color3.fromRGB(32, 32, 32),           -- Минималистичная тонкая обводка
    Text = Color3.fromRGB(255, 255, 255),          -- Белый текст
    TextDim = Color3.fromRGB(140, 140, 140),       -- Спокойный серый текст
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

if ParentContainer:FindFirstChild("VoltEclipseLibrary") then
    ParentContainer.VoltEclipseLibrary:Destroy()
end

local function tween(object, info, properties)
    local anim = TweenService:Create(object, TweenInfo.new(info), properties)
    anim:Play()
    return anim
end

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

function Library:Init()
    local Main = {
        CurrentTab = nil,
        Tabs = {},
        Pages = {}
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VoltEclipseLibrary"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = ParentContainer

    -- Главный фрейм (Контейнер всего чит-меню)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 800, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -400, 0, 30) -- Сверху по центру экрана
    MainFrame.BackgroundTransparency = 1
    MainFrame.Parent = ScreenGui

    -- Шапка интерфейса (Header)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 48)
    Header.BackgroundColor3 = Library.Theme.Background
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 5)
    HeaderCorner.Parent = Header

    local HeaderStroke = Instance.new("UIStroke")
    HeaderStroke.Color = Library.Theme.Stroke
    HeaderStroke.Thickness = 1
    HeaderStroke.Parent = Header

    makeDraggable(MainFrame, Header)

    -- Логотип проекта (VoltEclipse) - Слева
    local Logo = Instance.new("ImageLabel")
    Logo.Name = "ProjectLogo"
    Logo.Size = UDim2.new(0, 26, 0, 26)
    Logo.Position = UDim2.new(0, 12, 0.5, -13)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://7015953925"
    Logo.Parent = Header

    -- Контейнер для вкладок (ScrollingFrame - защищает от лимитов!)
    local TabsScroll = Instance.new("ScrollingFrame")
    TabsScroll.Name = "TabsScroll"
    TabsScroll.Size = UDim2.new(0, 410, 1, 0)
    TabsScroll.Position = UDim2.new(0, 50, 0, 0)
    TabsScroll.BackgroundTransparency = 1
    TabsScroll.BorderSizePixel = 0
    TabsScroll.ScrollBarThickness = 0
    TabsScroll.ScrollingDirection = Enum.ScrollingDirection.Horizontal
    TabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    TabsScroll.Parent = Header

    local TabsLayout = Instance.new("UIListLayout")
    TabsLayout.FillDirection = Enum.FillDirection.Horizontal
    TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabsLayout.Padding = UDim.new(0, 6)
    TabsLayout.Parent = TabsScroll

    local TabsPadding = Instance.new("UIPadding")
    TabsPadding.PaddingLeft = UDim.new(0, 2)
    TabsPadding.Parent = TabsScroll

    -- Правая сторона (Поиск + Шестеренка)
    local RightContainer = Instance.new("Frame")
    RightContainer.Name = "RightContainer"
    RightContainer.Size = UDim2.new(0, 320, 1, 0)
    RightContainer.Position = UDim2.new(1, -330, 0, 0)
    RightContainer.BackgroundTransparency = 1
    RightContainer.Parent = Header

    local RightLayout = Instance.new("UIListLayout")
    RightLayout.FillDirection = Enum.FillDirection.Horizontal
    RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    RightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Padding = UDim.new(0, 8)
    RightLayout.Parent = RightContainer

    -- Поисковая панель CLEAN
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Size = UDim2.new(0, 160, 0, 28)
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

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Size = UDim2.new(0, 14, 0, 14)
    SearchIcon.Position = UDim2.new(0, 8, 0.5, -7)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = "rbxassetid://118685771787843"
    SearchIcon.ImageColor3 = Library.Theme.TextDim
    SearchIcon.Parent = SearchFrame

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -32, 1, 0)
    SearchBox.Position = UDim2.new(0, 28, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(70, 70, 70)
    SearchBox.TextColor3 = Library.Theme.Text
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.Parent = SearchFrame

    -- Иконка настроек (Шестеренка ImageButton)
    local SettingsBtn = Instance.new("ImageButton")
    SettingsBtn.Name = "SettingsBtn"
    SettingsBtn.Size = UDim2.new(0, 28, 0, 28)
    SettingsBtn.BackgroundColor3 = Library.Theme.Card
    SettingsBtn.Image = "rbxassetid://103884184213243"
    SettingsBtn.ImageColor3 = Library.Theme.TextDim
    SettingsBtn.LayoutOrder = 2
    SettingsBtn.Parent = RightContainer

    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 4)
    SettingsCorner.Parent = SettingsBtn

    local SettingsStroke = Instance.new("UIStroke")
    SettingsStroke.Color = Library.Theme.Stroke
    SettingsStroke.Thickness = 1
    SettingsStroke.Parent = SettingsBtn

    -- Логика эффекта наведения на шестеренку
    SettingsBtn.MouseEnter:Connect(function()
        tween(SettingsBtn, 0.15, {ImageColor3 = Library.Theme.Text})
    end)
    SettingsBtn.MouseLeave:Connect(function()
        tween(SettingsBtn, 0.15, {ImageColor3 = Library.Theme.TextDim})
    end)

    -- Папка страниц под хедером
    local PagesFolder = Instance.new("Frame")
    PagesFolder.Name = "PagesFolder"
    PagesFolder.Size = UDim2.new(1, 0, 1, -58)
    PagesFolder.Position = UDim2.new(0, 0, 0, 58)
    PagesFolder.BackgroundTransparency = 1
    PagesFolder.Parent = MainFrame

    -- Функция переключения Окон Вкладок (Подсветка всей плашки!)
    local function showPage(tabName)
        for name, page in pairs(Main.Pages) do
            local tabAsset = Main.Tabs[name]
            if name == tabName then
                page.Visible = true
                tween(tabAsset.Frame, 0.15, {BackgroundColor3 = Library.Theme.Accent})
                tween(tabAsset.Stroke, 0.15, {Color = Library.Theme.Accent})
                tween(tabAsset.Label, 0.15, {TextColor3 = Library.Theme.Text})
            else
                page.Visible = false
                tween(tabAsset.Frame, 0.15, {BackgroundColor3 = Library.Theme.Card})
                tween(tabAsset.Stroke, 0.15, {Color = Library.Theme.Stroke})
                tween(tabAsset.Label, 0.15, {TextColor3 = Library.Theme.TextDim})
            end
        end
    end

    -- Умный поиск по названию окон
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

        -- Окно-плашка вкладки
        local TabFrame = Instance.new("Frame")
        TabFrame.Name = tabName .. "TabFrame"
        TabFrame.Size = UDim2.new(0, 95, 0, 28)
        TabFrame.BackgroundColor3 = Library.Theme.Card
        TabFrame.Parent = TabsScroll

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabFrame

        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = Library.Theme.Stroke
        TabStroke.Thickness = 1
        TabStroke.Parent = TabFrame

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, 0, 1, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = string.upper(tabName)
        TabLabel.TextColor3 = Library.Theme.TextDim
        TabLabel.Font = Enum.Font.GothamBold
        TabLabel.TextSize = 11
        TabLabel.Parent = TabFrame

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 1, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = TabFrame

        -- Страница для окон (ScrollingFrame, чтобы окна тоже могли идти бесконечно вниз)
        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 0
        Page.Visible = false
        Page.ScrollingDirection = Enum.ScrollingDirection.Vertical
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Parent = PagesFolder

        local PageLayout = Instance.new("UIGridLayout")
        PageLayout.CellSize = UDim2.new(0, 190, 0, 140)
        PageLayout.CellPadding = UDim2.new(0, 12, 0, 12)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page

        Main.Tabs[tabName] = {Frame = TabFrame, Stroke = TabStroke, Label = TabLabel}
        Main.Pages[tabName] = Page

        TabBtn.MouseButton1Click:Connect(function()
            showPage(tabName)
        end)

        if not Main.CurrentTab then
            Main.CurrentTab = tabName
            showPage(tabName)
        end

        -- [[ МЕТОД: СОЗДАНИЕ ОКНА ]] --
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

            local WindowTitle = Instance.new("TextLabel")
            WindowTitle.Name = "WindowTitle"
            WindowTitle.Size = UDim2.new(1, 0, 0, 25)
            WindowTitle.Position = UDim2.new(0, 10, 0, 6)
            WindowTitle.BackgroundTransparency = 1
            WindowTitle.Text = windowName
            WindowTitle.TextColor3 = Library.Theme.Text
            WindowTitle.Font = Enum.Font.GothamBold
            WindowTitle.TextSize = 12
            WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
            WindowTitle.Parent = WindowFrame

            local ElementsContainer = Instance.new("Frame")
            ElementsContainer.Name = "Elements"
            ElementsContainer.Size = UDim2.new(1, -20, 1, -35)
            ElementsContainer.Position = UDim2.new(0, 10, 0, 32)
            ElementsContainer.BackgroundTransparency = 1
            ElementsContainer.Parent = WindowFrame

            local ElementsLayout = Instance.new("UIListLayout")
            ElementsLayout.FillDirection = Enum.FillDirection.Vertical
            ElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementsLayout.Padding = UDim.new(0, 6)
            ElementsLayout.Parent = ElementsContainer

            ElementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                WindowFrame.Size = UDim2.new(0, 190, 0, ElementsLayout.AbsoluteContentSize.Y + 42)
            end)

            -- [[ МЕТОД: СОЗДАНИЕ КНОПКИ ]] --
            function Window:CreateButton(btnText, callback)
                callback = callback or function() end

                local Button = Instance.new("TextButton")
                Button.Name = btnText .. "Btn"
                Button.Size = UDim2.new(1, 0, 0, 24)
                Button.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
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

            -- [[ МЕТОД: СОЗДАНИЕ СЛАЙДЕРА ]] --
            function Window:CreateSlider(sliderText, min, max, default, callback)
                callback = callback or function() end
                local val = default or min

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = sliderText .. "Slider"
                SliderFrame.Size = UDim2.new(1, 0, 0, 30)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = ElementsContainer

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0, 110, 0, 14)
                Label.BackgroundTransparency = 1
                Label.Text = sliderText
                Label.TextColor3 = Library.Theme.TextDim
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 10
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SliderFrame

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(1, -115, 0, 14)
                ValLabel.Position = UDim2.new(0, 115, 0, 0)
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
                Track.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
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

            -- [[ МЕТОД: СОЗДАНИЕ ТУГГЛА (Переключателя) ]] --
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
                Box.Size = UDim2.new(0, 15, 0, 15)
                Box.Position = UDim2.new(1, -15, 0.5, -7)
                Box.BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(28, 28, 28)
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
                    tween(Box, 0.12, {BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(28, 28, 28)})
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
