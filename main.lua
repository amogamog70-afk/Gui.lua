-- [[ VOLTECLIPSE ПРЕМИУМ UI БИБЛИОТЕКА — ПОЛНЫЙ ФИКС ВЕРСТКИ ]] --
local Library = {}
Library.Theme = {
    Background = Color3.fromRGB(15, 15, 15),       
    Card = Color3.fromRGB(21, 21, 21),             
    Accent = Color3.fromRGB(145, 70, 255),         
    Stroke = Color3.fromRGB(35, 35, 35),           
    Text = Color3.fromRGB(255, 255, 255),          
    TextDim = Color3.fromRGB(140, 140, 140),       
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

    -- Главное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 780, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -390, 0.5, -240) 
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Library.Theme.Stroke
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    -- Хедер (Шапка)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Library.Theme.Background
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 6)
    HeaderCorner.Parent = Header

    -- Скрываем нижние углы хедера, чтобы они не вылезали в основное окно
    local HeaderLine = Instance.new("Frame")
    HeaderLine.Size = UDim2.new(1, 0, 0, 5)
    HeaderLine.Position = UDim2.new(0, 0, 1, -5)
    HeaderLine.BackgroundColor3 = Library.Theme.Background
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Parent = Header

    makeDraggable(MainFrame, Header)

    -- Логотип проекта VoltEclipse
    local Logo = Instance.new("ImageLabel")
    Logo.Name = "ProjectLogo"
    Logo.Size = UDim2.new(0, 24, 0, 24)
    Logo.Position = UDim2.new(0, 12, 0.5, -12)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://7015953925"
    Logo.Parent = Header

    -- Исправленный контейнер вкладок (Размер зафиксирован, скролл работает идеально)
    local TabsScroll = Instance.new("ScrollingFrame")
    TabsScroll.Name = "TabsScroll"
    TabsScroll.Size = UDim2.new(0, 400, 0, 28)
    TabsScroll.Position = UDim2.new(0, 48, 0.5, -14) -- Идеальное центрирование по оси Y
    TabsScroll.BackgroundTransparency = 1
    TabsScroll.BorderSizePixel = 0
    TabsScroll.ScrollBarThickness = 0
    TabsScroll.ScrollingDirection = Enum.ScrollingDirection.X
    TabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    TabsScroll.Parent = Header

    local TabsLayout = Instance.new("UIListLayout")
    TabsLayout.FillDirection = Enum.FillDirection.Horizontal
    TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    TabsLayout.Padding = UDim.new(0, 6)
    TabsLayout.Parent = TabsScroll

    -- Правый блок управления (Поиск + Шестеренка)
    local RightContainer = Instance.new("Frame")
    RightContainer.Name = "RightContainer"
    RightContainer.Size = UDim2.new(0, 220, 1, 0)
    RightContainer.Position = UDim2.new(1, -232, 0, 0)
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
    SearchFrame.Size = UDim2.new(0, 150, 0, 28)
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
    SearchBox.Size = UDim2.new(1, -30, 1, 0)
    SearchBox.Position = UDim2.new(0, 26, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(70, 70, 70)
    SearchBox.TextColor3 = Library.Theme.Text
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.Parent = SearchFrame

    -- НАСТРОЙКИ: Используем переданную тобой иконку шестеренки!
    local SettingsBtn = Instance.new("ImageButton")
    SettingsBtn.Name = "SettingsBtn"
    SettingsBtn.Size = UDim2.new(0, 28, 0, 28)
    SettingsBtn.BackgroundColor3 = Library.Theme.Card
    SettingsBtn.Image = "rbxassetid://103884184213243" -- Твой ассет настроек
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

    SettingsBtn.MouseEnter:Connect(function() tween(SettingsBtn, 0.1, {ImageColor3 = Library.Theme.Text}) end)
    SettingsBtn.MouseLeave:Connect(function() tween(SettingsBtn, 0.1, {ImageColor3 = Library.Theme.TextDim}) end)

    -- Главный контейнер страниц
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
                tween(tabAsset.Frame, 0.12, {BackgroundColor3 = Library.Theme.Accent})
                tween(tabAsset.Stroke, 0.12, {Color = Library.Theme.Accent})
                tween(tabAsset.Label, 0.12, {TextColor3 = Library.Theme.Text})
            else
                page.Visible = false
                tween(tabAsset.Frame, 0.12, {BackgroundColor3 = Library.Theme.Card})
                tween(tabAsset.Stroke, 0.12, {Color = Library.Theme.Stroke})
                tween(tabAsset.Label, 0.12, {TextColor3 = Library.Theme.TextDim})
            end
        end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, page in pairs(Main.Pages) do
            -- Ищем окна внутри левой и правой колонок
            for _, column in ipairs({page:FindFirstChild("LeftColumn"), page:FindFirstChild("RightColumn")}) do
                if column then
                    for _, window in ipairs(column:GetChildren()) do
                        if window:IsA("Frame") then
                            local winTitle = window:FindFirstChild("WindowTitle")
                            if winTitle then
                                window.Visible = string.find(string.lower(winTitle.Text), query) and true or false
                            end
                        end
                    end
                end
            end
        end
    end)

    -- [[ МЕТОД: СОЗДАНИЕ ВКЛАДКИ ]] --
    function Main:CreateTab(tabName)
        local Tab = { WindowCount = 0 }

        local TabFrame = Instance.new("Frame")
        TabFrame.Name = tabName .. "TabFrame"
        TabFrame.Size = UDim2.new(0, 85, 1, 0)
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

        -- Главный холст страницы со скроллингом вниз
        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 0
        Page.Visible = false
        Page.ScrollingDirection = Enum.ScrollingDirection.Y
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Parent = PagesFolder

        -- ДВУХКОЛОНОЧНЫЙ ДИЗАЙН (Замена баганного UIGridLayout)
        local LeftColumn = Instance.new("Frame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Size = UDim2.new(0.5, -7, 1, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.Parent = Page

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 12)
        LeftLayout.Parent = LeftColumn

        local RightColumn = Instance.new("Frame")
        RightColumn.Name = "RightColumn"
        RightColumn.Size = UDim2.new(0.5, -7, 1, 0)
        RightColumn.Position = UDim2.new(0.5, 7, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.Parent = Page

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 12)
        RightLayout.Parent = RightColumn

        Main.Tabs[tabName] = {Frame = TabFrame, Stroke = TabStroke, Label = TabLabel}
        Main.Pages[tabName] = Page

        TabBtn.MouseButton1Click:Connect(function() showPage(tabName) end)

        if not Main.CurrentTab then
            Main.CurrentTab = tabName
            showPage(tabName)
        end

        -- [[ МЕТОД: СОЗДАНИЕ ОКНА ]] --
        function Tab:CreateWindow(windowName)
            local Window = {}
            Tab.WindowCount = Tab.WindowCount + 1

            -- Автоматически распределяем окна: нечетные налево, четные направо
            local TargetColumn = (Tab.WindowCount % 2 ~= 0) and LeftColumn or RightColumn

            local WindowFrame = Instance.new("Frame")
            WindowFrame.Name = windowName .. "Window"
            WindowFrame.Size = UDim2.new(1, 0, 0, 100) -- Ширина заполняет колонку целиком!
            WindowFrame.BackgroundColor3 = Library.Theme.Card
            WindowFrame.Parent = TargetColumn

            local WindowCorner = Instance.new("UICorner")
            WindowCorner.CornerRadius = UDim.new(0, 5)
            WindowCorner.Parent = WindowFrame

            local WindowStroke = Instance.new("UIStroke")
            WindowStroke.Color = Library.Theme.Stroke
            WindowStroke.Thickness = 1
            WindowStroke.Parent = WindowFrame

            local WindowTitle = Instance.new("TextLabel")
            WindowTitle.Name = "WindowTitle"
            WindowTitle.Size = UDim2.new(1, -20, 0, 30)
            WindowTitle.Position = UDim2.new(0, 12, 0, 2)
            WindowTitle.BackgroundTransparency = 1
            WindowTitle.Text = windowName
            WindowTitle.TextColor3 = Library.Theme.Text
            WindowTitle.Font = Enum.Font.GothamBold
            WindowTitle.TextSize = 12
            WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
            WindowTitle.Parent = WindowFrame

            local ElementsContainer = Instance.new("Frame")
            ElementsContainer.Name = "Elements"
            ElementsContainer.Size = UDim2.new(1, -24, 1, -36)
            ElementsContainer.Position = UDim2.new(0, 12, 0, 32)
            ElementsContainer.BackgroundTransparency = 1
            ElementsContainer.Parent = WindowFrame

            local ElementsLayout = Instance.new("UIListLayout")
            ElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementsLayout.Padding = UDim.new(0, 6)
            ElementsLayout.Parent = ElementsContainer

            -- Динамический просчет высоты под контент окон
            ElementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                WindowFrame.Size = UDim2.new(1, 0, 0, ElementsLayout.AbsoluteContentSize.Y + 42)
            end)

            -- [[ ЭЛЕМЕНТ: КНОПКА ]] --
            function Window:CreateButton(btnText, callback)
                callback = callback or function() end

                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 0, 26)
                Button.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
                Button.Text = btnText
                Button.TextColor3 = Library.Theme.TextDim
                Button.Font = Enum.Font.Gotham
                Button.TextSize = 11
                Button.Parent = ElementsContainer

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 4)
                BtnCorner.Parent = Button

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Library.Theme.Stroke
                BtnStroke.Thickness = 1
                BtnStroke.Parent = Button

                Button.MouseEnter:Connect(function()
                    tween(BtnStroke, 0.1, {Color = Color3.fromRGB(70, 70, 70)})
                    tween(Button, 0.1, {TextColor3 = Library.Theme.Text})
                end)
                Button.MouseLeave:Connect(function()
                    tween(BtnStroke, 0.1, {Color = Library.Theme.Stroke})
                    tween(Button, 0.1, {TextColor3 = Library.Theme.TextDim})
                end)
                Button.MouseButton1Click:Connect(function()
                    tween(BtnStroke, 0.05, {Color = Library.Theme.Accent})
                    task.wait(0.06)
                    tween(BtnStroke, 0.05, {Color = Color3.fromRGB(70, 70, 70)})
                    callback()
                end)
            end

            -- [[ ЭЛЕМЕНТ: СЛАЙДЕР ]] --
            function Window:CreateSlider(sliderText, min, max, default, callback)
                callback = callback or function() end
                local val = default or min

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 32)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = ElementsContainer

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.7, 0, 0, 14)
                Label.BackgroundTransparency = 1
                Label.Text = sliderText
                Label.TextColor3 = Library.Theme.TextDim
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SliderFrame

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(0.3, 0, 0, 14)
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
                Track.Position = UDim2.new(0, 0, 0, 22)
                Track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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

            -- [[ ЭЛЕМЕНТ: ТУГГЛ ]] --
            function Window:CreateToggle(toggleText, default, callback)
                callback = callback or function() end
                local state = default or false

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = ElementsContainer

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
                Box.BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(26, 26, 26)
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
                    tween(Box, 0.1, {BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(26, 26, 26)})
                    tween(BoxStroke, 0.1, {Color = state and Library.Theme.Accent or Library.Theme.Stroke})
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
