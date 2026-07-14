-- [[ VOLTECLIPSE / PREMIUM STYLE CLEAN UI LIBRARY (V2.2 - OPTIMIZED EDITION) ]] --
local Library = {}
Library.Theme = {
    Background = Color3.fromRGB(11, 11, 14),       
    Header = Color3.fromRGB(16, 16, 20),           
    Card = Color3.fromRGB(18, 18, 24),             
    Section = Color3.fromRGB(24, 24, 30),          
    Accent = Color3.fromRGB(145, 70, 255),         
    Stroke = Color3.fromRGB(32, 32, 40),           
    Text = Color3.fromRGB(255, 255, 255),          
    TextDim = Color3.fromRGB(140, 140, 150),       
}

local TabIcons = {
    Combat   = "rbxassetid://12614416478",      
    Movement = "rbxassetid://136160678435000", 
    Visuals  = "rbxassetid://102976018150012", 
    Misc     = "rbxassetid://137382232901580", 
    World    = "rbxassetid://107448093571441", 
    Auto     = "rbxassetid://17119858971"      
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
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

-- Функция транслитерации для поиска на любой раскладке клавиатуры
local function cleanSearchText(text)
    local query = string.lower(text)
    
    local ru_to_en = {
        ["й"]="q", ["ц"]="w", ["у"]="e", ["к"]="r", ["е"]="t", ["н"]="y", ["г"]="u", ["ш"]="i", ["щ"]="o", ["з"]="p", ["х"]="[", ["ъ"]="]",
        ["ф"]="a", ["ы"]="s", ["в"]="d", ["а"]="f", ["п"]="g", ["р"]="h", ["о"]="j", ["л"]="k", ["д"]="l", ["ж"]=";", ["э"]="'",
        ["я"]="z", ["ч"]="x", ["с"]="c", ["м"]="v", ["и"]="b", ["т"]="n", ["ь"]="m", ["б"]=",", ["ю"]="."
    }
    
    local cyr_to_lat = {
        ["а"]="a", ["в"]="b", ["с"]="c", ["е"]="e", ["н"]="h", ["к"]="k", 
        ["м"]="m", ["о"]="o", ["р"]="p", ["т"]="t", ["у"]="y", ["х"]="x"
    }
    
    local layout_query = ""
    local visual_query = ""
    
    for _, code in ipairs({utf8.codepoint(query, 1, -1)}) do
        local char = utf8.char(code)
        layout_query = layout_query .. (ru_to_en[char] or char)
        visual_query = visual_query .. (cyr_to_lat[char] or char)
    end
    
    return query, layout_query, visual_query
end

function Library:Init()
    local Main = {
        CurrentTab = nil,
        Tabs = {},
        Pages = {},
        Visible = true
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VoltEclipseLibrary"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = ParentContainer

    -- Главный фрейм теперь фиксирован по ширине (500px), чтобы вкладки не сжимались
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Size = UDim2.new(0, 500, 0, 420)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundTransparency = 1 
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local robloxMenuOpen = false
    
    local function toggleMenu(state)
        Main.Visible = state
        ScreenGui.Enabled = Main.Visible
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggleMenu(not Main.Visible)
        end
    end)

    GuiService.MenuOpened:Connect(function()
        if Main.Visible then
            toggleMenu(false)
            robloxMenuOpen = true
        end
    end)

    GuiService.MenuClosed:Connect(function()
        if robloxMenuOpen then
            toggleMenu(true)
            robloxMenuOpen = false
        end
    end)

    -- Хедер
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Library.Theme.Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 6)
    HeaderCorner.Parent = Header

    local HeaderStroke = Instance.new("UIStroke")
    HeaderStroke.Color = Library.Theme.Stroke
    HeaderStroke.Thickness = 1
    HeaderStroke.Parent = Header

    makeDraggable(MainFrame, Header)

    local Logo = Instance.new("ImageLabel")
    Logo.Name = "ProjectLogo"
    Logo.Size = UDim2.new(0, 18, 0, 18)
    Logo.Position = UDim2.new(0, 12, 0.5, -9)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://7015953925"
    Logo.Parent = Header

    local TabsScroll = Instance.new("ScrollingFrame")
    TabsScroll.Name = "TabsScroll"
    TabsScroll.Size = UDim2.new(1, -196, 0, 26)
    TabsScroll.Position = UDim2.new(0, 42, 0.5, -13)
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
    TabsLayout.Padding = UDim.new(0, 5)
    TabsLayout.Parent = TabsScroll

    local RightContainer = Instance.new("Frame")
    RightContainer.Name = "RightContainer"
    RightContainer.Size = UDim2.new(0, 140, 0, 24)
    RightContainer.Position = UDim2.new(1, -152, 0.5, -12)
    RightContainer.BackgroundTransparency = 1
    RightContainer.Parent = Header

    local RightLayout = Instance.new("UIListLayout")
    RightLayout.FillDirection = Enum.FillDirection.Horizontal
    RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    RightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Padding = UDim.new(0, 6)
    RightLayout.Parent = RightContainer

    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Size = UDim2.new(0, 110, 0, 24)
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
    SearchIcon.Size = UDim2.new(0, 10, 0, 10)
    SearchIcon.Position = UDim2.new(0, 6, 0.5, -5)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = "rbxassetid://118685771787843"
    SearchIcon.ImageColor3 = Library.Theme.TextDim
    SearchIcon.Parent = SearchFrame

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -22, 1, 0)
    SearchBox.Position = UDim2.new(0, 18, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 90)
    SearchBox.TextColor3 = Library.Theme.Text
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 10
    SearchBox.Parent = SearchFrame

    local SettingsBtn = Instance.new("ImageButton")
    SettingsBtn.Name = "SettingsBtn"
    SettingsBtn.Size = UDim2.new(0, 24, 0, 24)
    SettingsBtn.BackgroundColor3 = Library.Theme.Background
    SettingsBtn.Image = "rbxassetid://7059346373"
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
    PagesFolder.Size = UDim2.new(1, 0, 1, -46)
    PagesFolder.Position = UDim2.new(0, 0, 0, 46)
    PagesFolder.BackgroundTransparency = 1
    PagesFolder.Parent = MainFrame

    -- Функция умного центрирования колонок (240px)
    local function updateLayout(tabName)
        local pageInfo = Main.Pages[tabName]
        if not pageInfo then return end

        local data = pageInfo.Data
        if data.WindowCount <= 1 then
            -- Одно окно: колонка шириной 240px встает ровно по центру
            data.LeftColumn.Size = UDim2.new(0, 240, 1, 0)
            data.LeftColumn.Position = UDim2.new(0.5, -120, 0, 0)
            data.RightColumn.Visible = false
        else
            -- Несколько окон: две колонки по 240px распределяются по бокам
            data.LeftColumn.Size = UDim2.new(0, 240, 1, 0)
            data.LeftColumn.Position = UDim2.new(0.5, -245, 0, 0)
            
            data.RightColumn.Size = UDim2.new(0, 240, 1, 0)
            data.RightColumn.Position = UDim2.new(0.5, 5, 0, 0)
            data.RightColumn.Visible = true
        end
    end

    local function showPage(tabName)
        Main.CurrentTab = tabName
        for name, pageInfo in pairs(Main.Pages) do
            local page = pageInfo.Page
            local tabAsset = Main.Tabs[name]
            local tabIcon = tabAsset.Frame:FindFirstChild("TabIcon")
            if name == tabName then
                page.Visible = true
                tween(tabAsset.Frame, 0.1, {BackgroundColor3 = Library.Theme.Accent})
                tween(tabAsset.Stroke, 0.1, {Color = Library.Theme.Accent})
                tween(tabAsset.Label, 0.1, {TextColor3 = Library.Theme.Text})
                if tabIcon then tween(tabIcon, 0.1, {ImageColor3 = Library.Theme.Text}) end
            else
                page.Visible = false
                tween(tabAsset.Frame, 0.1, {BackgroundColor3 = Library.Theme.Header})
                tween(tabAsset.Stroke, 0.1, {Color = Library.Theme.Stroke})
                tween(tabAsset.Label, 0.1, {TextColor3 = Library.Theme.TextDim})
                if tabIcon then tween(tabIcon, 0.1, {ImageColor3 = Library.Theme.TextDim}) end
            end
        end
        updateLayout(tabName)
    end

    -- Улучшенный сквозной поиск (ищет везде и переключает вкладки сам)
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local rawQuery = SearchBox.Text
        if rawQuery == "" then
            for _, pageInfo in pairs(Main.Pages) do
                local data = pageInfo.Data
                for _, column in ipairs({data.LeftColumn, data.RightColumn}) do
                    for _, window in ipairs(column:GetChildren()) do
                        if window:IsA("Frame") then
                            window.Visible = true
                        end
                    end
                end
            end
            return
        end

        local q1, q2, q3 = cleanSearchText(rawQuery)
        local firstMatchingTab = nil

        for tabName, pageInfo in pairs(Main.Pages) do
            local data = pageInfo.Data
            local tabHasMatch = false
            
            for _, column in ipairs({data.LeftColumn, data.RightColumn}) do
                for _, window in ipairs(column:GetChildren()) do
                    if window:IsA("Frame") then
                        local winTitle = window:FindFirstChild("WindowTitle")
                        if winTitle then
                            local titleText = string.lower(winTitle.Text)
                            local match = string.find(titleText, q1) or string.find(titleText, q2) or string.find(titleText, q3)
                            
                            if not match then
                                local elements = window:FindFirstChild("Elements")
                                if elements then
                                    for _, elem in ipairs(elements:GetChildren()) do
                                        if elem:IsA("Frame") or elem:IsA("TextButton") then
                                            local secTitle = elem:FindFirstChild("SectionTitle")
                                            if secTitle then
                                                local secText = string.lower(secTitle.Text)
                                                if string.find(secText, q1) or string.find(secText, q2) or string.find(secText, q3) then
                                                    match = true
                                                    break
                                                end
                                            end
                                            
                                            local lbl = elem:FindFirstChild("Label") or elem:FindFirstChild("TextLabel")
                                            if not lbl and elem:IsA("TextButton") then
                                                lbl = elem
                                            end
                                            if lbl then
                                                local lblText = string.lower(lbl.Text)
                                                if string.find(lblText, q1) or string.find(lblText, q2) or string.find(lblText, q3) then
                                                    match = true
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            
                            window.Visible = match
                            if match then
                                tabHasMatch = true
                            end
                        end
                    end
                end
            end
            
            if tabHasMatch and not firstMatchingTab then
                firstMatchingTab = tabName
            end
        end

        -- Автоматически переходим на вкладку, где нашлось совпадение
        if firstMatchingTab and Main.CurrentTab ~= firstMatchingTab then
            showPage(firstMatchingTab)
        end
    end)

    -- Создание компактных элементов без пустот
    local function createElementsSystem(container)
        local Elements = {}

        -- Кнопка (Button)
        function Elements:CreateButton(btnText, callback)
            callback = callback or function() end

            local Button = Instance.new("TextButton")
            Button.Name = btnText .. "Btn"
            Button.Size = UDim2.new(1, 0, 0, 24)
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

        -- Тоггл (Toggle) - Флажок слева, текст сразу справа, без пустых зон
        function Elements:CreateToggle(toggleText, default, callback)
            callback = callback or function() end
            local state = default or false

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Name = toggleText .. "Toggle"
            ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Parent = container

            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(0, 14, 0, 14)
            Box.Position = UDim2.new(0, 2, 0.5, -7)
            Box.BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(30, 30, 36)
            Box.BorderSizePixel = 0
            Box.Parent = ToggleFrame

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 3)
            BoxCorner.Parent = Box

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Color = state and Library.Theme.Accent or Library.Theme.Stroke
            BoxStroke.Thickness = 1
            BoxStroke.Parent = Box

            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Size = UDim2.new(1, -24, 1, 0)
            Label.Position = UDim2.new(0, 24, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = toggleText
            Label.TextColor3 = state and Library.Theme.Text or Library.Theme.TextDim
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame

            local function toggle()
                state = not state
                tween(Box, 0.1, {BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(30, 30, 36)})
                tween(BoxStroke, 0.1, {Color = state and Library.Theme.Accent or Library.Theme.Stroke})
                tween(Label, 0.1, {TextColor3 = state and Library.Theme.Text or Library.Theme.TextDim})
                callback(state)
            end

            ToggleFrame.MouseButton1Click:Connect(toggle)

            ToggleFrame.MouseEnter:Connect(function()
                if not state then
                    tween(Label, 0.1, {TextColor3 = Library.Theme.Text})
                    tween(BoxStroke, 0.1, {Color = Color3.fromRGB(80, 80, 95)})
                end
            end)
            ToggleFrame.MouseLeave:Connect(function()
                if not state then
                    tween(Label, 0.1, {TextColor3 = Library.Theme.TextDim})
                    tween(BoxStroke, 0.1, {Color = Library.Theme.Stroke})
                end
            end)

            return ToggleFrame
        end

        -- Однострочный Слайдер (Slider) - Все на одной линии, без пустот
        function Elements:CreateSlider(sliderText, min, max, default, callback)
            callback = callback or function() end
            local val = default or min

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = sliderText .. "Slider"
            SliderFrame.Size = UDim2.new(1, 0, 0, 24)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.Parent = container

            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Size = UDim2.new(0.4, -5, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = sliderText
            Label.TextColor3 = Library.Theme.TextDim
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(0.6, -45, 0, 4)
            Track.Position = UDim2.new(0.4, 5, 0.5, -2)
            Track.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
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

            local Thumb = Instance.new("Frame")
            Thumb.Name = "Thumb"
            Thumb.Size = UDim2.new(0, 9, 0, 9)
            Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
            Thumb.Position = UDim2.new((val - min) / (max - min), 0, 0.5, 0)
            Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Thumb.Parent = Track

            local ThumbCorner = Instance.new("UICorner")
            ThumbCorner.CornerRadius = UDim.new(1, 0)
            ThumbCorner.Parent = Thumb

            local ThumbStroke = Instance.new("UIStroke")
            ThumbStroke.Color = Library.Theme.Accent
            ThumbStroke.Thickness = 1.5
            ThumbStroke.Parent = Thumb

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0, 35, 1, 0)
            ValLabel.Position = UDim2.new(1, -35, 0, 0)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(val)
            ValLabel.TextColor3 = Library.Theme.Text
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextSize = 11
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.Parent = SliderFrame

            local isDragging = false
            local function update(input)
                local percentage = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                val = math.round(min + ((max - min) * percentage))
                Fill.Size = UDim2.new(percentage, 0, 1, 0)
                Thumb.Position = UDim2.new(percentage, 0, 0.5, 0)
                ValLabel.Text = tostring(val)
                callback(val)
            end

            SliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    update(input)
                    tween(Thumb, 0.1, {Size = UDim2.new(0, 11, 0, 11)})
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
                    tween(Thumb, 0.1, {Size = UDim2.new(0, 9, 0, 9)})
                end
            end)
            
            SliderFrame.MouseEnter:Connect(function()
                tween(Label, 0.1, {TextColor3 = Library.Theme.Text})
            end)
            SliderFrame.MouseLeave:Connect(function()
                if not isDragging then
                    tween(Label, 0.1, {TextColor3 = Library.Theme.TextDim})
                end
            end)

            return SliderFrame
        end

        -- Текстовое Поле (TextBox) - Вплотную к названию, без пустот
        function Elements:CreateTextBox(textBoxText, placeholder, callback)
            callback = callback or function() end
            placeholder = placeholder or "Type..."

            local TextFrame = Instance.new("Frame")
            TextFrame.Name = textBoxText .. "TextBox"
            TextFrame.Size = UDim2.new(1, 0, 0, 24)
            TextFrame.BackgroundTransparency = 1
            TextFrame.Parent = container

            local TextLayout = Instance.new("UIListLayout")
            TextLayout.FillDirection = Enum.FillDirection.Horizontal
            TextLayout.SortOrder = Enum.SortOrder.LayoutOrder
            TextLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            TextLayout.Padding = UDim.new(0, 8)
            TextLayout.Parent = TextFrame

            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Size = UDim2.new(0, 0, 1, 0)
            Label.AutomaticSize = Enum.AutomaticSize.X
            Label.BackgroundTransparency = 1
            Label.Text = textBoxText
            Label.TextColor3 = Library.Theme.TextDim
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = TextFrame

            local BoxBg = Instance.new("Frame")
            BoxBg.Size = UDim2.new(0, 110, 0, 20)
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
            TextBox.Size = UDim2.new(1, -10, 1, 0)
            TextBox.Position = UDim2.new(0, 5, 0, 0)
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
                tween(Label, 0.1, {TextColor3 = Library.Theme.Text})
            end)

            TextBox.FocusLost:Connect(function(enterPressed)
                tween(BoxStroke, 0.1, {Color = Library.Theme.Stroke})
                tween(Label, 0.1, {TextColor3 = Library.Theme.TextDim})
                callback(TextBox.Text, enterPressed)
            end)
            return TextFrame
        end

        return Elements
    end

    function Main:CreateTab(tabName)
        local Tab = {}

        local TabFrame = Instance.new("TextButton")
        TabFrame.Name = tabName .. "TabFrame"
        TabFrame.Size = UDim2.new(0, 0, 0, 24)
        TabFrame.BackgroundColor3 = Library.Theme.Header
        TabFrame.Text = ""
        TabFrame.AutoButtonColor = false
        TabFrame.AutomaticSize = Enum.AutomaticSize.X
        TabFrame.Parent = TabsScroll

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 5)
        TabCorner.Parent = TabFrame

        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = Library.Theme.Stroke
        TabStroke.Thickness = 1
        TabStroke.Parent = TabFrame

        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingLeft = UDim.new(0, 8)
        TabPadding.PaddingRight = UDim.new(0, 8)
        TabPadding.Parent = TabFrame

        local TabListLayout = Instance.new("UIListLayout")
        TabListLayout.FillDirection = Enum.FillDirection.Horizontal
        TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        TabListLayout.Padding = UDim.new(0, 5)
        TabListLayout.Parent = TabFrame

        local matchedIcon = nil
        for name, id in pairs(TabIcons) do
            if string.lower(name) == string.lower(tabName) then
                matchedIcon = id
                break
            end
        end

        if matchedIcon then
            local TabIcon = Instance.new("ImageLabel")
            TabIcon.Name = "TabIcon"
            TabIcon.Size = UDim2.new(0, 12, 0, 12)
            TabIcon.BackgroundTransparency = 1
            TabIcon.Image = matchedIcon
            TabIcon.ImageColor3 = Library.Theme.TextDim
            TabIcon.LayoutOrder = 1
            TabIcon.Parent = TabFrame
        end

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(0, 0, 1, 0)
        TabLabel.AutomaticSize = Enum.AutomaticSize.X
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = string.upper(tabName)
        TabLabel.TextColor3 = Library.Theme.TextDim
        TabLabel.Font = Enum.Font.GothamBold
        TabLabel.TextSize = 9
        TabLabel.LayoutOrder = 2
        TabLabel.Parent = TabFrame

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
        PagePadding.PaddingLeft = UDim.new(0, 6)
        PagePadding.PaddingRight = UDim.new(0, 6)
        PagePadding.PaddingTop = UDim.new(0, 6)
        PagePadding.PaddingBottom = UDim.new(0, 12)
        PagePadding.Parent = Page

        local LeftColumn = Instance.new("Frame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Size = UDim2.new(0, 240, 0, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
        LeftColumn.Parent = Page

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 8)
        LeftLayout.Parent = LeftColumn

        local RightColumn = Instance.new("Frame")
        RightColumn.Name = "RightColumn"
        RightColumn.Size = UDim2.new(0, 240, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.AutomaticSize = Enum.AutomaticSize.Y
        RightColumn.Parent = Page

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 8)
        RightLayout.Parent = RightColumn

        local PageData = {
            WindowCount = 0,
            LeftColumn = LeftColumn,
            RightColumn = RightColumn
        }

        Main.Tabs[tabName] = {Frame = TabFrame, Stroke = TabStroke, Label = TabLabel}
        Main.Pages[tabName] = {Page = Page, Data = PageData}

        TabFrame.MouseButton1Click:Connect(function()
            showPage(tabName)
        end)

        if not Main.CurrentTab then
            Main.CurrentTab = tabName
            showPage(tabName)
        end

        function Tab:CreateWindow(windowName)
            local Window = {}
            PageData.WindowCount = PageData.WindowCount + 1

            local WindowFrame = Instance.new("Frame")
            WindowFrame.Name = windowName .. "Window"
            WindowFrame.Size = UDim2.new(1, 0, 0, 0) 
            WindowFrame.BackgroundColor3 = Library.Theme.Card
            WindowFrame.AutomaticSize = Enum.AutomaticSize.Y
            WindowFrame.Parent = (PageData.WindowCount % 2 == 1) and LeftColumn or RightColumn

            -- Рассчитываем сетку и центрирование
            updateLayout(tabName)

            local WindowCorner = Instance.new("UICorner")
            WindowCorner.CornerRadius = UDim.new(0, 5)
            WindowCorner.Parent = WindowFrame

            local WindowStroke = Instance.new("UIStroke")
            WindowStroke.Color = Library.Theme.Stroke
            WindowStroke.Thickness = 1
            WindowStroke.Parent = WindowFrame

            local TitleIndicator = Instance.new("Frame")
            TitleIndicator.Name = "Indicator"
            TitleIndicator.Size = UDim2.new(0, 2, 0, 10)
            TitleIndicator.Position = UDim2.new(0, 8, 0, 9)
            TitleIndicator.BackgroundColor3 = Library.Theme.Accent
            TitleIndicator.BorderSizePixel = 0
            TitleIndicator.Parent = WindowFrame

            local WindowTitle = Instance.new("TextLabel")
            WindowTitle.Name = "WindowTitle"
            WindowTitle.Size = UDim2.new(1, -20, 0, 28)
            WindowTitle.Position = UDim2.new(0, 14, 0, 0)
            WindowTitle.BackgroundTransparency = 1
            WindowTitle.Text = windowName
            WindowTitle.TextColor3 = Library.Theme.Text
            WindowTitle.Font = Enum.Font.GothamBold
            WindowTitle.TextSize = 11
            WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
            WindowTitle.Parent = WindowFrame

            local ElementsContainer = Instance.new("Frame")
            ElementsContainer.Name = "Elements"
            ElementsContainer.Size = UDim2.new(1, -16, 0, 0)
            ElementsContainer.Position = UDim2.new(0, 8, 0, 28)
            ElementsContainer.BackgroundTransparency = 1
            ElementsContainer.AutomaticSize = Enum.AutomaticSize.Y
            ElementsContainer.Parent = WindowFrame

            local ElementsLayout = Instance.new("UIListLayout")
            ElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementsLayout.Padding = UDim.new(0, 5)
            ElementsLayout.Parent = ElementsContainer

            local Padding = Instance.new("UIPadding")
            Padding.PaddingBottom = UDim.new(0, 8)
            Padding.Parent = ElementsContainer

            local WindowElements = createElementsSystem(ElementsContainer)
            for k, v in pairs(WindowElements) do
                Window[k] = v
            end

            function Window:CreateSection(sectionName)
                local SectionFrame = Instance.new("Frame")
                SectionFrame.Name = sectionName .. "Section"
                SectionFrame.Size = UDim2.new(1, 0, 0, 0)
                SectionFrame.BackgroundColor3 = Library.Theme.Section
                SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
                SectionFrame.Parent = ElementsContainer

                local SectionCorner = Instance.new("UICorner")
                SectionCorner.CornerRadius = UDim.new(0, 4)
                SectionCorner.Parent = SectionFrame

                local SectionStroke = Instance.new("UIStroke")
                SectionStroke.Color = Color3.fromRGB(34, 34, 42)
                SectionStroke.Thickness = 1
                SectionStroke.Parent = SectionFrame

                local SectionTitle = Instance.new("TextLabel")
                SectionTitle.Name = "SectionTitle"
                SectionTitle.Size = UDim2.new(1, -12, 0, 20)
                SectionTitle.Position = UDim2.new(0, 6, 0, 3)
                SectionTitle.BackgroundTransparency = 1
                SectionTitle.Text = string.upper(sectionName)
                SectionTitle.TextColor3 = Library.Theme.Accent
                SectionTitle.Font = Enum.Font.GothamBold
                SectionTitle.TextSize = 9
                SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
                SectionTitle.Parent = SectionFrame

                local SecElementsContainer = Instance.new("Frame")
                SecElementsContainer.Name = "SecElements"
                SecElementsContainer.Size = UDim2.new(1, -12, 0, 0)
                SecElementsContainer.Position = UDim2.new(0, 6, 0, 23)
                SecElementsContainer.BackgroundTransparency = 1
                SecElementsContainer.AutomaticSize = Enum.AutomaticSize.Y
                SecElementsContainer.Parent = SectionFrame

                local SecElementsLayout = Instance.new("UIListLayout")
                SecElementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                SecElementsLayout.Padding = UDim.new(0, 5)
                SecElementsLayout.Parent = SecElementsContainer

                local SecPadding = Instance.new("UIPadding")
                SecPadding.PaddingBottom = UDim.new(0, 6)
                SecPadding.Parent = SecElementsContainer

                return createElementsSystem(SecElementsContainer)
            end

            return Window
        end

        return Tab
    end

    return Main
end

return Library
