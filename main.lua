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

    local function updateLayout(tabName)
        local pageInfo = Main.Pages[tabName]
        if not pageInfo then return end

        local data = pageInfo.Data
        if data.WindowCount <= 1 then
            data.LeftColumn.Size = UDim2.new(0, 240, 1, 0)
            data.LeftColumn.Position = UDim2.new(0.5, -120, 0, 0)
            data.RightColumn.Visible = false
        else
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

        if firstMatchingTab and Main.CurrentTab ~= firstMatchingTab then
            showPage(firstMatchingTab)
        end
    end)

    -- Создание компактных элементов без пустот
    local function createElementsSystem(container)
        local Elements = {}

        -- Локальный вспомогательный метод для инлайновых инструкций (Tooltip)
        local function addTooltip(parentFrame, text, yOffset)
            if not text or text == "" then return end
            
            local DotsBtn = Instance.new("TextButton")
            DotsBtn.Name = "DotsBtn"
            DotsBtn.Size = UDim2.new(0, 18, 0, 14)
            DotsBtn.Position = UDim2.new(1, -18, 0, (yOffset or 5))
            DotsBtn.BackgroundTransparency = 1
            DotsBtn.Text = "•••"
            DotsBtn.TextColor3 = Library.Theme.TextDim
            DotsBtn.Font = Enum.Font.GothamBold
            DotsBtn.TextSize = 10
            DotsBtn.Parent = parentFrame
            
            local InfoFrame = Instance.new("Frame")
            InfoFrame.Name = "InfoFrame"
            InfoFrame.Size = UDim2.new(1, 0, 0, 0)
            InfoFrame.Position = UDim2.new(0, 0, 0, 24)
            InfoFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
            InfoFrame.BackgroundTransparency = 0.4
            InfoFrame.AutomaticSize = Enum.AutomaticSize.Y
            InfoFrame.Visible = false
            InfoFrame.ClipsDescendants = true
            InfoFrame.Parent = parentFrame
            
            local InfoPadding = Instance.new("UIPadding")
            InfoPadding.PaddingLeft = UDim.new(0, 8)
            InfoPadding.PaddingRight = UDim.new(0, 8)
            InfoPadding.PaddingTop = UDim.new(0, 4)
            InfoPadding.PaddingBottom = UDim.new(0, 6)
            InfoPadding.Parent = InfoFrame
            
            local InfoLabel = Instance.new("TextLabel")
            InfoLabel.Size = UDim2.new(1, 0, 0, 0)
            InfoLabel.AutomaticSize = Enum.AutomaticSize.Y
            InfoLabel.BackgroundTransparency = 1
            InfoLabel.Text = text
            InfoLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
            InfoLabel.Font = Enum.Font.Gotham
            InfoLabel.TextSize = 10
            InfoLabel.TextWrapped = true
            InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
            InfoLabel.Parent = InfoFrame
            
            local InfoStroke = Instance.new("UIStroke")
            InfoStroke.Color = Color3.fromRGB(45, 45, 55)
            InfoStroke.Thickness = 1
            InfoStroke.Parent = InfoFrame
            
            local InfoCorner = Instance.new("UICorner")
            InfoCorner.CornerRadius = UDim.new(0, 4)
            InfoCorner.Parent = InfoFrame
            
            DotsBtn.MouseButton1Click:Connect(function()
                InfoFrame.Visible = not InfoFrame.Visible
                DotsBtn.TextColor3 = InfoFrame.Visible and Library.Theme.Accent or Library.Theme.TextDim
            end)
        end

        -- Вспомогательный элемент ползунка каналов для ColorPicker
        local function createColorChannel(name, labelColor, defaultValue, onUpdate)
            local ChannelFrame = Instance.new("Frame")
            ChannelFrame.Name = name .. "Channel"
            ChannelFrame.Size = UDim2.new(1, 0, 0, 16)
            ChannelFrame.BackgroundTransparency = 1
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0, 15, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = labelColor
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 10
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ChannelFrame
            
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -55, 0, 3)
            Track.Position = UDim2.new(0, 20, 0.5, -1)
            Track.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
            Track.BorderSizePixel = 0
            Track.Parent = ChannelFrame
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(defaultValue / 255, 0, 1, 0)
            Fill.BackgroundColor3 = labelColor
            Fill.BorderSizePixel = 0
            Fill.Parent = Track
            
            local Thumb = Instance.new("Frame")
            Thumb.Size = UDim2.new(0, 7, 0, 7)
            Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
            Thumb.Position = UDim2.new(defaultValue / 255, 0, 0.5, 0)
            Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Thumb.Parent = Track
            
            local ThumbCorner = Instance.new("UICorner")
            ThumbCorner.CornerRadius = UDim.new(1, 0)
            ThumbCorner.Parent = Thumb
            
            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0, 25, 1, 0)
            ValLabel.Position = UDim2.new(1, -25, 0, 0)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(math.round(defaultValue))
            ValLabel.TextColor3 = Library.Theme.TextDim
            ValLabel.Font = Enum.Font.Gotham
            ValLabel.TextSize = 9
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.Parent = ChannelFrame
            
            local isDragging = false
            local function update(input)
                local percentage = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local val = math.round(percentage * 255)
                Fill.Size = UDim2.new(percentage, 0, 1, 0)
                Thumb.Position = UDim2.new(percentage, 0, 0.5, 0)
                ValLabel.Text = tostring(val)
                onUpdate(val)
            end
            
            ChannelFrame.InputBegan:Connect(function(input)
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
            
            return ChannelFrame
        end

        -- Кнопка (Button)
        function Elements:CreateButton(btnText, callback, tooltipText)
            callback = callback or function() end
            
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = btnText .. "ButtonFrame"
            ButtonFrame.Size = UDim2.new(1, 0, 0, 24)
            ButtonFrame.BackgroundTransparency = 1
            ButtonFrame.AutomaticSize = Enum.AutomaticSize.Y
            ButtonFrame.Parent = container

            local Button = Instance.new("TextButton")
            Button.Name = btnText .. "Btn"
            Button.Size = UDim2.new(1, (tooltipText and -22 or 0), 0, 24)
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
            Button.Text = btnText
            Button.TextColor3 = Library.Theme.TextDim
            Button.Font = Enum.Font.GothamMedium
            Button.TextSize = 11
            Button.Parent = ButtonFrame

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

            if tooltipText then
                addTooltip(ButtonFrame, tooltipText, 5)
            end

            return ButtonFrame
        end

        -- Тоггл / Флажок (Toggle)
        function Elements:CreateToggle(toggleText, default, callback, tooltipText)
            callback = callback or function() end
            local state = default or false

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = toggleText .. "Toggle"
            ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.AutomaticSize = Enum.AutomaticSize.Y
            ToggleFrame.Parent = container

            local ClickArea = Instance.new("TextButton")
            ClickArea.Size = UDim2.new(1, (tooltipText and -22 or 0), 0, 24)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""
            ClickArea.AutoButtonColor = false
            ClickArea.Parent = ToggleFrame

            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(0, 14, 0, 14)
            Box.Position = UDim2.new(0, 2, 0.5, -7)
            Box.BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(30, 30, 36)
            Box.BorderSizePixel = 0
            Box.Parent = ClickArea

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
            Label.Parent = ClickArea

            local function toggle()
                state = not state
                tween(Box, 0.1, {BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(30, 30, 36)})
                tween(BoxStroke, 0.1, {Color = state and Library.Theme.Accent or Library.Theme.Stroke})
                tween(Label, 0.1, {TextColor3 = state and Library.Theme.Text or Library.Theme.TextDim})
                callback(state)
            end

            ClickArea.MouseButton1Click:Connect(toggle)

            ClickArea.MouseEnter:Connect(function()
                if not state then
                    tween(Label, 0.1, {TextColor3 = Library.Theme.Text})
                    tween(BoxStroke, 0.1, {Color = Color3.fromRGB(80, 80, 95)})
                end
            end)
            ClickArea.MouseLeave:Connect(function()
                if not state then
                    tween(Label, 0.1, {TextColor3 = Library.Theme.TextDim})
                    tween(BoxStroke, 0.1, {Color = Library.Theme.Stroke})
                end
            end)

            if tooltipText then
                addTooltip(ToggleFrame, tooltipText, 5)
            end

            return ToggleFrame
        end

        -- Однострочный Слайдер (Slider)
        function Elements:CreateSlider(sliderText, min, max, default, callback, tooltipText)
            callback = callback or function() end
            local val = default or min

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = sliderText .. "Slider"
            SliderFrame.Size = UDim2.new(1, 0, 0, 24)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.AutomaticSize = Enum.AutomaticSize.Y
            SliderFrame.Parent = container

            local ContentRow = Instance.new("Frame")
            ContentRow.Name = "ContentRow"
            ContentRow.Size = UDim2.new(1, (tooltipText and -22 or 0), 0, 24)
            ContentRow.BackgroundTransparency = 1
            ContentRow.Parent = SliderFrame

            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Size = UDim2.new(0.35, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = sliderText
            Label.TextColor3 = Library.Theme.TextDim
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ContentRow

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(0.65, -65, 0, 4)
            Track.Position = UDim2.new(0.35, 5, 0.5, -2)
            Track.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
            Track.BorderSizePixel = 0
            Track.Parent = ContentRow

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
            ValLabel.Size = UDim2.new(0, 30, 1, 0)
            ValLabel.Position = UDim2.new(1, -55, 0, 0)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(val)
            ValLabel.TextColor3 = Library.Theme.Text
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextSize = 11
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.Parent = ContentRow

            local isDragging = false
            local function update(input)
                local percentage = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                val = math.round(min + ((max - min) * percentage))
                Fill.Size = UDim2.new(percentage, 0, 1, 0)
                Thumb.Position = UDim2.new(percentage, 0, 0.5, 0)
                ValLabel.Text = tostring(val)
                callback(val)
            end

            ContentRow.InputBegan:Connect(function(input)
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
            
            ContentRow.MouseEnter:Connect(function()
                tween(Label, 0.1, {TextColor3 = Library.Theme.Text})
            end)
            ContentRow.MouseLeave:Connect(function()
                if not isDragging then
                    tween(Label, 0.1, {TextColor3 = Library.Theme.TextDim})
                end
            end)

            if tooltipText then
                addTooltip(SliderFrame, tooltipText, 5)
            end

            return SliderFrame
        end

        -- Поле ввода (TextBox)
        function Elements:CreateTextBox(textBoxText, placeholder, callback, tooltipText)
            callback = callback or function() end
            placeholder = placeholder or "Type..."

            local TextFrame = Instance.new("Frame")
            TextFrame.Name = textBoxText .. "TextBox"
            TextFrame.Size = UDim2.new(1, 0, 0, 24)
            TextFrame.BackgroundTransparency = 1
            TextFrame.AutomaticSize = Enum.AutomaticSize.Y
            TextFrame.Parent = container

            local ContentRow = Instance.new("Frame")
            ContentRow.Name = "ContentRow"
            ContentRow.Size = UDim2.new(1, (tooltipText and -22 or 0), 0, 24)
            ContentRow.BackgroundTransparency = 1
            ContentRow.Parent = TextFrame

            local TextLayout = Instance.new("UIListLayout")
            TextLayout.FillDirection = Enum.FillDirection.Horizontal
            TextLayout.SortOrder = Enum.SortOrder.LayoutOrder
            TextLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            TextLayout.Padding = UDim.new(0, 8)
            TextLayout.Parent = ContentRow

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
            Label.Parent = ContentRow

            local BoxBg = Instance.new("Frame")
            BoxBg.Size = UDim2.new(0, 110, 0, 20)
            BoxBg.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
            BoxBg.Parent = ContentRow

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

            if tooltipText then
                addTooltip(TextFrame, tooltipText, 5)
            end

            return TextFrame
        end

        -- Универсальный Выпадающий список (Dropdown & Multi-Dropdown)
        function Elements:CreateDropdown(dropdownText, options, isMulti, default, callback, tooltipText)
            callback = callback or function() end
            isMulti = isMulti or false
            default = default or (isMulti and {} or "")
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = dropdownText .. "Dropdown"
            DropdownFrame.Size = UDim2.new(1, 0, 0, 24)
            DropdownFrame.BackgroundTransparency = 1
            DropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
            DropdownFrame.Parent = container
            
            local HeaderBtn = Instance.new("TextButton")
            HeaderBtn.Name = "HeaderBtn"
            HeaderBtn.Size = UDim2.new(1, (tooltipText and -22 or 0), 0, 24)
            HeaderBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
            HeaderBtn.Text = ""
            HeaderBtn.Parent = DropdownFrame
            
            local HeaderCorner = Instance.new("UICorner")
            HeaderCorner.CornerRadius = UDim.new(0, 4)
            HeaderCorner.Parent = HeaderBtn
            
            local HeaderStroke = Instance.new("UIStroke")
            HeaderStroke.Color = Library.Theme.Stroke
            HeaderStroke.Thickness = 1
            HeaderStroke.Parent = HeaderBtn
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -30, 1, 0)
            Label.Position = UDim2.new(0, 8, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = dropdownText
            Label.TextColor3 = Library.Theme.TextDim
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = HeaderBtn
            
            local Indicator = Instance.new("TextLabel")
            Indicator.Size = UDim2.new(0, 20, 1, 0)
            Indicator.Position = UDim2.new(1, -24, 0, 0)
            Indicator.BackgroundTransparency = 1
            Indicator.Text = "▼"
            Indicator.TextColor3 = Library.Theme.TextDim
            Indicator.Font = Enum.Font.GothamBold
            Indicator.TextSize = 9
            Indicator.Parent = HeaderBtn
            
            local OptionsScroll = Instance.new("ScrollingFrame")
            OptionsScroll.Name = "OptionsScroll"
            OptionsScroll.Size = UDim2.new(1, 0, 0, 0)
            OptionsScroll.Position = UDim2.new(0, 0, 0, 26)
            OptionsScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
            OptionsScroll.BorderSizePixel = 0
            OptionsScroll.ScrollBarThickness = 2
            OptionsScroll.ScrollBarImageColor3 = Library.Theme.Stroke
            OptionsScroll.Visible = false
            OptionsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            OptionsScroll.Parent = DropdownFrame
            
            local ScrollCorner = Instance.new("UICorner")
            ScrollCorner.CornerRadius = UDim.new(0, 4)
            ScrollCorner.Parent = OptionsScroll
            
            local ScrollStroke = Instance.new("UIStroke")
            ScrollStroke.Color = Library.Theme.Stroke
            ScrollStroke.Thickness = 1
            ScrollStroke.Parent = OptionsScroll
            
            local ScrollLayout = Instance.new("UIListLayout")
            ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ScrollLayout.Padding = UDim.new(0, 2)
            ScrollLayout.Parent = OptionsScroll
            
            local ScrollPadding = Instance.new("UIPadding")
            ScrollPadding.PaddingTop = UDim.new(0, 4)
            ScrollPadding.PaddingBottom = UDim.new(0, 4)
            ScrollPadding.PaddingLeft = UDim.new(0, 6)
            ScrollPadding.PaddingRight = UDim.new(0, 6)
            ScrollPadding.Parent = OptionsScroll
            
            local selected = {}
            if isMulti then
                for _, val in ipairs(default) do
                    selected[val] = true
                end
            else
                selected[default] = true
            end
            
            local isOpen = false
            local function toggleDropdown()
                isOpen = not isOpen
                OptionsScroll.Visible = isOpen
                Indicator.Text = isOpen and "▲" or "▼"
                HeaderBtn.TextColor3 = isOpen and Library.Theme.Accent or Library.Theme.TextDim
                
                if isOpen then
                    local itemsCount = #options
                    local calculatedHeight = math.min(itemsCount * 22 + 8, 100)
                    OptionsScroll.Size = UDim2.new(1, 0, 0, calculatedHeight)
                else
                    OptionsScroll.Size = UDim2.new(1, 0, 0, 0)
                end
            end
            
            HeaderBtn.MouseButton1Click:Connect(toggleDropdown)
            
            local optionButtons = {}
            for i, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Name = opt .. "Opt"
                OptBtn.Size = UDim2.new(1, 0, 0, 20)
                OptBtn.BackgroundTransparency = 1
                OptBtn.Text = ""
                OptBtn.Parent = OptionsScroll
                
                local OptLabel = Instance.new("TextLabel")
                OptLabel.Size = UDim2.new(1, -20, 1, 0)
                OptLabel.Position = UDim2.new(0, 4, 0, 0)
                OptLabel.BackgroundTransparency = 1
                OptLabel.Text = opt
                OptLabel.TextColor3 = selected[opt] and Library.Theme.Text or Library.Theme.TextDim
                OptLabel.Font = Enum.Font.Gotham
                OptLabel.TextSize = 10
                OptLabel.TextXAlignment = Enum.TextXAlignment.Left
                OptLabel.Parent = OptBtn
                
                local Check = Instance.new("TextLabel")
                Check.Size = UDim2.new(0, 14, 1, 0)
                Check.Position = UDim2.new(1, -14, 0, 0)
                Check.BackgroundTransparency = 1
                Check.Text = selected[opt] and "✓" or ""
                Check.TextColor3 = Library.Theme.Accent
                Check.Font = Enum.Font.GothamBold
                Check.TextSize = 10
                Check.Parent = OptBtn
                
                OptBtn.MouseButton1Click:Connect(function()
                    if isMulti then
                        selected[opt] = not selected[opt]
                        OptLabel.TextColor3 = selected[opt] and Library.Theme.Text or Library.Theme.TextDim
                        Check.Text = selected[opt] and "✓" or ""
                        
                        local currentSelection = {}
                        for k, v in pairs(selected) do
                            if v then table.insert(currentSelection, k) end
                        end
                        callback(currentSelection)
                    else
                        for o, btn in pairs(optionButtons) do
                            selected[o] = false
                            btn.Label.TextColor3 = Library.Theme.TextDim
                            btn.Check.Text = ""
                        end
                        selected[opt] = true
                        OptLabel.TextColor3 = Library.Theme.Text
                        Check.Text = "✓"
                        toggleDropdown()
                        callback(opt)
                    end
                end)
                
                optionButtons[opt] = {Label = OptLabel, Check = Check}
            end
            
            if tooltipText then
                addTooltip(DropdownFrame, tooltipText, 5)
            end
            
            return DropdownFrame
        end

        -- Выбор цвета (Color Picker)
        function Elements:CreateColorPicker(pickerText, defaultColor, callback, tooltipText)
            callback = callback or function() end
            defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
            
            local PickerFrame = Instance.new("Frame")
            PickerFrame.Name = pickerText .. "ColorPicker"
            PickerFrame.Size = UDim2.new(1, 0, 0, 24)
            PickerFrame.BackgroundTransparency = 1
            PickerFrame.AutomaticSize = Enum.AutomaticSize.Y
            PickerFrame.Parent = container
            
            local MainRow = Instance.new("Frame")
            MainRow.Name = "MainRow"
            MainRow.Size = UDim2.new(1, (tooltipText and -22 or 0), 0, 24)
            MainRow.BackgroundTransparency = 1
            MainRow.Parent = PickerFrame
            
            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Size = UDim2.new(1, -30, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = pickerText
            Label.TextColor3 = Library.Theme.TextDim
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = MainRow
            
            local ColorBox = Instance.new("TextButton")
            ColorBox.Size = UDim2.new(0, 20, 0, 14)
            ColorBox.Position = UDim2.new(1, -20, 0.5, -7)
            ColorBox.BackgroundColor3 = defaultColor
            ColorBox.Text = ""
            ColorBox.Parent = MainRow
            
            local ColorCorner = Instance.new("UICorner")
            ColorCorner.CornerRadius = UDim.new(0, 3)
            ColorCorner.Parent = ColorBox
            
            local ColorStroke = Instance.new("UIStroke")
            ColorStroke.Color = Library.Theme.Stroke
            ColorStroke.Thickness = 1
            ColorStroke.Parent = ColorBox
            
            local PickerContainer = Instance.new("Frame")
            PickerContainer.Name = "PickerContainer"
            PickerContainer.Size = UDim2.new(1, 0, 0, 0)
            PickerContainer.Position = UDim2.new(0, 0, 0, 26)
            PickerContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
            PickerContainer.BorderSizePixel = 0
            PickerContainer.Visible = false
            PickerContainer.ClipsDescendants = true
            PickerContainer.Parent = PickerFrame
            
            local ContainerCorner = Instance.new("UICorner")
            ContainerCorner.CornerRadius = UDim.new(0, 4)
            ContainerCorner.Parent = PickerContainer
            
            local ContainerStroke = Instance.new("UIStroke")
            ContainerStroke.Color = Library.Theme.Stroke
            ContainerStroke.Thickness = 1
            ContainerStroke.Parent = PickerContainer
            
            local ContainerLayout = Instance.new("UIListLayout")
            ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContainerLayout.Padding = UDim.new(0, 4)
            ContainerLayout.Parent = PickerContainer
            
            local ContainerPadding = Instance.new("UIPadding")
            ContainerPadding.PaddingTop = UDim.new(0, 6)
            ContainerPadding.PaddingBottom = UDim.new(0, 6)
            ContainerPadding.PaddingLeft = UDim.new(0, 8)
            ContainerPadding.PaddingRight = UDim.new(0, 8)
            ContainerPadding.Parent = PickerContainer
            
            local r, g, b = math.round(defaultColor.R * 255), math.round(defaultColor.G * 255), math.round(defaultColor.B * 255)
            
            local function updateColor()
                local clr = Color3.fromRGB(r, g, b)
                ColorBox.BackgroundColor3 = clr
                callback(clr)
            end
            
            local RedChannel = createColorChannel("R", Color3.fromRGB(255, 75, 75), r, function(val)
                r = val
                updateColor()
            end)
            RedChannel.LayoutOrder = 1
            RedChannel.Parent = PickerContainer
            
            local GreenChannel = createColorChannel("G", Color3.fromRGB(75, 255, 75), g, function(val)
                g = val
                updateColor()
            end)
            GreenChannel.LayoutOrder = 2
            GreenChannel.Parent = PickerContainer
            
            local BlueChannel = createColorChannel("B", Color3.fromRGB(75, 75, 255), b, function(val)
                b = val
                updateColor()
            end)
            BlueChannel.LayoutOrder = 3
            BlueChannel.Parent = PickerContainer
            
            local isOpen = false
            ColorBox.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                PickerContainer.Visible = isOpen
                if isOpen then
                    PickerContainer.Size = UDim2.new(1, 0, 0, 68)
                else
                    PickerContainer.Size = UDim2.new(1, 0, 0, 0)
                end
            end)
            
            if tooltipText then
                addTooltip(PickerFrame, tooltipText, 5)
            end
            
            return PickerFrame
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
