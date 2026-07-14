-- [[ VOLTECLIPSE / PREMIUM STYLE CLEAN UI LIBRARY (V2) ]] --
local Library = {}
Library.Theme = {
    Background = Color3.fromRGB(11, 11, 14),       -- Глубокий темный фон всего меню
    Header = Color3.fromRGB(16, 16, 20),           -- Темный фон шапки
    Card = Color3.fromRGB(18, 18, 24),             -- Карточки модулей (Окна)
    Section = Color3.fromRGB(24, 24, 30),          -- Внутренние карточки под-секций
    Accent = Color3.fromRGB(145, 70, 255),         -- Фиолетовый Volt-неон
    Stroke = Color3.fromRGB(32, 32, 40),           -- Тонкие премиальные границы
    Text = Color3.fromRGB(255, 255, 255),          -- Белый текст заголовков
    TextDim = Color3.fromRGB(140, 140, 150),       -- Серый текст для опций
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

    -- Главный Фрейм (Сплошной премиум фон)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 800, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
    MainFrame.BackgroundColor3 = Library.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Library.Theme.Stroke
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    -- Шапка
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Library.Theme.Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header

    -- Линия разделения под шапкой
    local HeaderLine = Instance.new("Frame")
    HeaderLine.Size = UDim2.new(1, 0, 0, 1)
    HeaderLine.Position = UDim2.new(0, 0, 1, -1)
    HeaderLine.BackgroundColor3 = Library.Theme.Stroke
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Parent = Header

    makeDraggable(MainFrame, Header)

    local Logo = Instance.new("ImageLabel")
    Logo.Name = "ProjectLogo"
    Logo.Size = UDim2.new(0, 22, 0, 22)
    Logo.Position = UDim2.new(0, 15, 0.5, -11)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://7015953925"
    Logo.Parent = Header

    -- Контейнер вкладок с ИДЕАЛЬНЫМ центрированием
    local TabsScroll = Instance.new("ScrollingFrame")
    TabsScroll.Name = "TabsScroll"
    TabsScroll.Size = UDim2.new(1, -310, 0, 28)
    TabsScroll.Position = UDim2.new(0, 50, 0.5, -14) -- Идеально ровно по середине
    TabsScroll.BackgroundTransparency = 1
    TabsScroll.BorderSizePixel = 0
    TabsScroll.ScrollBarThickness = 0
    TabsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabsScroll.ScrollingDirection = Enum.ScrollingDirection.X
    TabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    TabsScroll.Parent = Header

    local TabsLayout = Instance.new("UIListLayout")
    TabsLayout.FillDirection = Enum.FillDirection.Horizontal
    TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabsLayout.Padding = UDim.new(0, 6)
    TabsLayout.Parent = TabsScroll

    local RightContainer = Instance.new("Frame")
    RightContainer.Name = "RightContainer"
    RightContainer.Size = UDim2.new(0, 240, 0, 26)
    RightContainer.Position = UDim2.new(1, -250, 0.5, -13)
    RightContainer.BackgroundTransparency = 1
    RightContainer.Parent = Header

    local RightLayout = Instance.new("UIListLayout")
    RightLayout.FillDirection = Enum.FillDirection.Horizontal
    RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    RightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Padding = UDim.new(0, 8)
    RightLayout.Parent = RightContainer

    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Size = UDim2.new(0, 150, 0, 26)
    SearchFrame.BackgroundColor3 = Library.Theme.Background
    SearchFrame.Parent = RightContainer

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 5)
    SearchCorner.Parent = SearchFrame

    local SearchStroke = Instance.new("UIStroke")
    SearchStroke.Color = Library.Theme.Stroke
    SearchStroke.Thickness = 1
    SearchStroke.Parent = SearchFrame

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Size = UDim2.new(0, 12, 0, 12)
    SearchIcon.Position = UDim2.new(0, 6, 0.5, -6)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = "rbxassetid://118685771787843"
    SearchIcon.ImageColor3 = Library.Theme.TextDim
    SearchIcon.Parent = SearchFrame

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -26, 1, 0)
    SearchBox.Position = UDim2.new(0, 22, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 90)
    SearchBox.TextColor3 = Library.Theme.Text
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 11
    SearchBox.Parent = SearchFrame

    local SettingsBtn = Instance.new("ImageButton")
    SettingsBtn.Name = "SettingsBtn"
    SettingsBtn.Size = UDim2.new(0, 26, 0, 26)
    SettingsBtn.BackgroundColor3 = Library.Theme.Background
    SettingsBtn.Image = "rbxassetid://103884184213243"
    SettingsBtn.ImageColor3 = Library.Theme.TextDim
    SettingsBtn.Parent = RightContainer

    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 5)
    SettingsCorner.Parent = SettingsBtn

    local SettingsStroke = Instance.new("UIStroke")
    SettingsStroke.Color = Library.Theme.Stroke
    SettingsStroke.Thickness = 1
    SettingsStroke.Parent = SettingsBtn

    local PagesFolder = Instance.new("Frame")
    PagesFolder.Name = "PagesFolder"
    PagesFolder.Size = UDim2.new(1, -24, 1, -65)
    PagesFolder.Position = UDim2.new(0, 12, 0, 55)
    PagesFolder.BackgroundTransparency = 1
    PagesFolder.Parent = MainFrame

    local function showPage(tabName)
        for name, page in pairs(Main.Pages) do
            local tabAsset = Main.Tabs[name]
            if name == tabName then
                page.Visible = true
                tween(tabAsset.Frame, 0.1, {BackgroundColor3 = Library.Theme.Accent})
                tween(tabAsset.Stroke, 0.1, {Color = Library.Theme.Accent})
                tween(tabAsset.Label, 0.1, {TextColor3 = Library.Theme.Text})
            else
                page.Visible = false
                tween(tabAsset.Frame, 0.1, {BackgroundColor3 = Library.Theme.Header})
                tween(tabAsset.Stroke, 0.1, {Color = Library.Theme.Stroke})
                tween(tabAsset.Label, 0.1, {TextColor3 = Library.Theme.TextDim})
            end
        end
    end

    -- Умный поиск (Сканирует окна, секции и даже подписи)
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, page in pairs(Main.Pages) do
            for _, column in ipairs({page:FindFirstChild("LeftColumn"), page:FindFirstChild("RightColumn")}) do
                if column then
                    for _, window in ipairs(column:GetChildren()) do
                        if window:IsA("Frame") then
                            local winTitle = window:FindFirstChild("WindowTitle")
                            if winTitle then
                                local match = false
                                if string.find(string.lower(winTitle.Text), query) then
                                    match = true
                                else
                                    local elements = window:FindFirstChild("Elements")
                                    if elements then
                                        for _, elem in ipairs(elements:GetChildren()) do
                                            if elem:IsA("Frame") or elem:IsA("TextButton") then
                                                local secTitle = elem:FindFirstChild("SectionTitle")
                                                if secTitle and string.find(string.lower(secTitle.Text), query) then
                                                    match = true
                                                end
                                                local lbl = elem:FindFirstChild("Label") or elem:FindFirstChild("TextLabel") or (elem:IsA("TextButton") and elem)
                                                if lbl and string.find(string.lower(lbl.Text), query) then
                                                    match = true
                                                end
                                            end
                                        end
                                    end
                                end
                                window.Visible = (query == "" or match)
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Функция-генератор элементов (чтобы не дублировать код для окон и секций)
    local function createElementsSystem(container)
        local Elements = {}

        -- [[ КНОПКА ]] --
        function Elements:CreateButton(btnText, callback)
            callback = callback or function() end

            local Button = Instance.new("TextButton")
            Button.Name = btnText .. "Btn"
            Button.Size = UDim2.new(1, 0, 0, 26)
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
            Button.Text = btnText
            Button.TextColor3 = Library.Theme.TextDim
            Button.Font = Enum.Font.GothamMedium
            Button.TextSize = 11
            Button.Parent = container

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = Button

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Library.Theme.Stroke
            BtnStroke.Thickness = 1
            BtnStroke.Parent = Button

            Button.MouseEnter:Connect(function()
                tween(BtnStroke, 0.1, {Color = Color3.fromRGB(80, 80, 95)})
                tween(Button, 0.1, {TextColor3 = Library.Theme.Text})
            end)
            Button.MouseLeave:Connect(function()
                tween(BtnStroke, 0.1, {Color = Library.Theme.Stroke})
                tween(Button, 0.1, {TextColor3 = Library.Theme.TextDim})
            end)
            Button.MouseButton1Click:Connect(function()
                tween(BtnStroke, 0.05, {Color = Library.Theme.Accent})
                task.wait(0.06)
                tween(BtnStroke, 0.05, {Color = Color3.fromRGB(80, 80, 95)})
                callback()
            end)
            return Button
        end

        -- [[ ТУГГЛ ]] --
        function Elements:CreateToggle(toggleText, default, callback)
            callback = callback or function() end
            local state = default or false

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = toggleText .. "Toggle"
            ToggleFrame.Size = UDim2.new(1, 0, 0, 26)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.Parent = container

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -30, 1, 0)
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
            Box.BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(30, 30, 36)
            Box.Text = ""
            Box.Parent = ToggleFrame

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = Box

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Color = state and Library.Theme.Accent or Library.Theme.Stroke
            BoxStroke.Thickness = 1
            BoxStroke.Parent = Box

            Box.MouseButton1Click:Connect(function()
                state = not state
                tween(Box, 0.1, {BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(30, 30, 36)})
                tween(BoxStroke, 0.1, {Color = state and Library.Theme.Accent or Library.Theme.Stroke})
                callback(state)
            end)
            return ToggleFrame
        end

        -- [[ СЛАЙДЕР ]] --
        function Elements:CreateSlider(sliderText, min, max, default, callback)
            callback = callback or function() end
            local val = default or min

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = sliderText .. "Slider"
            SliderFrame.Size = UDim2.new(1, 0, 0, 34)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.Parent = container

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.7, 0, 0, 16)
            Label.BackgroundTransparency = 1
            Label.Text = sliderText
            Label.TextColor3 = Library.Theme.TextDim
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0.3, 0, 0, 16)
            ValLabel.Position = UDim2.new(0.7, 0, 0, 0)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(val)
            ValLabel.TextColor3 = Library.Theme.Text
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextSize = 11
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.Parent = SliderFrame

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, 0, 0, 4)
            Track.Position = UDim2.new(0, 0, 0, 24)
            Track.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
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
            return SliderFrame
        end

        -- [[ ТЕКСТ БОКС ]] --
        function Elements:CreateTextBox(textBoxText, placeholder, callback)
            callback = callback or function() end
            placeholder = placeholder or "Type..."

            local TextFrame = Instance.new("Frame")
            TextFrame.Name = textBoxText .. "TextBox"
            TextFrame.Size = UDim2.new(1, 0, 0, 28)
            TextFrame.BackgroundTransparency = 1
            TextFrame.Parent = container

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -110, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = textBoxText
            Label.TextColor3 = Library.Theme.TextDim
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = TextFrame

            local BoxBg = Instance.new("Frame")
            BoxBg.Size = UDim2.new(0, 100, 0, 22)
            BoxBg.Position = UDim2.new(1, -100, 0.5, -11)
            BoxBg.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
            BoxBg.Parent = TextFrame

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = BoxBg

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Color = Library.Theme.Stroke
            BoxStroke.Thickness = 1
            BoxStroke.Parent = BoxBg

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(1, -12, 1, 0)
            TextBox.Position = UDim2.new(0, 6, 0, 0)
            TextBox.BackgroundTransparency = 1
            TextBox.Text = ""
            TextBox.PlaceholderText = placeholder
            TextBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 90)
            TextBox.TextColor3 = Library.Theme.Text
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 10
            TextBox.TextXAlignment = Enum.TextXAlignment.Left
            TextBox.ClipsDescendants = true
            TextBox.Parent = BoxBg

            TextBox.Focused:Connect(function()
                tween(BoxStroke, 0.1, {Color = Library.Theme.Accent})
            end)

            TextBox.FocusLost:Connect(function(enterPressed)
                tween(BoxStroke, 0.1, {Color = Library.Theme.Stroke})
                callback(TextBox.Text, enterPressed)
            end)
            return TextFrame
        end

        return Elements
    end

    function Main:CreateTab(tabName)
        local Tab = {}

        local TabFrame = Instance.new("Frame")
        TabFrame.Name = tabName .. "TabFrame"
        TabFrame.Size = UDim2.new(0, 85, 0, 26)
        TabFrame.BackgroundColor3 = Library.Theme.Header
        TabFrame.Parent = TabsScroll

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 5)
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
        TabLabel.TextSize = 10
        TabLabel.Parent = TabFrame

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 1, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = TabFrame

        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Library.Theme.Stroke
        Page.Visible = false
        Page.ScrollingDirection = Enum.ScrollingDirection.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Parent = PagesFolder

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingLeft = UDim.new(0, 4)
        PagePadding.PaddingRight = UDim.new(0, 4)
        PagePadding.PaddingTop = UDim.new(0, 4)
        PagePadding.PaddingBottom = UDim.new(0, 12)
        PagePadding.Parent = Page

        -- Левая колонка окон
        local LeftColumn = Instance.new("Frame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Size = UDim2.new(0.5, -6, 0, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
        LeftColumn.Parent = Page

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 12)
        LeftLayout.Parent = LeftColumn

        -- Правая колонка окон
        local RightColumn = Instance.new("Frame")
        RightColumn.Name = "RightColumn"
        RightColumn.Size = UDim2.new(0.5, -6, 0, 0)
        RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.AutomaticSize = Enum.AutomaticSize.Y
        RightColumn.Parent = Page

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 12)
        RightLayout.Parent = RightColumn

        local windowCount = 0

        Main.Tabs[tabName] = {Frame = TabFrame, Stroke = TabStroke, Label = TabLabel}
        Main.Pages[tabName] = Page

        TabBtn.MouseButton1Click:Connect(function()
            showPage(tabName)
        end)

        if not Main.CurrentTab then
            Main.CurrentTab = tabName
            showPage(tabName)
        end

        function Tab:CreateWindow(windowName)
            local Window = {}
            windowCount = windowCount + 1

            -- Сама карточка окна
            local WindowFrame = Instance.new("Frame")
            WindowFrame.Name = windowName .. "Window"
            WindowFrame.Size = UDim2.new(1, 0, 0, 0) 
            WindowFrame.BackgroundColor3 = Library.Theme.Card
            WindowFrame.AutomaticSize = Enum.AutomaticSize.Y
            WindowFrame.Parent = (windowCount % 2 == 1) and LeftColumn or RightColumn

            local WindowCorner = Instance.new("UICorner")
            WindowCorner.CornerRadius = UDim.new(0, 6)
            WindowCorner.Parent = WindowFrame

            local WindowStroke = Instance.new("UIStroke")
            WindowStroke.Color = Library.Theme.Stroke
            WindowStroke.Thickness = 1
            WindowStroke.Parent = WindowFrame

            -- Вертикальный премиум индикатор у заголовка
            local TitleIndicator = Instance.new("Frame")
            TitleIndicator.Name = "Indicator"
            TitleIndicator.Size = UDim2.new(0, 2, 0, 12)
            TitleIndicator.Position = UDim2.new(0, 10, 0, 10)
            TitleIndicator.BackgroundColor3 = Library.Theme.Accent
            TitleIndicator.BorderSizePixel = 0
            TitleIndicator.Parent = WindowFrame

            local WindowTitle = Instance.new("TextLabel")
            WindowTitle.Name = "WindowTitle"
            WindowTitle.Size = UDim2.new(1, -24, 0, 32)
            WindowTitle.Position = UDim2.new(0, 18, 0, 0)
            WindowTitle.BackgroundTransparency = 1
            WindowTitle.Text = windowName
            WindowTitle.TextColor3 = Library.Theme.Text
            WindowTitle.Font = Enum.Font.GothamBold
            WindowTitle.TextSize = 12
            WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
            WindowTitle.Parent = WindowFrame

            local ElementsContainer = Instance.new("Frame")
            ElementsContainer.Name = "Elements"
            ElementsContainer.Size = UDim2.new(1, -20, 0, 0)
            ElementsContainer.Position = UDim2.new(0, 10, 0, 32)
            ElementsContainer.BackgroundTransparency = 1
            ElementsContainer.AutomaticSize = Enum.AutomaticSize.Y
            ElementsContainer.Parent = WindowFrame

            local ElementsLayout = Instance.new("UIListLayout")
            ElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementsLayout.Padding = UDim.new(0, 6)
            ElementsLayout.Parent = ElementsContainer

            local Padding = Instance.new("UIPadding")
            Padding.PaddingBottom = UDim.new(0, 10)
            Padding.Parent = ElementsContainer

            -- Навешиваем базовые элементы на окно
            local WindowElements = createElementsSystem(ElementsContainer)
            for k, v in pairs(WindowElements) do
                Window[k] = v
            end

            -- [[ СОЗДАНИЕ СЕКЦИИ (Создает отдельную под-группу элементов) ]] --
            function Window:CreateSection(sectionName)
                local SectionFrame = Instance.new("Frame")
                SectionFrame.Name = sectionName .. "Section"
                SectionFrame.Size = UDim2.new(1, 0, 0, 0)
                SectionFrame.BackgroundColor3 = Library.Theme.Section
                SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
                SectionFrame.Parent = ElementsContainer

                local SectionCorner = Instance.new("UICorner")
                SectionCorner.CornerRadius = UDim.new(0, 5)
                SectionCorner.Parent = SectionFrame

                local SectionStroke = Instance.new("UIStroke")
                SectionStroke.Color = Color3.fromRGB(34, 34, 42)
                SectionStroke.Thickness = 1
                SectionStroke.Parent = SectionFrame

                -- Заголовок секции (мелкий капс)
                local SectionTitle = Instance.new("TextLabel")
                SectionTitle.Name = "SectionTitle"
                SectionTitle.Size = UDim2.new(1, -16, 0, 24)
                SectionTitle.Position = UDim2.new(0, 8, 0, 4)
                SectionTitle.BackgroundTransparency = 1
                SectionTitle.Text = string.upper(sectionName)
                SectionTitle.TextColor3 = Library.Theme.Accent
                SectionTitle.Font = Enum.Font.GothamBold
                SectionTitle.TextSize = 10
                SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
                SectionTitle.Parent = SectionFrame

                local SecElementsContainer = Instance.new("Frame")
                SecElementsContainer.Name = "SecElements"
                SecElementsContainer.Size = UDim2.new(1, -16, 0, 0)
                SecElementsContainer.Position = UDim2.new(0, 8, 0, 28)
                SecElementsContainer.BackgroundTransparency = 1
                SecElementsContainer.AutomaticSize = Enum.AutomaticSize.Y
                SecElementsContainer.Parent = SectionFrame

                local SecElementsLayout = Instance.new("UIListLayout")
                SecElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                SecElementsLayout.Padding = UDim.new(0, 6)
                SecElementsLayout.Parent = SecElementsContainer

                local SecPadding = Instance.new("UIPadding")
                SecPadding.PaddingBottom = UDim.new(0, 8)
                SecPadding.Parent = SecElementsContainer

                -- Навешиваем такие же элементы внутрь Секции
                return createElementsSystem(SecElementsContainer)
            end

            return Window
        end

        return Tab
    end

    return Main
end

return Library
