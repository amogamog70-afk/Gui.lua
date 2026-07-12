-- [[
--    METEOR / WISH STYLE CLICKGUI ENGINE
--    [VERSION 5.2 - FIX & AUDIO UPDATE] 
-- ]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")

local Library = {
    Windows = {},
    Registry = {}, 
    AudioRegistry = {},
    ToggleKey = Enum.KeyCode.RightShift,
    Visible = true,
    WatermarkEnabled = true,
    LastToggleTime = 0
}

-- Глобальный аудио-объект для плеера
Library.LocalSound = Instance.new("Sound")
Library.LocalSound.Name = "MeteorEngine_Audio"
Library.LocalSound.Parent = SoundService

local Theme = {
    MainBG = Color3.fromRGB(12, 12, 14),
    TopbarBG = Color3.fromRGB(18, 18, 22),
    ElementBG = Color3.fromRGB(16, 16, 20),
    InnerBoxBG = Color3.fromRGB(8, 8, 10),
    Accent = Color3.fromRGB(221, 43, 110),
    TextMain = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(140, 140, 145),
    Stroke = Color3.fromRGB(26, 26, 32),
    Hover = Color3.fromRGB(24, 24, 30)
}

-- Инициализация директории конфигов
pcall(function()
    if makefolder then makefolder("Meteor_Configs") end
end)

local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = "MeteorMenu_Core"
MenuGui.ResetOnSpawn = false

local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "MeteorWatermark_Core"
WatermarkGui.ResetOnSpawn = false

pcall(function() 
    MenuGui.Parent = CoreGui 
    WatermarkGui.Parent = CoreGui
end)

if not MenuGui.Parent then
    MenuGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    WatermarkGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local function applyStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Miter
    stroke.Parent = parent
    return stroke
end

local function tween(object, info, properties)
    local t = TweenService:Create(object, info, properties)
    t:Play()
    return t
end

-- ИСПРАВЛЕННЫЙ КЕЙБИНД СКРЫТИЯ МЕНЮ (Без перехватов Роблокса и без фризов анимации)
UserInputService.InputBegan:Connect(function(input)
    if UserInputService:GetFocusedTextBox() then return end
    
    if input.KeyCode == Library.ToggleKey then
        local currentTime = os.clock()
        if (currentTime - Library.LastToggleTime) < 0.25 then return end -- Защита от спама кнопкой
        Library.LastToggleTime = currentTime
        
        Library.Visible = not Library.Visible
        
        if Library.Visible then
            MenuGui.Enabled = true
            for _, wData in ipairs(Library.Windows) do
                wData.UIScale.Scale = 0.8
                wData.MainFrame.BackgroundTransparency = 1
                wData.Topbar.BackgroundTransparency = 1
                wData.Topbar.TextTransparency = 1
                
                tween(wData.UIScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {Scale = 1})
                tween(wData.MainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {BackgroundTransparency = 0})
                tween(wData.Topbar, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {BackgroundTransparency = 0, TextTransparency = 0})
            end
        else
            local totalWindows = #Library.Windows
            local closedWindows = 0
            for _, wData in ipairs(Library.Windows) do
                tween(wData.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingStyle.In), {Scale = 0.8})
                tween(wData.MainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingStyle.In), {BackgroundTransparency = 1})
                local t = tween(wData.Topbar, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingStyle.In), {BackgroundTransparency = 1, TextTransparency = 1})
                
                t.Completed:Connect(function()
                    closedWindows = closedWindows + 1
                    if closedWindows == totalWindows and not Library.Visible then
                        MenuGui.Enabled = false
                    end
                end)
            end
        end
    end
end)

local function makeDraggable(frame, dragHandle, uiScale)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local scaleModifier = uiScale and uiScale.Scale or 1
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + (delta.X / scaleModifier), 
                startPos.Y.Scale, startPos.Y.Offset + (delta.Y / scaleModifier)
            )
        end
    end)
end

function Library:CreateWindow(windowName, initialPosition)
    local Window = { Elements = {}, Collapsed = false }
    initialPosition = initialPosition or UDim2.new(0, 50, 0, 50)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = windowName .. "_Window"
    MainFrame.Size = UDim2.new(0, 220, 0, 30)
    MainFrame.Position = initialPosition
    MainFrame.BackgroundColor3 = Theme.MainBG
    MainFrame.BorderSizePixel = 0
    MainFrame.AutomaticSize = Enum.AutomaticSize.Y
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = MenuGui
    local MainFrameStroke = applyStroke(MainFrame, Theme.Stroke, 1)

    local WindowScale = Instance.new("UIScale")
    WindowScale.Parent = MainFrame

    local Topbar = Instance.new("TextButton")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 30)
    Topbar.BackgroundColor3 = Theme.TopbarBG
    Topbar.BorderSizePixel = 0
    Topbar.Text = " " .. windowName
    Topbar.Font = Enum.Font.Code
    Topbar.TextSize = 13
    Topbar.TextColor3 = Theme.TextMain
    Topbar.TextXAlignment = Enum.TextXAlignment.Left
    Topbar.AutoButtonColor = false
    Topbar.Parent = MainFrame

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = Topbar

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.Position = UDim2.new(0, 0, 0, 30)
    Container.BackgroundTransparency = 1
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.BorderSizePixel = 0
    Container.Parent = MainFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 1)
    ListLayout.Parent = Container

    makeDraggable(MainFrame, Topbar, WindowScale)

    local wData = {MainFrame = MainFrame, Topbar = Topbar, Container = Container, UIScale = WindowScale, Collapsed = false}
    table.insert(Library.Windows, wData)

    -- ФИКС ЗАВИСАНИЯ ПКМ: Сворачивание теперь моментальное, без блокирующих потоков и конфликтов разметки
    Topbar.MouseButton2Click:Connect(function()
        Window.Collapsed = not Window.Collapsed
        wData.Collapsed = Window.Collapsed
        
        if Window.Collapsed then
            Container.Visible = false
            MainFrame.AutomaticSize = Enum.AutomaticSize.None
            MainFrame.Size = UDim2.new(0, 220, 0, 30)
        else
            Container.Visible = true
            MainFrame.AutomaticSize = Enum.AutomaticSize.Y
        end
    end)

    function Window:CreateButton(name, callback)
        callback = callback or function() end
        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.Size = UDim2.new(1, 0, 0, 24)
        ButtonFrame.BackgroundColor3 = Theme.ElementBG
        ButtonFrame.BorderSizePixel = 0
        ButtonFrame.Parent = Container

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.BackgroundTransparency = 1
        Btn.Text = " " .. name
        Btn.Font = Enum.Font.Code
        Btn.TextSize = 11
        Btn.TextColor3 = Theme.TextMain
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Btn.Parent = ButtonFrame

        Btn.MouseEnter:Connect(function() tween(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Hover}) end)
        Btn.MouseLeave:Connect(function() tween(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementBG}) end)
        Btn.MouseButton1Click:Connect(function()
            ButtonFrame.BackgroundColor3 = Theme.Accent
            tween(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover})
            callback()
        end)
    end

    function Window:CreateToggle(name, default, callback, defaultColor, colorCallback, isAudioScope)
        local state = default or false
        local currentInstColor = defaultColor or Color3.fromRGB(255,255,255)
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name
        local targetRegistry = isAudioScope and Library.AudioRegistry or Library.Registry

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
        ToggleFrame.BackgroundColor3 = Theme.ElementBG
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.AutomaticSize = Enum.AutomaticSize.Y
        ToggleFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, defaultColor and -50 or -30, 0, 24)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = state and Theme.TextMain or Theme.TextDim
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame

        local Box = Instance.new("TextButton")
        Box.AnchorPoint = Vector2.new(1, 0)
        Box.Size = UDim2.new(0, 14, 0, 14)
        Box.Position = UDim2.new(1, -6, 0, 5)
        Box.BackgroundColor3 = state and Theme.Accent or Theme.InnerBoxBG
        Box.BorderSizePixel = 0
        Box.Text = ""
        Box.Parent = ToggleFrame
        local BoxStroke = applyStroke(Box, Theme.Stroke, 1)

        local function updateToggle()
            Label.TextColor3 = state and Theme.TextMain or Theme.TextDim
            Box.BackgroundColor3 = state and Theme.Accent or Theme.InnerBoxBG
            BoxStroke.Color = state and Theme.Accent or Theme.Stroke
        end

        local function toggle()
            state = not state
            updateToggle()
            callback(state)
        end

        Box.MouseButton1Click:Connect(toggle)
        
        local InvisibleBtn = Instance.new("TextButton")
        InvisibleBtn.Size = UDim2.new(1, defaultColor and -50 or -30, 0, 24)
        InvisibleBtn.BackgroundTransparency = 1
        InvisibleBtn.Text = ""
        InvisibleBtn.Parent = ToggleFrame
        InvisibleBtn.MouseButton1Click:Connect(toggle)

        targetRegistry[registryKey] = {
            Type = "Toggle",
            Get = function() return { State = state } end,
            Set = function(self, data)
                state = data.State
                updateToggle()
                callback(state)
            end
        }

        return { SetState = function(self, val) state = val updateToggle() callback(state) end }
    end

    function Window:CreateSlider(name, min, max, default, decimals, callback, isAudioScope)
        min = min or 0 max = max or 100 decimals = decimals or 0
        local value = math.clamp(default or min, min, max)
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name
        local targetRegistry = isAudioScope and Library.AudioRegistry or Library.Registry

        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 34)
        SliderFrame.BackgroundColor3 = Theme.ElementBG
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.6, 0, 0, 18)
        Label.Position = UDim2.new(0, 6, 0, 2)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextMain
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderFrame

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.AnchorPoint = Vector2.new(1, 0)
        ValueLabel.Size = UDim2.new(0.35, 0, 0, 18)
        ValueLabel.Position = UDim2.new(1, -6, 0, 2)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = string.format("%." .. decimals .. "f", value)
        ValueLabel.Font = Enum.Font.Code
        ValueLabel.TextSize = 11
        ValueLabel.TextColor3 = Theme.Accent
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderFrame

        local SliderBar = Instance.new("TextButton")
        SliderBar.Size = UDim2.new(1, -12, 0, 6)
        SliderBar.Position = UDim2.new(0, 6, 0, 22)
        SliderBar.BackgroundColor3 = Theme.InnerBoxBG
        SliderBar.BorderSizePixel = 0
        SliderBar.Text = ""
        SliderBar.AutoButtonColor = false
        SliderBar.Parent = SliderFrame
        local SliderBarStroke = applyStroke(SliderBar, Theme.Stroke, 1)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = SliderBar

        local sliding = false
        local function updateSlider(input)
            local percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * percentage
            local formatStr = "%." .. decimals .. "f"
            value = tonumber(string.format(formatStr, value))
            Fill.Size = UDim2.new(percentage, 0, 1, 0)
            ValueLabel.Text = string.format(formatStr, value)
            callback(value)
        end

        SliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true updateSlider(input) end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
        end)

        local function externalSet(val)
            value = math.clamp(val, min, max)
            local pct = (value - min) / (max - min)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            ValueLabel.Text = string.format("%." .. decimals .. "f", value)
            callback(value)
        end

        targetRegistry[registryKey] = {
            Type = "Slider",
            Get = function() return value end,
            Set = function(self, val) externalSet(val) end
        }

        return { SetValue = externalSet }
    end

    function Window:CreateTextBox(name, placeholder, callback, isAudioScope)
        callback = callback or function() end
        local registryKey = windowName .. "_" .. name
        local targetRegistry = isAudioScope and Library.AudioRegistry or Library.Registry

        local BoxFrame = Instance.new("Frame")
        BoxFrame.Size = UDim2.new(1, 0, 0, 26)
        BoxFrame.BackgroundColor3 = Theme.ElementBG
        BoxFrame.BorderSizePixel = 0
        BoxFrame.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.4, 0, 1, 0)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextDim
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = BoxFrame

        local TBox = Instance.new("TextBox")
        TBox.AnchorPoint = Vector2.new(1, 0)
        TBox.Size = UDim2.new(0.55, 0, 0, 16)
        TBox.Position = UDim2.new(1, -6, 0, 5)
        TBox.BackgroundColor3 = Theme.InnerBoxBG
        TBox.BorderSizePixel = 0
        TBox.Text = ""
        TBox.PlaceholderText = placeholder
        TBox.PlaceholderColor3 = Theme.TextDim
        TBox.TextColor3 = Theme.TextMain
        TBox.Font = Enum.Font.Code
        TBox.TextSize = 10
        TBox.TextXAlignment = Enum.TextXAlignment.Center
        TBox.ClearTextOnFocus = false
        TBox.Parent = BoxFrame
        local BoxStroke = applyStroke(TBox, Theme.Stroke, 1)

        TBox.Focused:Connect(function() Label.TextColor3 = Theme.TextMain BoxStroke.Color = Theme.Accent end)
        TBox.FocusLost:Connect(function(enter) Label.TextColor3 = Theme.TextDim BoxStroke.Color = Theme.Stroke callback(TBox.Text, enter) end)

        targetRegistry[registryKey] = {
            Type = "TextBox",
            Get = function() return TBox.Text end,
            Set = function(self, val) TBox.Text = val callback(val, false) end
        }
        
        return { GetText = function() return TBox.Text end, SetText = function(self, val) TBox.Text = val end }
    end

    function Window:CreateDropdown(name, list, default, callback)
        list = list or {} 
        local currentSelection = default or list[1] or "" 
        callback = callback or function() end 
        local expanded = false
        local registryKey = windowName .. "_" .. name

        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Size = UDim2.new(1, 0, 0, 26)
        DropdownFrame.BackgroundColor3 = Theme.ElementBG
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
        DropdownFrame.Parent = Container

        local Header = Instance.new("TextButton")
        Header.Size = UDim2.new(1, 0, 0, 26)
        Header.BackgroundTransparency = 1
        Header.Text = ""
        Header.Parent = DropdownFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.4, 0, 1, 0)
        Label.Position = UDim2.new(0, 6, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.Font = Enum.Font.Code
        Label.TextSize = 11
        Label.TextColor3 = Theme.TextMain
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Header

        local SelectionLabel = Instance.new("TextLabel")
        SelectionLabel.AnchorPoint = Vector2.new(1, 0)
        SelectionLabel.Size = UDim2.new(0.55, -14, 0, 16)
        SelectionLabel.Position = UDim2.new(1, -20, 0, 5)
        SelectionLabel.BackgroundColor3 = Theme.InnerBoxBG
        SelectionLabel.Text = currentSelection
        SelectionLabel.Font = Enum.Font.Code
        SelectionLabel.TextSize = 10
        SelectionLabel.TextColor3 = Theme.Accent
        SelectionLabel.Parent = Header
        local BoxStroke = applyStroke(SelectionLabel, Theme.Stroke, 1)

        local Arrow = Instance.new("TextLabel")
        Arrow.AnchorPoint = Vector2.new(1, 0)
        Arrow.Size = UDim2.new(0, 10, 0, 16)
        Arrow.Position = UDim2.new(1, -6, 0, 5)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "v"
        Arrow.Font = Enum.Font.Code
        Arrow.TextSize = 10
        Arrow.TextColor3 = Theme.TextDim
        Arrow.Parent = Header

        local OptionsContainer = Instance.new("Frame")
        OptionsContainer.Size = UDim2.new(0.55, -14, 0, 0)
        OptionsContainer.Position = UDim2.new(0.45, 0, 0, 24)
        OptionsContainer.BackgroundColor3 = Theme.InnerBoxBG
        OptionsContainer.BorderSizePixel = 0
        OptionsContainer.AutomaticSize = Enum.AutomaticSize.Y
        OptionsContainer.Visible = false
        OptionsContainer.ZIndex = 10
        OptionsContainer.Parent = DropdownFrame
        applyStroke(OptionsContainer, Theme.Stroke, 1)

        local OptionsLayout = Instance.new("UIListLayout")
        OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        OptionsLayout.Parent = OptionsContainer

        local function refreshOptions()
            for _, child in ipairs(OptionsContainer:GetChildren()) do 
                if child:IsA("TextButton") then child:Destroy() end 
            end
            for _, optionName in ipairs(list) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 18)
                OptBtn.BackgroundColor3 = optionName == currentSelection and Theme.Hover or Color3.fromRGB(0,0,0)
                OptBtn.BackgroundTransparency = optionName == currentSelection and 0 or 1
                OptBtn.BorderSizePixel = 0
                OptBtn.Text = optionName
                OptBtn.Font = Enum.Font.Code
                OptBtn.TextSize = 10
                OptBtn.TextColor3 = optionName == currentSelection and Theme.Accent or Theme.TextDim
                OptBtn.ZIndex = 11
                OptBtn.Parent = OptionsContainer

                OptBtn.MouseButton1Click:Connect(function()
                    currentSelection = optionName
                    SelectionLabel.Text = optionName
                    expanded = false
                    OptionsContainer.Visible = false
                    Arrow.Text = "v"
                    BoxStroke.Color = Theme.Stroke
                    callback(optionName)
                end)
            end
        end

        Header.MouseButton1Click:Connect(function()
            expanded = not expanded
            OptionsContainer.Visible = expanded
            Arrow.Text = expanded and "^" or "v"
            BoxStroke.Color = expanded and Theme.Accent or Theme.Stroke
            if expanded then refreshOptions() end
        end)

        Library.Registry[registryKey] = {
            Type = "Dropdown",
            Get = function() return currentSelection end,
            Set = function(self, val)
                currentSelection = val
                SelectionLabel.Text = val
                callback(val)
            end
        }

        return {
            SetSelection = function(self, val)
                currentSelection = val
                SelectionLabel.Text = val
                callback(val)
            end,
            Refresh = function(self, newList)
                list = newList or {}
                if expanded then refreshOptions() end
            end
        }
    end

    return Window
end

-- СИСТЕМА ОБЫЧНЫХ КОНФИГОВ
function Library:SaveConfig(name)
    local data = {}
    for key, val in pairs(Library.Registry) do
        data[key] = val:Get()
    end
    pcall(function()
        if writefile then
            writefile("Meteor_Configs/" .. name .. ".json", HttpService:JSONEncode(data))
        end
    end)
end

function Library:LoadConfig(name)
    local data
    pcall(function()
        if readfile then
            data = HttpService:JSONDecode(readfile("Meteor_Configs/" .. name .. ".json"))
        end
    end)
    if data then
        for key, val in pairs(data) do
            if Library.Registry[key] then
                pcall(function() Library.Registry[key]:Set(val) end)
            end
        end
    end
end

-- СИСТЕМА НЕЗАВИСИМЫХ АУДИО-КОНФИГОВ
function Library:SaveAudioConfig(name)
    local data = {}
    for key, val in pairs(Library.AudioRegistry) do
        data[key] = val:Get()
    end
    pcall(function()
        if writefile then
            writefile("Meteor_Configs/Audio_" .. name .. ".json", HttpService:JSONEncode(data))
        end
    end)
end

function Library:LoadAudioConfig(name)
    local data
    pcall(function()
        if readfile then
            data = HttpService:JSONDecode(readfile("Meteor_Configs/Audio_" .. name .. ".json"))
        end
    end)
    if data then
        for key, val in pairs(data) do
            if Library.AudioRegistry[key] then
                pcall(function() Library.AudioRegistry[key]:Set(val) end)
            end
        end
    end
end

-- ГЕНЕРАЦИЯ ПОСТОЯННОЙ ВКЛАДКИ АУДИОПЛЕЕРА
local AudioWindow = Library:CreateWindow("Audio Player", UDim2.new(0, 280, 0, 50))
do
    local audioConfigName = "default"

    AudioWindow:CreateTextBox("Sound ID", "rbxassetid://...", function(text)
        Library.LocalSound.SoundId = text
    end, true)

    AudioWindow:CreateSlider("Volume", 0, 10, 1, 1, function(val)
        Library.LocalSound.Volume = val
    end, true)

    AudioWindow:CreateSlider("Speed", 0.5, 3, 1, 2, function(val)
        Library.LocalSound.PlaybackSpeed = val
    end, true)

    AudioWindow:CreateToggle("Loop Track", false, function(state)
        Library.LocalSound.Looped = state
    end, nil, nil, true)

    AudioWindow:CreateButton("Play / Resume", function()
        Library.LocalSound:Play()
    end)

    AudioWindow:CreateButton("Pause Track", function()
        Library.LocalSound:Pause()
    end)

    AudioWindow:CreateButton("Stop Track", function()
        Library.LocalSound:Stop()
    end)

    AudioWindow:CreateTextBox("Config Name", "default", function(text)
        audioConfigName = text ~= "" and text or "default"
    end, true)

    AudioWindow:CreateButton("Save Audio Settings", function()
        Library:SaveAudioConfig(audioConfigName)
    end)

    AudioWindow:CreateButton("Load Audio Settings", function()
        Library:LoadAudioConfig(audioConfigName)
    end)
end

-- ВОТЕРМАРК
do
    local WatermarkFrame = Instance.new("Frame")
    WatermarkFrame.Size = UDim2.new(0, 260, 0, 24)
    WatermarkFrame.Position = UDim2.new(0, 10, 0, 10)
    WatermarkFrame.BackgroundColor3 = Theme.MainBG
    WatermarkFrame.BorderSizePixel = 0
    WatermarkFrame.Parent = WatermarkGui
    applyStroke(WatermarkFrame, Theme.Stroke, 1)

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = WatermarkFrame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -12, 1, -2)
    TextLabel.Position = UDim2.new(0, 6, 0, 2)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = "meteor v5.2 | fps: 0 | mem: 0mb | ping: 0ms"
    TextLabel.Font = Enum.Font.Code
    TextLabel.TextSize = 11
    TextLabel.TextColor3 = Theme.TextMain
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = WatermarkFrame

    local fpsCount = 0
    local nextUpdate = os.clock() + 1

    RunService.RenderStepped:Connect(function()
        fpsCount = fpsCount + 1
        local now = os.clock()
        if now >= nextUpdate then
            local mem = math.floor(Stats:GetTotalMemoryUsageMb())
            local pingStr = "0"
            pcall(function()
                local serverStats = Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerStatsItem")
                local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")
                if dataPing then
                    pingStr = tostring(math.floor(dataPing:GetValue()))
                end
            end)
            
            TextLabel.Text = string.format("meteor v5.2 | fps: %d | mem: %dmb | ping: %sms", fpsCount, mem, pingStr)
            fpsCount = 0
            nextUpdate = now + 1
        end
        WatermarkFrame.Visible = Library.WatermarkEnabled
    end)
end

return Library
